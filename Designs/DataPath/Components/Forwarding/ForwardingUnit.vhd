LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY FORWARDING_UNIT IS 
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
END FORWARDING_UNIT;

ARCHITECTURE STRUCTURAL OF FORWARDING_UNIT IS

    COMPONENT DECODE_FW_UNIT IS
        PORT(IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
             ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
             MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
 
             IF_ID_IsBranch: OUT std_logic;
             ID_EXE_IsLoad: OUT std_logic;
             ID_EXE_HasDest: OUT std_logic;
             WB_HasDestA, WB_HasDestB: OUT std_logic);
    END COMPONENT;

    COMPONENT EXECUTION_FW_UNIT IS 
        PORT(ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
             EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
             MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
 
             FW_A, FW_B, FW_MEM: OUT std_logic_vector(1 DOWNTO 0));
    END COMPONENT;

BEGIN

    -- Decode stage forwarding flags
    ID_STAGE: DECODE_FW_UNIT PORT MAP (IF_ID_Instruction => IF_ID_Instruction, 
                                       ID_EXE_Instruction => ID_EXE_Instruction,
                                       MEM_WB_Instruction => MEM_WB_Instruction,
                                       
                                       IF_ID_IsBranch => IF_ID_IsBranch, ID_EXE_IsLoad => ID_EXE_IsLoad, ID_EXE_HasDest => ID_EXE_HasDest,
                                       WB_HasDestA => WB_HasDestA, WB_HasDestB => WB_HasDestB);

    -- Execution stage forwarding flags
    EXE_STAGE: EXECUTION_FW_UNIT PORT MAP (ID_EXE_Instruction => ID_EXE_Instruction, 
                                           EXE_MEM_Instruction => EXE_MEM_Instruction,
                                           MEM_WB_Instruction => MEM_WB_Instruction,

                                           FW_A => FW_A, FW_B => FW_B, FW_MEM => FW_MEM);              

END STRUCTURAL;