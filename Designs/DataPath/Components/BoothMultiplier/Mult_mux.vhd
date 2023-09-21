LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use WORK.GLOBALS.all;


ENTITY Mult_mux is
GENERIC (N_BIT : integer := NumBit);

	port (	A,B,C,D,E	: IN STD_LOGIC_VECTOR(N_BIT-1 DOWNTO 0);
	
				S				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);

				Y				: OUT STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0));

END Mult_mux;


ARCHITECTURE BEHAVIOURAL of Mult_muX is

    SIGNAL tempS: std_logic_vector(2 DOWNTO 0);
    
-- MUX 2 TO 1 COMPONENT
COMPONENT MUX21_GENERIC IS
	GENERIC(NBIT: integer:= NumBit);

	PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
	     SEL: IN std_logic;
		 Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
END COMPONENT;

	signal temp1, temp2, temp3: STD_LOGIC_VECTOR(N_BIT-1 DOWNTO 0);


-- mux 5 to 1 generation using 2 to 1 component

begin
    
    tempS <= NOT(S);
	M1: MUX21_GENERIC GENERIC MAP (N_BIT) PORT MAP(A, B, tempS(0), temp1);
	M2: MUX21_GENERIC GENERIC MAP (N_BIT) PORT MAP(C, D, tempS(0), temp2);
	M3: MUX21_GENERIC GENERIC MAP (N_BIT) PORT MAP(temp1, temp2, tempS(1), temp3);
	M4: MUX21_GENERIC GENERIC MAP (N_BIT) PORT MAP(temp3, E, tempS(2), Y);

END BEHAVIOURAL;