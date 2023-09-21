LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE WORK.Globals.ALL;

-- The idea of the number generator is to generate the 5 input of the MUX (5 to 1 MUX)
-- The OUTPUT are the 5 INPUT of the MUX

ENTITY Mult_num_generation is
GENERIC (N_BIT : integer := NumBit);

	PORT (S : IN INTEGER;
		  X	: IN STD_LOGIC_VECTOR (N_BIT/2-1 DOWNTO 0);
		  A,B,C,D,E	: OUT STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0));

END Mult_num_generation;


ARCHITECTURE BEHAVIOURAL OF Mult_num_generation IS


BEGIN

	PROCESS(S, X)
	VARIABLE tmpB, tmpD: std_logic_vector(N_BIT-1 DOWNTO 0);
	BEGIN
	   tmpB (N_BIT-1 DOWNTO N_BIT/2-1) := (OTHERS => X(N_BIT/2-1) );
	   tmpB (N_BIT/2-1 DOWNTO 0) := X;
	   
	   tmpD (N_BIT-1 DOWNTO N_BIT/2-1) := (OTHERS => X(N_BIT/2-1) );
	   tmpD (N_BIT/2-1 DOWNTO 0) := X;
	   
	   
	   A <= (OTHERS => '0');
	   
	   tmpB := std_logic_vector(shift_left(unsigned(tmpB),S));
	   B <= tmpB;
	   C <= std_logic_vector(signed(not(tmpB)) + 1);
	   
	   tmpD := std_logic_vector(shift_left(unsigned(tmpD), S+1));
	   D <= tmpD;
	   E <= std_logic_vector(unsigned(not(tmpD)) + 1);
	END PROCESS;
	
END BEHAVIOURAL;