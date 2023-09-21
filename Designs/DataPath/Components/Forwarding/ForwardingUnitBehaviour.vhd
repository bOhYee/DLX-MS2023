LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY FORWARDING_UNIT_BEHAV IS 
    PORT(IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
         ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
         EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
         MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);

         -- For ID stage management only
         IF_ID_IsBranch: OUT std_logic;
         ID_EXE_IsLoad: OUT std_logic;
         ID_EXE_HasDest: OUT std_logic;
         WB_HasDestA, WB_HasDestB: OUT std_logic;

         -- For EXE stage management only
         FW_A, FW_B, FW_MEM: OUT std_logic_vector(1 DOWNTO 0));
END FORWARDING_UNIT_BEHAV;

ARCHITECTURE BEHAVIOURAL OF FORWARDING_UNIT_BEHAV IS
BEGIN

    -- Forwarding needed for DECODE stage
    DecodeForw: PROCESS(IF_ID_Instruction, ID_EXE_Instruction, MEM_WB_Instruction)
    VARIABLE WBIsR, WBIsI: std_logic;
    BEGIN
        WBIsR := '0';
        WBIsI := '0';

        -- Check for taking directly from WB stage the data without waiting for RF to save them
        -- First, we need to know if the instruction actually saves data in the RF
        -- Second, need to check which operand has to be substituted: these checks are performed inside the same IF statements used for LOAD checks
        IF NOT(MEM_WB_Instruction(31 DOWNTO 26) = ITYPE_BEQZ OR
               MEM_WB_Instruction(31 DOWNTO 26) = ITYPE_BNEZ OR
               MEM_WB_Instruction(31 DOWNTO 26) = ITYPE_NOP OR
               MEM_WB_Instruction(31 DOWNTO 26) = ITYPE_SW OR
               MEM_WB_Instruction(31 DOWNTO 26) = JTYPE_J OR
               MEM_WB_Instruction(31 DOWNTO 26) = JTYPE_JAL) THEN
            
            IF MEM_WB_Instruction(31 DOWNTO 26) = RTYPE THEN
                WBIsR := '1';
            ELSE
                WBIsI := '1';
            END IF;
        END IF;

        -- Want to check if the instruction that is executed in the EXE stage is a LOAD operation
        -- in order to create a bubble in the pipeline to make use of forwarding for data management
        IF ID_EXE_Instruction(31 DOWNTO 26) = ITYPE_LOAD THEN
            ID_EXE_IsLoad <= '1';
        END IF;

        -- Want to check operands also to make use of forwarding:
        -- If they do not match, no bubble in pipeline since no forwarding is required
        -- If R-type instruction need to check the two source operands
        IF IF_ID_Instruction(31 DOWNTO 26) = RTYPE THEN
            IF IF_ID_Instruction(25 DOWNTO 21) = ID_EXE_Instruction(20 DOWNTO 16) OR
               IF_ID_Instruction(20 DOWNTO 16) = ID_EXE_Instruction(20 DOWNTO 16) THEN

                ID_EXE_HasDest <= '1'; 
            END IF;

            IF WBIsR = '1' THEN
                -- Not ELSIF structure since both A and B can require the same data
                IF IF_ID_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                    WB_HasDestA <= '1'; 
                END IF;
                
                IF IF_ID_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                    WB_HasDestB <= '1';
                END IF;

            ELSIF WBIsI = '1' THEN
                -- Not ELSIF structure since both A and B can require the same data
                IF IF_ID_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                    WB_HasDestA <= '1'; 
                END IF;
                
                IF IF_ID_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                    WB_HasDestB <= '1';
                END IF;

            END IF;

        -- If not J-type then it is an I-type instruction
        -- Need to check only rs
        ELSIF NOT((IF_ID_Instruction(31 DOWNTO 26) = JTYPE_J OR IF_ID_Instruction(31 DOWNTO 26) = JTYPE_JAL)) THEN
            IF IF_ID_Instruction(25 DOWNTO 21) = ID_EXE_Instruction(20 DOWNTO 16) THEN
                ID_EXE_HasDest <= '1'; 
            END IF;
        
            -- Last check: we want to know if the instruction in IF_ID is a branch or a jump
            -- They are not managed in an optimized way: generate NOP operations until PC is computed and effective
            IF IF_ID_Instruction(31 DOWNTO 26) = ITYPE_BEQZ OR IF_ID_Instruction(31 DOWNTO 26) = ITYPE_BNEZ THEN
                IF_ID_IsBranch <= '1';
            END IF;

            IF WBIsR = '1' THEN
                IF IF_ID_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                    WB_HasDestA <= '1'; 
                END IF;

            ELSIF WBIsI = '1' THEN
                IF IF_ID_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                    WB_HasDestA <= '1';
                END IF;

            END IF;

        ELSE
            -- Last check: we want to know if the instruction in IF_ID is a branch or a jump
            -- They are not managed in an optimized way: generate NOP operations until PC is computed and effective
            IF_ID_IsBranch <= '1';
        END IF;

    END PROCESS;

    -- Forwarding needed for EXE stage
    ExecutionForw: PROCESS(ID_EXE_Instruction, EXE_MEM_Instruction, MEM_WB_Instruction)
    VARIABLE ID_EXE_NoJMP, EXE_MEM_NoJMP, MEM_WB_NoJMP: std_logic;
    VARIABLE EX_MEM_ResNeeded_A, EX_MEM_ResNeeded_B, MEM_WB_ResNeeded_A, MEM_WB_ResNeeded_B: std_logic;
    VARIABLE SW_FORW_EXE, SW_FORW_MEM: std_logic;
    BEGIN
        -- Variable initialization
        -- 0 - JUMP (J or JAL); 1 - R or I-type instruction
        ID_EXE_NoJMP := '0';
        EXE_MEM_NoJMP := '0';
        MEM_WB_NoJMP := '0';

        EX_MEM_ResNeeded_A := '0';
        EX_MEM_ResNeeded_B := '0';
        MEM_WB_ResNeeded_A := '0';
        MEM_WB_ResNeeded_B := '0';

        SW_FORW_EXE := '0';
        SW_FORW_MEM := '0';

        -- Check if instruction in the ID/EXE buffer is a branch instruction (J or JAL) since they do not need any forwarding
        IF NOT(ID_EXE_Instruction(31 DOWNTO 26) = JTYPE_J OR ID_EXE_Instruction(31 DOWNTO 26) = JTYPE_JAL) THEN
            ID_EXE_NoJMP := '1';
        END IF;

        -- Check if instruction in the EXE/MEM buffer is a J or a JAL
        IF NOT(EXE_MEM_Instruction(31 DOWNTO 26) = JTYPE_J OR EXE_MEM_Instruction(31 DOWNTO 26) = JTYPE_JAL) THEN
            EXE_MEM_NoJMP := '1';
        END IF;

        -- Check if instruction in the MEM/WB buffer is a J or a JAL
        IF NOT(MEM_WB_Instruction(31 DOWNTO 26) = JTYPE_J  OR MEM_WB_Instruction(31 DOWNTO 26) = JTYPE_JAL) THEN
            MEM_WB_NoJMP := '1';
        END IF;

        -- FORWARDING CHECKS
        -- Do I need to forward the data computed during the previous clock cycle and now stored in the EX/MEM transition register?
        
        -- Two R-type instructions: the current has to check for each operand if there's a matching to the destination
        IF ID_EXE_Instruction(31 DOWNTO 26) = RTYPE AND EXE_MEM_Instruction(31 DOWNTO 26) = RTYPE THEN
            -- Both operands can refer to the same value
            IF ID_EXE_Instruction(25 DOWNTO 21) = EXE_MEM_Instruction(15 DOWNTO 11) THEN
                EX_MEM_ResNeeded_A := '1';
            END IF;
            
            IF ID_EXE_Instruction(20 DOWNTO 16) = EXE_MEM_Instruction(15 DOWNTO 11) THEN
                EX_MEM_ResNeeded_B := '1';
            END IF;

        -- Current is an R-type instructions while the next is an I-type instruction: the current has to check for each operand if there's a matching to the destination
        ELSIF ID_EXE_Instruction(31 DOWNTO 26) = RTYPE AND EXE_MEM_NoJMP = '1' THEN
            -- Both operands can refer to the same value
            IF ID_EXE_Instruction(25 DOWNTO 21) = EXE_MEM_Instruction(20 DOWNTO 16) THEN
                EX_MEM_ResNeeded_A := '1';
            END IF;
            
            IF ID_EXE_Instruction(20 DOWNTO 16) = EXE_MEM_Instruction(20 DOWNTO 16) THEN
                EX_MEM_ResNeeded_B := '1';

            END IF;

        -- If it is an I-type instruction: need only to check RS
        -- Only in A can be forwarded the data from the successor stages
        ELSIF ID_EXE_NoJMP = '1' AND EXE_MEM_Instruction(31 DOWNTO 26) = RTYPE THEN
            IF ID_EXE_Instruction(25 DOWNTO 21) = EXE_MEM_Instruction(15 DOWNTO 11) THEN
                EX_MEM_ResNeeded_A := '1'; 

            END IF;

        -- Both instruction are of I-type: need only to check RS
        -- Only in A can be forwarded the data from the successor stages
        ELSIF ID_EXE_NoJMP = '1' AND EXE_MEM_NoJMP = '1' THEN
            IF ID_EXE_Instruction(25 DOWNTO 21) = EXE_MEM_Instruction(20 DOWNTO 16) THEN
                EX_MEM_ResNeeded_A := '1'; 
            END IF;

        END IF;

        -- Second forwarding check
        -- Do I need to forward the data computed during the previous Memory stage and now stored in the MEM/WB transition register?

        -- Two R-type instructions: the current has to check for each operand if there's a matching to the destination
        IF ID_EXE_Instruction(31 DOWNTO 26) = RTYPE AND MEM_WB_Instruction(31 DOWNTO 26) = RTYPE THEN
            -- Both operands can refer to the same value
            IF ID_EXE_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                MEM_WB_ResNeeded_A := '1';

            END IF;
            
            IF ID_EXE_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                MEM_WB_ResNeeded_B := '1';

            END IF;

        -- Current is an R-type instructions while the next is an I-type instruction: the current has to check for each operand if there's a matching to the destination
        ELSIF ID_EXE_Instruction(31 DOWNTO 26) = RTYPE AND MEM_WB_NoJMP = '1' THEN
            -- Both operands can refer to the same value
            IF ID_EXE_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                MEM_WB_ResNeeded_A := '1';

            END IF;
            
            IF ID_EXE_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                MEM_WB_ResNeeded_B := '1';

            END IF;

        -- If it is an I-type instruction: need only to check RS
        -- Only in A can be forwarded the data from the successor stages
        ELSIF ID_EXE_NoJMP = '1' AND MEM_WB_Instruction(31 DOWNTO 26) = RTYPE THEN
            IF ID_EXE_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(15 DOWNTO 11) THEN
                MEM_WB_ResNeeded_A := '1'; 
            END IF;
        
        -- Both instruction are of I-type: need only to check RS
        -- Only in A can be forwarded the data from the successor stages
        ELSIF ID_EXE_NoJMP = '1' AND MEM_WB_NoJMP = '1' THEN
            IF ID_EXE_Instruction(25 DOWNTO 21) = MEM_WB_Instruction(20 DOWNTO 16) THEN
                MEM_WB_ResNeeded_A := '1'; 
            END IF;

        END IF;

        -- Third forwarding check 
        -- Is there a store operation that requires previously computed data to forward inside the execution stage?

        IF ID_EXE_Instruction(31 DOWNTO 26) = ITYPE_SW THEN
            IF (EXE_MEM_Instruction(31 DOWNTO 26) = RTYPE AND ID_EXE_Instruction(20 DOWNTO 16) = EXE_MEM_Instruction(15 DOWNTO 11)) OR 
               (EXE_MEM_NoJMP = '1' AND ID_EXE_Instruction(20 DOWNTO 16) = EXE_MEM_Instruction(20 DOWNTO 16)) THEN

                SW_FORW_EXE := '1';
            END IF;

            IF (MEM_WB_Instruction(31 DOWNTO 26) = RTYPE AND ID_EXE_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(15 DOWNTO 11)) OR 
               (MEM_WB_NoJMP = '1' AND ID_EXE_Instruction(20 DOWNTO 16) = MEM_WB_Instruction(20 DOWNTO 16)) THEN
               
                SW_FORW_MEM := '1';
            END IF;
        END IF;


        FW_A <= EX_MEM_ResNeeded_A & MEM_WB_ResNeeded_A;
        FW_B <= EX_MEM_ResNeeded_B & MEM_WB_ResNeeded_B;
        FW_MEM <= SW_FORW_EXE & SW_FORW_MEM;
    END PROCESS;

END BEHAVIOURAL;