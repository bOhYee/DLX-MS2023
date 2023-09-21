LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DLX_CU IS
    PORT(clock, reset: IN std_logic;
    
         -- Fetch stage
         S_PC_in: OUT std_logic;
         IR_Ready: IN std_logic; 
         IR_Enable: OUT std_logic;
         EN_setNOP_Fetch: OUT std_logic;
         EN_Fetch: OUT std_logic;
         
         -- Decod stage
         IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
         IF_ID_IsBranch: IN std_logic;
         ID_EXE_IsLoad: IN std_logic;
         ID_EXE_HasDest: IN std_logic;
         WB_HasDestA, WB_HasDestB: IN std_logic;
         Branch_cnt_over: IN std_logic;
         EN_RF_PORT1, EN_RF_PORT2: OUT std_logic;
         S_SEL_A, S_SEL_B, S_SIGN_EXT_OPTYPE, S_IMM: OUT std_logic;
         Branch_cnt_reset, Branch_cnt_en: OUT std_logic;
         EN_setNOP_Decod: OUT std_logic;
         EN_Decod: OUT std_logic;
         
         -- Execution stage
         ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
         FW_A, FW_B: IN std_logic_vector(1 DOWNTO 0);
         DIV_cnt_over: IN std_logic;
         S_MUX_P1, S_MUX_P2, S_MUX_ZERO: OUT std_logic_vector(1 DOWNTO 0);
         S_ALU_Op: OUT std_logic_vector(EXE_WIDTH_ALU-1 DOWNTO 0);
         DIV_cnt_reset, DIV_cnt_en: OUT std_logic;
         EN_setNOP_Exe: OUT std_logic;
         EN_Exe: OUT std_logic;
         
         -- Memory stage
         EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
         EN_Memory: OUT std_logic;
         EN_setNOP_MEM: OUT std_logic;
         DMEM_Ready: IN std_logic;
         S_MuxDOUT: OUT std_logic;
         DMEM_RW, DMEM_Enable: OUT std_logic;
         
         -- Write back stage
         MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
         EN_RF_WPORT: OUT std_logic         
    );         
END DLX_CU;

ARCHITECTURE Behavioral OF DLX_CU IS

    -- Fetch stage (IF)
    TYPE IFState IS (WRITE_INSTR, DECOD_WAIT, MEM_WAIT);
    SIGNAL CurrIFState, NextIFState: IFState;

    -- Decod stage (ID)
    SIGNAL ID_Stall: std_logic;
    TYPE IDState IS (RECOVER, EXECUTION_STALL, FORWARDING_STALL, BRANCH_STALL); 
    SIGNAL CurrIDState, NextIDState: IDState;
    SIGNAL NextID: std_logic_vector(DECOD_WIDTH-1 DOWNTO 0);
    
    -- Execution stage (EXE)
    SIGNAL EXE_Stall: std_logic;
    TYPE EXEState IS (COMPUTE_DATA, DIV_STALL, MEM_WAIT);
    SIGNAL CurrEXEState, NextEXEState: EXEState;
    SIGNAL NextEXE: std_logic_vector(EXE_WIDTH-1 DOWNTO 0);

    -- Memory stage (MEM)
    SIGNAL MEM_Stall: std_logic;
    TYPE MEMState IS (FORWARD_DATA, MEM_DATA);
    SIGNAL CurrMEMState, NextMEMState: MEMState;
    SIGNAL NextMEM: std_logic_vector(MEM_WIDTH-1 DOWNTO 0);

BEGIN

    -- Save all new contents inside the registers every rising edge of the clock
    -- Or reset their content if the reset signal is HIGH
    RegProc: PROCESS(clock, reset)
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '1' THEN
                CurrIFState <= WRITE_INSTR;
                CurrIDState <= RECOVER;
                CurrEXEState <= COMPUTE_DATA;
                CurrMEMState <= FORWARD_DATA;
            ELSE
                CurrIFState <= NextIFState;
                CurrIDState <= NextIDState;
                CurrEXEState <= NextEXEState;
                CurrMEMState <= NextMEMState;
            END IF;
        END IF;
    END PROCESS;

    -- Fetch stage FSM
    IFProc: PROCESS(CurrIFState, IR_Ready, ID_Stall)
    BEGIN
        -- Instrucion memory always enabled for read operations
        -- PC doesn't have to change when a stall arises though
        IR_Enable <= '1';

        CASE CurrIFState IS
            -- Activate the registers in order to proceed with the next instruction during the ID phase
            WHEN WRITE_INSTR => 
                IF ID_Stall = '1' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= DECOD_WAIT;
                ELSIF IR_Ready = '0' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '1';
                    NextIFState <= MEM_WAIT;
                ELSE
                    EN_Fetch <= '1';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= WRITE_INSTR;
                END IF;

            -- We wait until the instruction memory produce the intended instruction or until the stall
            -- has been managed
            WHEN MEM_WAIT =>
                IF ID_Stall = '1' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= DECOD_WAIT;
                ELSIF IR_Ready = '0' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '1';
                    NextIFState <= MEM_WAIT;
                ELSE
                    EN_Fetch <= '1';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= WRITE_INSTR;
                END IF;
            
            -- We wait until the decod stage manage its stall
            WHEN DECOD_WAIT =>
                IF ID_Stall = '1' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= DECOD_WAIT;
                ELSIF IR_Ready = '0' THEN
                    EN_Fetch <= '0';
                    EN_setNOP_Fetch <= '1';
                    NextIFState <= MEM_WAIT;
                ELSE
                    EN_Fetch <= '1';
                    EN_setNOP_Fetch <= '0';
                    NextIFState <= WRITE_INSTR;
                END IF;

            WHEN OTHERS =>
                -- When state received is an UNSAFE state, return to WRITE
                EN_Fetch <= '1';
                EN_setNOP_Fetch <= '0';
                NextIFState <= WRITE_INSTR;
        END CASE;
    END PROCESS;

    -- Decode stage FSM
    IDProc: PROCESS(CurrIDState, IF_ID_Instruction, IF_ID_IsBranch, ID_EXE_IsLoad, ID_EXE_HasDest, WB_HasDestA, WB_HasDestB, EXE_Stall, DMEM_Ready, Branch_cnt_over)
    VARIABLE DecSignals: std_logic_vector(DECOD_WIDTH-1 DOWNTO 0);
    BEGIN
        -- Computation of CW signals to send to the datapath
        CASE IF_ID_Instruction(31 DOWNTO 26) IS
            -- Need to recover the content of the destination register for a store operation
            WHEN RTYPE | ITYPE_SW =>
                DecSignals := DEC_RTYPE;

            WHEN JTYPE_J | JTYPE_JAL =>
                DecSignals := DEC_JTYPE;

            -- These operations do not sign-extend the immediate field
            WHEN ITYPE_ADDUI | ITYPE_SUBUI | 
                 ITYPE_SGEUI | ITYPE_SLEUI | ITYPE_SLTUI | ITYPE_SGTUI |
                 ITYPE_ANDI | ITYPE_NANDI | ITYPE_ORI | ITYPE_NORI | ITYPE_XORI | ITYPE_XNORI =>
                DecSignals := DEC_ITYPE_USIGN;

            WHEN OTHERS =>
                DecSignals := DEC_ITYPE;
        END CASE;

        -- Assign signals (Enable of registers is done during switch of state since it is critical for managing hazards)
        EN_RF_PORT1 <= DecSignals(DECOD_WIDTH-1);
        EN_RF_PORT2 <= DecSignals(DECOD_WIDTH-2);
        S_SEL_A <= DecSignals(DECOD_WIDTH-3) OR WB_HasDestA;
        S_SEL_B <= DecSignals(DECOD_WIDTH-4) OR WB_HasDestB;
        S_SIGN_EXT_OPTYPE <= DecSignals(DECOD_WIDTH-5);
        S_IMM <= DecSignals(DECOD_WIDTH-6);

        -- Only moment when it's assigned to '1' is when we exit from the BRANCH_STALL state
        S_PC_in <= '0'; 

        -- Branch counter management
        -- Only managed during BRANCH_STALL state, every other time they need to be configured like this
        Branch_cnt_reset <= '1';
        Branch_cnt_en <= '0';

        CASE CurrIDState IS
             -- State when the execution unit is stalling or it's taking a long time to complete its operations
            WHEN EXECUTION_STALL =>
                IF EXE_Stall = '1' THEN
                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= EXECUTION_STALL;
                ELSIF EXE_Stall = '0' AND (ID_EXE_IsLoad = '0' OR (ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '0')) AND IF_ID_IsBranch = '1' THEN
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= BRANCH_STALL;
                ELSIF EXE_Stall = '0' AND ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '1' THEN
                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '1';
                    NextIDState <= FORWARDING_STALL;
                ELSE
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= RECOVER;
                END IF;

            -- State when we know that the forwarding won't be useful until the next operation is in the memory stage
            -- in order for data to be better moved and used
            WHEN FORWARDING_STALL =>
                IF DMEM_Ready = '0' THEN
                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '1';
                    NextIDState <= FORWARDING_STALL;
                ELSIF DMEM_Ready = '1' AND IF_ID_IsBranch = '0' THEN
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= RECOVER;
                ELSE
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= BRANCH_STALL;
                END IF;

            -- State reached when a branch instruction has been encountered 
            -- Cycle for as many NOP cycles we need during our wait for the next regular instruction
            WHEN BRANCH_STALL => 
                -- Activate the down counter
                Branch_cnt_reset <= '0';
                Branch_cnt_en <= '1';
                ID_Stall <= '0';
                EN_Decod <= '1';
                EN_setNOP_Decod <= '0';

                IF Branch_cnt_over = '1' AND ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '1' THEN
                    S_PC_in <= '1';

                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '1';
                    NextIDState <= FORWARDING_STALL;

                ELSIF Branch_cnt_over = '1' AND (ID_EXE_IsLoad = '0' OR (ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '0')) AND IF_ID_IsBranch = '1' THEN
                    S_PC_in <= '1';
                    Branch_cnt_reset <= '1';
                    NextIDState <= BRANCH_STALL;

                ELSIF Branch_cnt_over = '1' AND (ID_EXE_IsLoad = '0' OR (ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '0')) AND IF_ID_IsBranch = '0' THEN
                    S_PC_in <= '1';
                    NextIDState <= RECOVER;

                ELSIF Branch_cnt_over = '0' THEN
                    S_PC_in <= '0';
                    NextIDState <= BRANCH_STALL;
                END IF;

            -- Normal stage for decoding 
            -- We decode the instruction and set the signals accordingly
            WHEN RECOVER =>
                IF EXE_Stall = '1' THEN
                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= EXECUTION_STALL;
                ELSIF ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '1' AND EXE_Stall = '0' THEN
                    ID_Stall <= '1';
                    EN_Decod <= '0';
                    EN_setNOP_Decod <= '1';
                    NextIDState <= FORWARDING_STALL;
                ELSIF EXE_Stall = '0' AND (ID_EXE_IsLoad = '0' OR (ID_EXE_IsLoad = '1' AND ID_EXE_HasDest = '0')) AND IF_ID_IsBranch = '1' THEN
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= BRANCH_STALL;
                ELSE
                    ID_Stall <= '0';
                    EN_Decod <= '1';
                    EN_setNOP_Decod <= '0';
                    NextIDState <= RECOVER;
                END IF;

            -- When state is UNSAFE, suppose it goes towards a RECOVER state
            WHEN OTHERS =>
                ID_Stall <= '0';
                EN_Decod <= '1';
                EN_setNOP_Decod <= '0';
                NextIDState <= EXECUTION_STALL;
        END CASE;
    END PROCESS;

    -- Execution stage FSM
    EXEProc: PROCESS(CurrEXEState, ID_EXE_Instruction, FW_A, FW_B, MEM_Stall, DIV_cnt_over)
    VARIABLE ExeSignals: std_logic_vector(EXE_WIDTH-1 DOWNTO 0);
    VARIABLE IsDiv: std_logic;
    BEGIN
        ExeSignals := (OTHERS => '0');
        IsDiv := '0';
        
        -- Division counter management
        -- If no memory stall has been signaled by the MEM stage, check if a DIV has to be performed
        IF (ID_EXE_Instruction(31 DOWNTO 26) = RTYPE AND ID_EXE_Instruction(10 DOWNTO 0) = RTYPE_DIV) OR 
            ID_EXE_Instruction(31 DOWNTO 26) = ITYPE_DIV THEN

            IsDiv := '1';
        END IF;

        -- Only managed during DIV_STALL state, every other time they need to be configured like this
        DIV_cnt_reset <= '1';
        DIV_cnt_en <= '0';

        -- Evaluate signals to send to EXE stage
        CASE ID_EXE_Instruction(31 DOWNTO 26) IS
            WHEN RTYPE =>
                CASE ID_EXE_Instruction(10 DOWNTO 0) IS
                    WHEN RTYPE_ADD    => ExeSignals := EXE_RTYPE & EXE_ADD;
                    WHEN RTYPE_ADDU   => ExeSignals := EXE_RTYPE & EXE_ADD;
                    WHEN RTYPE_SUB    => ExeSignals := EXE_RTYPE & EXE_SUB;
                    WHEN RTYPE_SUBU   => ExeSignals := EXE_RTYPE & EXE_SUB;
                    WHEN RTYPE_AND    => ExeSignals := EXE_RTYPE & EXE_AND;
                    WHEN RTYPE_NAND   => ExeSignals := EXE_RTYPE & EXE_NAND;
                    WHEN RTYPE_OR     => ExeSignals := EXE_RTYPE & EXE_OR;
                    WHEN RTYPE_NOR    => ExeSignals := EXE_RTYPE & EXE_NOR;
                    WHEN RTYPE_XOR    => ExeSignals := EXE_RTYPE & EXE_XOR;
                    WHEN RTYPE_XNOR   => ExeSignals := EXE_RTYPE & EXE_XNOR;
                    WHEN RTYPE_SLL    => ExeSignals := EXE_RTYPE & EXE_SLL;
                    WHEN RTYPE_SRL    => ExeSignals := EXE_RTYPE & EXE_SRL;
                    WHEN RTYPE_SRA    => ExeSignals := EXE_RTYPE & EXE_SRA;
                    WHEN RTYPE_SGT    => ExeSignals := EXE_RTYPE & EXE_SGT;
                    WHEN RTYPE_SGTU   => ExeSignals := EXE_RTYPE & EXE_SGTU;
                    WHEN RTYPE_SEQ    => ExeSignals := EXE_RTYPE & EXE_SEQ;
                    WHEN RTYPE_SGE    => ExeSignals := EXE_RTYPE & EXE_SGE;
                    WHEN RTYPE_SGEU   => ExeSignals := EXE_RTYPE & EXE_SGEU;
                    WHEN RTYPE_SNE    => ExeSignals := EXE_RTYPE & EXE_SNE;
                    WHEN RTYPE_SLT    => ExeSignals := EXE_RTYPE & EXE_SLT;
                    WHEN RTYPE_SLTU   => ExeSignals := EXE_RTYPE & EXE_SLTU;
                    WHEN RTYPE_SLEU   => ExeSignals := EXE_RTYPE & EXE_SLEU;
                    WHEN RTYPE_SLE    => ExeSignals := EXE_RTYPE & EXE_SLE;
                    WHEN RTYPE_MULTLO => ExeSignals := EXE_RTYPE & EXE_MULTLO;
                    WHEN RTYPE_MULTHI => ExeSignals := EXE_RTYPE & EXE_MULTHI;
                    WHEN RTYPE_DIV    => ExeSignals := EXE_RTYPE & EXE_DIV;
                    WHEN OTHERS    => ExeSignals := EXE_ITYPE & EXE_NOP;  
                END CASE;

            WHEN ITYPE_ADDI    => ExeSignals := EXE_ITYPE & EXE_ADD;
            WHEN ITYPE_ADDUI   => ExeSignals := EXE_ITYPE & EXE_ADD;
            WHEN ITYPE_SUBI    => ExeSignals := EXE_ITYPE & EXE_SUB;
            WHEN ITYPE_SUBUI   => ExeSignals := EXE_ITYPE & EXE_SUB;
            WHEN ITYPE_ANDI    => ExeSignals := EXE_ITYPE & EXE_AND;
            WHEN ITYPE_NANDI   => ExeSignals := EXE_ITYPE & EXE_NAND;
            WHEN ITYPE_ORI     => ExeSignals := EXE_ITYPE & EXE_OR;
            WHEN ITYPE_NORI    => ExeSignals := EXE_ITYPE & EXE_NOR;
            WHEN ITYPE_XORI    => ExeSignals := EXE_ITYPE & EXE_XOR;
            WHEN ITYPE_XNORI   => ExeSignals := EXE_ITYPE & EXE_XNOR;
            WHEN ITYPE_NOP     => ExeSignals := EXE_ITYPE & EXE_NOP;
            WHEN ITYPE_LOAD    => ExeSignals := EXE_ITYPE & EXE_ADD;
            WHEN ITYPE_SW      => ExeSignals := EXE_ITYPE & EXE_ADD;
            WHEN ITYPE_SLLI    => ExeSignals := EXE_ITYPE & EXE_SLL;
            WHEN ITYPE_SRLI    => ExeSignals := EXE_ITYPE & EXE_SRL;
            WHEN ITYPE_SRAI    => ExeSignals := EXE_ITYPE & EXE_SRA;
            WHEN ITYPE_SGTI    => ExeSignals := EXE_ITYPE & EXE_SGT;
            WHEN ITYPE_SGTUI   => ExeSignals := EXE_ITYPE & EXE_SGTU;
            WHEN ITYPE_SEQI    => ExeSignals := EXE_ITYPE & EXE_SEQ;
            WHEN ITYPE_SGEI    => ExeSignals := EXE_ITYPE & EXE_SGE;
            WHEN ITYPE_SGEUI   => ExeSignals := EXE_ITYPE & EXE_SGEU;
            WHEN ITYPE_SNEI    => ExeSignals := EXE_ITYPE & EXE_SNE;
            WHEN ITYPE_SLTI    => ExeSignals := EXE_ITYPE & EXE_SLT;
            WHEN ITYPE_SLTUI   => ExeSignals := EXE_ITYPE & EXE_SLTU;
            WHEN ITYPE_SLEI    => ExeSignals := EXE_ITYPE & EXE_SLE;
            WHEN ITYPE_SLEUI   => ExeSignals := EXE_ITYPE & EXE_SLEU;
            WHEN ITYPE_MULTLOI => ExeSignals := EXE_ITYPE & EXE_MULTLO;
            WHEN ITYPE_MULTHII => ExeSignals := EXE_ITYPE & EXE_MULTHI;
            WHEN ITYPE_DIV     => ExeSignals := EXE_ITYPE & EXE_DIV;

            -- JTYPE since they need to read NPC (PC+4) field to create the right address to access
            WHEN ITYPE_BEQZ => ExeSignals := EXE_JTYPE & EXE_ADD;
            WHEN ITYPE_BNEZ => ExeSignals := EXE_JTYPE & EXE_ADD;
            WHEN JTYPE_J    => ExeSignals := EXE_JTYPE & EXE_ADD;
            WHEN JTYPE_JAL  => ExeSignals := EXE_JTYPE & EXE_ADD;        

            -- When error => NOP
            WHEN OTHERS    => ExeSignals := EXE_ITYPE & EXE_NOP;        
        END CASE;

        -- Apply FORWARDING
        CASE ID_EXE_Instruction(31 DOWNTO 26) IS
            -- In this case the A mux needs to transport NPC to the ALU
            -- The value that needs to change is the one that goes to zero comparator block
            WHEN ITYPE_BEQZ | ITYPE_BNEZ =>
                CASE FW_A IS
                    WHEN "01" => ExeSignals(EXE_WIDTH-5 DOWNTO EXE_WIDTH-6) := "00";
                    WHEN "10" | "11" => ExeSignals(EXE_WIDTH-5 DOWNTO EXE_WIDTH-6) := "01";
                    WHEN OTHERS => ExeSignals(EXE_WIDTH-5 DOWNTO EXE_WIDTH-6) := ExeSignals(EXE_WIDTH-5 DOWNTO EXE_WIDTH-6);
                END CASE;

            WHEN OTHERS =>
                CASE FW_A IS
                    WHEN "01" => ExeSignals(EXE_WIDTH-1 DOWNTO EXE_WIDTH-2) := "00";
                    WHEN "10" | "11" => ExeSignals(EXE_WIDTH-1 DOWNTO EXE_WIDTH-2) := "01";
                    WHEN OTHERS => ExeSignals(EXE_WIDTH-1 DOWNTO EXE_WIDTH-2) := ExeSignals(EXE_WIDTH-1 DOWNTO EXE_WIDTH-2);
                END CASE;
        END CASE;

        CASE FW_B IS
            WHEN "01" => ExeSignals(EXE_WIDTH-3 DOWNTO EXE_WIDTH-4) := "00";
            WHEN "10" | "11" => ExeSignals(EXE_WIDTH-3 DOWNTO EXE_WIDTH-4) := "01";
            WHEN OTHERS => ExeSignals(EXE_WIDTH-3 DOWNTO EXE_WIDTH-4) := ExeSignals(EXE_WIDTH-3 DOWNTO EXE_WIDTH-4);
        END CASE;

        -- Assign signals
        S_MUX_P1 <= ExeSignals(EXE_WIDTH-1 DOWNTO EXE_WIDTH-2);
        S_MUX_P2 <= ExeSignals(EXE_WIDTH-3 DOWNTO EXE_WIDTH-4);
        S_MUX_ZERO <= ExeSignals(EXE_WIDTH-5 DOWNTO EXE_WIDTH-6);
        S_ALU_Op <= ExeSignals(EXE_WIDTH_ALU-1 DOWNTO 0);

        -- Actual FSM
        CASE CurrEXEState IS
            -- State where the ALU computes its operations like normal
            WHEN COMPUTE_DATA =>
                IF MEM_Stall = '0' AND IsDiv = '0' THEN
                    EXE_Stall <= '0';
                    EN_setNOP_Exe <= '0';
                    EN_Exe <= '1';
                    NextEXEState <= COMPUTE_DATA;
                ELSIF MEM_Stall = '0' AND IsDiv = '1' THEN
                    EXE_Stall <= '1';
                    EN_setNOP_Exe <= '1';
                    EN_Exe <= '0';
                    NextEXEState <= DIV_STALL;
                ELSIF MEM_Stall = '1' THEN                    
                    EXE_Stall <= '1';
                    EN_setNOP_Exe <= '0';
                    EN_Exe <= '0';
                    NextEXEState <= MEM_WAIT;
                END IF;
            
            -- State for waiting the division to complete since it takes more than one clock cycle
            -- to produce the result
            WHEN DIV_STALL =>
                -- Activate the down counter
                DIV_cnt_reset <= '0';
                DIV_cnt_en <= '1';

                IF DIV_cnt_over = '1' THEN
                    EXE_Stall <= '0';
                    EN_Exe <= '1';
                    EN_setNOP_Exe <= '0';
                    NextEXEState <= COMPUTE_DATA;
                ELSE
                    EXE_Stall <= '1';
                    EN_Exe <= '1';
                    EN_setNOP_Exe <= '1';
                    NextEXEState <= DIV_STALL;
                END IF;

            -- State where the ALU has to wait for the operation in the MEM stage to complete
            -- (e.g. the memory requires many clock cycles to complete a load or a store operation)
            WHEN MEM_WAIT =>
                IF MEM_Stall = '1' THEN
                    EXE_Stall <= '1';
                    EN_Exe <= '0';
                    EN_setNOP_Exe <= '0';
                    NextEXEState <= MEM_WAIT;    
                ELSIF MEM_Stall = '0' AND IsDiv = '1' THEN
                    EXE_Stall <= '1';
                    EN_setNOP_Exe <= '1';
                    EN_Exe <= '0';
                    NextEXEState <= DIV_STALL;
                ELSIF MEM_Stall = '0' THEN
                    EXE_Stall <= '0';
                    EN_Exe <= '1';
                    EN_setNOP_Exe <= '0';
                    NextEXEState <= COMPUTE_DATA;
                END IF;

            -- When state is UNSAFE, suppose it goes towards a COMPUTE_DATA state
            WHEN OTHERS =>
                EXE_Stall <= '0';
                EN_Exe <= '1';
                EN_setNOP_Exe <= '0';
                NextEXEState <= COMPUTE_DATA;

        END CASE;
    END PROCESS;

    -- Memory stage FSM
    MEMProc: PROCESS(CurrMEMState, EXE_MEM_Instruction, DMEM_Ready)
    VARIABLE IsMemRel: std_logic;
    VARIABLE CWSignals: std_logic_vector(MEM_WIDTH-1 DOWNTO 0);
    BEGIN
        IsMemRel := '0';

        -- Check if the instruction in the EXE/MEM buffer is a load or a store operation
        IF ((EXE_MEM_Instruction(31 DOWNTO 26) = ITYPE_LOAD) OR (EXE_MEM_Instruction(31 DOWNTO 26) = ITYPE_SW)) THEN
            IsMemRel := '1';
        END IF;

        -- Control signals
        CASE EXE_MEM_Instruction(31 DOWNTO 26) IS
            WHEN ITYPE_LOAD => 
                CWSignals := MEM_ITYPE_LOAD;
            
            WHEN ITYPE_SW =>
                CWSignals := MEM_ITYPE_SW;
            
            WHEN OTHERS =>
                CWSignals := MEM_OTHERS;
        END CASE;

        DMEM_RW <= CWSignals(MEM_WIDTH-1);
        DMEM_Enable <= CWSignals(MEM_WIDTH-2);
        S_MuxDOUT <= CWSignals(MEM_WIDTH-3);

        -- Actual FSM
        CASE CurrMEMState IS
            -- State related to instructions that do not access the memory to perform
            -- a load or a store
            WHEN FORWARD_DATA =>
                IF IsMemRel = '0' OR (IsMemRel = '1' AND DMEM_Ready = '1') THEN
                    MEM_Stall <= '0';
                    EN_Memory <= '1';
                    EN_setNOP_MEM <= '0';
                    NextMEMState <= FORWARD_DATA;
                ELSIF IsMemRel = '1' AND DMEM_Ready = '0' THEN
                    MEM_Stall <= '1';
                    EN_Memory <= '0';
                    EN_setNOP_MEM <= '1';
                    NextMEMState <= MEM_DATA;
                END IF;

            -- State related to access to memory
            WHEN MEM_DATA =>
                IF DMEM_Ready = '0' THEN
                    MEM_Stall <= '1';
                    EN_Memory <= '0';
                    EN_setNOP_MEM <= '1';
                    NextMEMState <= MEM_DATA;
                ELSE
                    MEM_Stall <= '0';
                    EN_Memory <= '1';
                    EN_setNOP_MEM <= '0';
                    NextMEMState <= FORWARD_DATA;
                END IF;

            WHEN OTHERS =>
                MEM_Stall <= '0';
                EN_Memory <= '1';
                EN_setNOP_MEM <= '0';
                NextMEMState <= FORWARD_DATA;

        END CASE;
    END PROCESS;

    -- Write back stage
    WBProc: PROCESS(MEM_WB_Instruction) 
    VARIABLE CWSignals: std_logic_vector(WB_WIDTH-1 DOWNTO 0);
    BEGIN
        CASE MEM_WB_Instruction(31 DOWNTO 26) IS
            WHEN ITYPE_BEQZ |
                 ITYPE_BNEZ |
                 ITYPE_SW   |
                 ITYPE_NOP  |
                 JTYPE_J => 
                CWSignals := WB_NOT_SAVE;

            WHEN OTHERS => 
                CWSignals := WB_SAVE;
        END CASE;

        EN_RF_WPORT <= CWSignals(WB_WIDTH-1);
    END PROCESS;

END Behavioral;