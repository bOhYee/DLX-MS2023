LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DECODE_FW_UNIT IS 
    PORT(IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
         ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
         MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);

         IF_ID_IsBranch: OUT std_logic;
         ID_EXE_IsLoad: OUT std_logic;
         ID_EXE_HasDest: OUT std_logic;
         WB_HasDestA, WB_HasDestB: OUT std_logic);
END DECODE_FW_UNIT;

ARCHITECTURE STRUCTURAL OF DECODE_FW_UNIT IS

    SIGNAL IF_ID_IsR_s, IF_ID_IsI, IF_ID_IsJ_s: std_logic;
    SIGNAL MEM_WB_IsForwardable_s, WBIsR_s, WBIsI_s: std_logic;
    SIGNAL C2_out_s, C3_out_s, C4_out_s, C5_out_s, C6_out_s, C7_out_s, C8_out_s: std_logic;
    SIGNAL C9_out_s, C10_out_s, C11_out_s, C12_out_s, C13_out_s, C14_out_s, C15_out_s, C16_out_s, C17_out_s: std_logic;

    -- ID_EXE instruction has as destination one of the input operands of next instruction
    -- Two different signals for the two routes
    -- Combined through an OR gate to obtain final signal to output
    SIGNAL ID_EXE_HasDest_RTYPE_s, ID_EXE_HasDest_JTYPE_s: std_logic;

    -- Two different signals for the two routes of every WBHasDest signal for better comprehension
    SIGNAL WB_HasDestA_1511_s, WB_HasDestA_2016_s: std_logic;
    SIGNAL WB_HasDestB_1511_s, WB_HasDestB_2016_s: std_logic;

    -- For OPCODE comparisons
    COMPONENT IR_COMPARATOR IS 
        PORT(A, B: IN std_logic_vector(5 DOWNTO 0);
             AreEqual: OUT std_logic);
    END COMPONENT;
    
    -- For register comparisons
    COMPONENT REG_COMPARATOR IS 
        PORT(A, B: IN std_logic_vector(4 DOWNTO 0);
             AreEqual: OUT std_logic);
    END COMPONENT;

BEGIN

    -- ID_EXE instruction is a load instruction
    C0: IR_COMPARATOR PORT MAP (A => ID_EXE_Instruction(31 DOWNTO 26), B => ITYPE_LOAD, AreEqual => ID_EXE_IsLoad);

    C1: IR_COMPARATOR PORT MAP (A => IF_ID_Instruction(31 DOWNTO 26), B => RTYPE, AreEqual => IF_ID_IsR_s);

    C2: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(25 DOWNTO 21), B => ID_EXE_Instruction(20 DOWNTO 16), AreEqual => C2_out_s);

    C3: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(20 DOWNTO 16), B => ID_EXE_Instruction(20 DOWNTO 16), AreEqual => C3_out_s);

    C4: IR_COMPARATOR PORT MAP (A => IF_ID_Instruction(31 DOWNTO 26), B => JTYPE_J, AreEqual => C4_out_s);

    C5: IR_COMPARATOR PORT MAP (A => IF_ID_Instruction(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => C5_out_s);

    -- ID_EXE instruction has as destination one of the input operands of next instruction
    IF_ID_IsJ_s <= C4_out_s OR C5_out_s;
    IF_ID_IsI <= NOT(IF_ID_IsJ_s) AND NOT(IF_ID_IsR_s);
    ID_EXE_HasDest_JTYPE_s <= IF_ID_IsI AND C2_out_s;
    ID_EXE_HasDest_RTYPE_s <= (C2_out_s OR C3_out_s) AND IF_ID_IsR_s;
    ID_EXE_HasDest <= ID_EXE_HasDest_RTYPE_s OR ID_EXE_HasDest_JTYPE_s;

    C6: IR_COMPARATOR PORT MAP (A => IF_ID_Instruction(31 DOWNTO 26), B => ITYPE_BEQZ, AreEqual => C6_out_s);

    C7: IR_COMPARATOR PORT MAP (A => IF_ID_Instruction(31 DOWNTO 26), B => ITYPE_BNEZ, AreEqual => C7_out_s);

    -- IF_ID instruction is a branch instruction? Do we need to prepare for resetting in case of wrong prediction?
    IF_ID_IsBranch <= ((C6_out_s OR C7_out_s) AND IF_ID_IsI) OR (NOT(IF_ID_IsR_s) AND IF_ID_IsJ_s);

    -- Write back instruction analysis
    C8: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => ITYPE_BEQZ, AreEqual => C8_out_s);

    C9: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => ITYPE_BNEZ, AreEqual => C9_out_s);

    C10: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => ITYPE_SW, AreEqual => C10_out_s);

    C11: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => JTYPE_J, AreEqual => C11_out_s);

    C12: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => C12_out_s);

    C13: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => RTYPE, AreEqual => C13_out_s);

    MEM_WB_IsForwardable_s <= NOT(((C8_out_s OR C9_out_s) OR (C10_out_s OR C11_out_s)) OR C12_out_s);
    WBIsR_s <= MEM_WB_IsForwardable_s AND C13_out_s;
    WBIsI_s <= MEM_WB_IsForwardable_s AND NOT(C13_out_s);

    C14: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(25 DOWNTO 21), B => MEM_WB_Instruction(15 DOWNTO 11), AreEqual => C14_out_s);

    C15: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(25 DOWNTO 21), B => MEM_WB_Instruction(20 DOWNTO 16), AreEqual => C15_out_s);

    C16: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(20 DOWNTO 16), B => MEM_WB_Instruction(15 DOWNTO 11), AreEqual => C16_out_s);

    C17: REG_COMPARATOR PORT MAP (A => IF_ID_Instruction(20 DOWNTO 16), B => MEM_WB_Instruction(20 DOWNTO 16), AreEqual => C17_out_s);
    
    -- Can we forward the result of WB into the A operand?
    WB_HasDestA_1511_s <= (NOT(IF_ID_IsJ_s) OR IF_ID_IsR_s) AND C14_out_s AND WBIsR_s;
    WB_HasDestA_2016_s <= (NOT(IF_ID_IsJ_s) OR IF_ID_IsR_s) AND C15_out_s AND WBIsI_s;
    WB_HasDestA <= WB_HasDestA_1511_s OR WB_HasDestA_2016_s;

    -- Can we forward the result of WB into the B operand?
    WB_HasDestB_1511_s <= IF_ID_IsR_s AND C16_out_s AND WBIsR_s;
    WB_HasDestB_2016_s <= IF_ID_IsR_s AND C17_out_s AND WBIsI_s;
    WB_HasDestB <= WB_HasDestB_1511_s OR WB_HasDestB_2016_s;

END STRUCTURAL;