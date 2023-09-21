LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY EXECUTION_FW_UNIT IS 
    PORT(ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
         EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
         MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);

         FW_A, FW_B, FW_MEM: OUT std_logic_vector(1 DOWNTO 0));
END EXECUTION_FW_UNIT;

ARCHITECTURE STRUCTURAL OF EXECUTION_FW_UNIT IS

    SIGNAL ID_EXE_IsR, EXE_MEM_IsR, MEM_WB_IsR: std_logic;
    SIGNAL ID_EXE_NoJMP, EXE_MEM_NoJMP, MEM_WB_NoJMP: std_logic;

    SIGNAL cond_1_fw_1_s, cond_2_fw_1_s, cond_3_fw_1_s, cond_4_fw_1_s: std_logic;
    SIGNAL cond_1_fw_2_s, cond_2_fw_2_s, cond_3_fw_2_s, cond_4_fw_2_s: std_logic;
    SIGNAL FW_A1_EXE_1511_s, FW_A1_EXE_2016_s: std_logic;
    SIGNAL FW_A2_MEM_1511_s, FW_A2_MEM_2016_s: std_logic;

    SIGNAL C0_out_s, C1_out_s, C2_out_s, C3_out_s, C4_out_s, C5_out_s, C8_out_s: std_logic;
    SIGNAL C9_out_s, C10_out_s, C11_out_s, C13_out_s, C14_out_s, C15_out_s, C16_out_s, C17_out_s: std_logic;

    SIGNAL FW_MEM_EXE_s, FW_MEM_MEM_s: std_logic;

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

    C0: IR_COMPARATOR PORT MAP (A => ID_EXE_Instruction(31 DOWNTO 26), B => JTYPE_J, AreEqual => C0_out_s);

    C1: IR_COMPARATOR PORT MAP (A => ID_EXE_Instruction(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => C1_out_s);
    
    C2: IR_COMPARATOR PORT MAP (A => EXE_MEM_Instruction(31 DOWNTO 26), B => JTYPE_J, AreEqual => C2_out_s);

    C3: IR_COMPARATOR PORT MAP (A => EXE_MEM_Instruction(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => C3_out_s);
                      
    C4: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => JTYPE_J, AreEqual => C4_out_s);

    C5: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => C5_out_s);

    ID_EXE_NoJMP <= NOT(C0_out_s OR C1_out_s);
    EXE_MEM_NoJMP <= NOT(C2_out_s OR C3_out_s);
    MEM_WB_NoJMP <= NOT(C4_out_s OR C5_out_s);

    C6: IR_COMPARATOR PORT MAP (A => ID_EXE_Instruction(31 DOWNTO 26), B => RTYPE, AreEqual => ID_EXE_IsR);

    C7: IR_COMPARATOR PORT MAP (A => EXE_MEM_Instruction(31 DOWNTO 26), B => RTYPE, AreEqual => EXE_MEM_IsR);

    -- Conditions for the MSBs of FW_A and FW_B
    cond_1_fw_1_s <= ID_EXE_IsR AND EXE_MEM_IsR;
    cond_2_fw_1_s <= ID_EXE_IsR AND EXE_MEM_NoJMP AND NOT(cond_1_fw_1_s);
    cond_3_fw_1_s <= ID_EXE_NoJMP AND EXE_MEM_IsR AND NOT(cond_1_fw_1_s) AND NOT(cond_2_fw_1_s);
    cond_4_fw_1_s <= ID_EXE_NoJMP AND EXE_MEM_NoJMP AND NOT(cond_1_fw_1_s) AND NOT(cond_2_fw_1_s) AND NOT(cond_3_fw_1_s);

    C8: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(25 DOWNTO 21), B => EXE_MEM_Instruction(15 DOWNTO 11), AreEqual => C8_out_s);

    C9: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(25 DOWNTO 21), B => EXE_MEM_Instruction(20 DOWNTO 16), AreEqual => C9_out_s);

    FW_A1_EXE_1511_s <= (C8_out_s AND cond_1_fw_1_s) OR (C8_out_s AND cond_3_fw_1_s);
    FW_A1_EXE_2016_s <= (C9_out_s AND cond_2_fw_1_s) OR (C9_out_s AND cond_4_fw_1_s);
    FW_A(1) <= FW_A1_EXE_1511_s OR FW_A1_EXE_2016_s;

    C10: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(20 DOWNTO 16), B => EXE_MEM_Instruction(15 DOWNTO 11), AreEqual => C10_out_s);

    C11: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(20 DOWNTO 16), B => EXE_MEM_Instruction(20 DOWNTO 16), AreEqual => C11_out_s);

    FW_B(1) <= (C10_out_s AND cond_1_fw_1_s) OR (C11_out_s AND cond_2_fw_1_s);

    C12: IR_COMPARATOR PORT MAP (A => MEM_WB_Instruction(31 DOWNTO 26), B => RTYPE, AreEqual => MEM_WB_IsR);

    -- Conditions for the LSBs of FW_A and FW_B
    cond_1_fw_2_s <= ID_EXE_IsR AND MEM_WB_IsR;
    cond_2_fw_2_s <= ID_EXE_IsR AND MEM_WB_NoJMP AND NOT(cond_1_fw_2_s);
    cond_3_fw_2_s <= ID_EXE_NoJMP AND MEM_WB_IsR AND NOT(cond_1_fw_2_s) AND NOT(cond_2_fw_2_s);
    cond_4_fw_2_s <= ID_EXE_NoJMP AND MEM_WB_NoJMP AND NOT(cond_1_fw_2_s) AND NOT(cond_2_fw_2_s) AND NOT(cond_3_fw_2_s);

    C13: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(25 DOWNTO 21), B => MEM_WB_Instruction(15 DOWNTO 11), AreEqual => C13_out_s);

    C14: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(25 DOWNTO 21), B => MEM_WB_Instruction(20 DOWNTO 16), AreEqual => C14_out_s);
    
    FW_A2_MEM_1511_s <= (C13_out_s AND cond_1_fw_2_s) OR (C13_out_s AND cond_3_fw_2_s);
    FW_A2_MEM_2016_s <= (C14_out_s AND cond_2_fw_2_s) OR (C14_out_s AND cond_4_fw_2_s);
    FW_A(0) <= FW_A2_MEM_1511_s OR FW_A2_MEM_2016_s;

    C15: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(20 DOWNTO 16), B => MEM_WB_Instruction(15 DOWNTO 11), AreEqual => C15_out_s);

    C16: REG_COMPARATOR PORT MAP (A => ID_EXE_Instruction(20 DOWNTO 16), B => MEM_WB_Instruction(20 DOWNTO 16), AreEqual => C16_out_s);

    FW_B(0) <= (C15_out_s AND cond_1_fw_2_s) OR (C16_out_s AND cond_2_fw_2_s);

    -- Multiplexer for B during store operations
    C17: IR_COMPARATOR PORT MAP (A => ID_EXE_Instruction(31 DOWNTO 26), B => ITYPE_SW, AreEqual => C17_out_s);

    FW_MEM_EXE_s <= C17_out_s AND ((EXE_MEM_IsR AND C10_out_s) OR (EXE_MEM_NoJMP AND C11_out_s));
    FW_MEM_MEM_s <= C17_out_s AND ((MEM_WB_IsR AND C15_out_s) OR (MEM_WB_NoJMP AND C16_out_s));
    FW_MEM <= FW_MEM_EXE_s & FW_MEM_MEM_s;

END STRUCTURAL;