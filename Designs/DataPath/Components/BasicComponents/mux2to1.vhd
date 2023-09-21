LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY MUX21_GENERIC IS
	GENERIC(NBIT: integer:= NumBit);

	PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
		 SEL: IN std_logic;
		 Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
END MUX21_GENERIC;

ARCHITECTURE STRUCTURAL OF MUX21_GENERIC IS 

	SIGNAL SelExtended, SelInverted, Y0, Y1: std_logic_vector(NBIT-1 DOWNTO 0);

	COMPONENT IV_GENERIC 
		GENERIC(NBIT: integer := NumBit);

		PORT(A:	IN std_logic_vector(NBIT-1 DOWNTO 0);
			Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT ND_GENERIC
		GENERIC(NBIT: integer := NumBit);

		PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
			Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

BEGIN

    -- Need to extend the selection signal in order to perform the 32-bit logic operation (NOT, NAND)
    SelProc: PROCESS(SEL)
        VARIABLE temp : std_logic_vector(NBIT-1 DOWNTO 0);
        BEGIN 
            temp := (OTHERS => SEL);
            SelExtended <= temp; 
    END PROCESS SelProc;
    
    UIV: IV_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => SelExtended, Y => SelInverted);
    UND0: ND_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => A, B => SelExtended, Y => Y0);
    UND1: ND_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => B, B => SelInverted, Y => Y1);
    UND2: ND_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => Y0, B => Y1, Y => Y);

END STRUCTURAL;