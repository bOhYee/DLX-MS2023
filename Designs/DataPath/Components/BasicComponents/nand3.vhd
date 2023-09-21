LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY NAND3_GENERIC IS
    GENERIC(N: integer:= NumBit);
    
	PORT(A, B, C: IN std_logic_vector(N-1 DOWNTO 0);
		 Y: OUT std_logic_vector(N-1 DOWNTO 0));
END NAND3_GENERIC;

ARCHITECTURE Structural OF NAND3_GENERIC IS 

    COMPONENT IV_GENERIC IS
	   GENERIC(NBIT: integer := NumBit);

        PORT(A:	IN std_logic_vector(N-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT ND_GENERIC IS
	   GENERIC(NBIT: integer := NumBit);

        PORT(A, B: IN std_logic_vector(N-1 DOWNTO 0);
             Y: OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;

    SIGNAL D, E : std_logic_vector(N-1 DOWNTO 0);

BEGIN 

    NAND0: ND_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => A, B => B, Y => D);
    IV0: IV_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => D, Y => E);
    NAND1: ND_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => E, B => C, Y => Y);
    
END Structural;