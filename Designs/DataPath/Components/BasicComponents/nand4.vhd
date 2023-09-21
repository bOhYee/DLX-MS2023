LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY NAND4_GENERIC IS
    GENERIC(N: integer:= NumBit);
    
	PORT(A, B, C, D: IN std_logic_vector(N-1 DOWNTO 0);
		 Y: OUT std_logic_vector(N-1 DOWNTO 0));
END NAND4_GENERIC;

ARCHITECTURE Structural OF NAND4_GENERIC IS 

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

    SIGNAL E, F, G, H : std_logic_vector(N-1 DOWNTO 0);

BEGIN 

    NAND0: ND_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => A, B => B, Y => E);
    NAND1: ND_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => C, B => D, Y => F);
    IV0: IV_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => E, Y => G);
    IV1: IV_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => F, Y => H);
    NAND2: ND_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => G, B => H, Y => Y);
    
END Structural;