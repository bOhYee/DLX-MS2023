LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY COND IS
    PORT(ZEROS_OUT: IN std_logic;
		 IR: IN std_logic_vector (NumBit-1 DOWNTO 0);
         B: OUT std_logic);
END COND;

ARCHITECTURE STRUCTURAL OF COND IS

	SIGNAL AreEqual_BEQZ, AreEqual_BENZ, B_J, B_JAL, B_BEQZ, B_BNEZ : std_logic;

    COMPONENT IR_COMPARATOR IS 
        PORT(A, B: IN std_logic_vector(5 DOWNTO 0);
             AreEqual: OUT std_logic);
    END COMPONENT;

BEGIN
    
    B_BEQZ <= ( ZEROS_OUT AND AreEqual_BEQZ );
    B_BNEZ <= (( NOT ZEROS_OUT ) AND AreEqual_BENZ );

    B <= ( B_BEQZ OR B_BNEZ OR B_J OR B_JAL );

    IRcomparator_BEQZ : IR_COMPARATOR PORT MAP (A => IR(31 DOWNTO 26), B => ITYPE_BEQZ, AreEqual => AreEqual_BEQZ);
    IRcomparator_BNEZ : IR_COMPARATOR PORT MAP (A => IR(31 DOWNTO 26), B => ITYPE_BNEZ, AreEqual => AreEqual_BENZ);
    IRcomparator_JTYPE_J : IR_COMPARATOR PORT MAP (A => IR(31 DOWNTO 26), B => JTYPE_J, AreEqual => B_J);
    IRcomparator_JTYPE_JAL : IR_COMPARATOR PORT MAP (A => IR(31 DOWNTO 26), B => JTYPE_JAL, AreEqual => B_JAL);

END STRUCTURAL;