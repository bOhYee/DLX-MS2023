LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY OUT_EXTRACTOR IS
    PORT(IR: IN std_logic_vector(31 DOWNTO 0);
         ADDR: OUT std_logic_vector(4 DOWNTO 0));
END OUT_EXTRACTOR;

ARCHITECTURE STRUCTURAL OF OUT_EXTRACTOR IS

    SIGNAL Sel : std_logic;

    COMPONENT IR_COMPARATOR IS 
        PORT(A, B: IN std_logic_vector(5 DOWNTO 0);
             AreEqual: OUT std_logic);
    END COMPONENT;
    
    COMPONENT MUX21_GENERIC IS
	   GENERIC(NBIT: integer:= NumBit);

	   PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
		    SEL: IN std_logic;
		    Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

BEGIN

    IR_Comparator_address : IR_COMPARATOR PORT MAP (A => IR(31 DOWNTO 31-(OP_CODE_SIZE-1)), B => RTYPE, AreEqual => Sel);    
    MUX21 : MUX21_GENERIC GENERIC MAP (NBIT => 5) PORT MAP (A => IR(15 DOWNTO 11), B => IR(20 DOWNTO 16), SEL => Sel, Y => ADDR);

END STRUCTURAL;