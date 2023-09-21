LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE WORK.GLOBALS.all;


ENTITY Mult_encoder is

	PORT (A0,A1,A2	: IN STD_LOGIC;
    	  S	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0));

END Mult_encoder;


ARCHITECTURE BEHAVIOURAL OF Mult_encoder IS

	SIGNAL A : STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN

	A(0) <= A0;
	A(1) <= A1;
	A(2) <= A2;

	PROCESS (A)		-- This process is used to implement the behaviour of the ENCODER
						-- We are using a 3 bit output in order to select the INPUT of the mux

	BEGIN

		CASE (A) IS

			WHEN "000" => S <= "000";	-- 0
			WHEN "111" => S <= "000";	-- 0
			WHEN "100" => S <= "100";	-- -2A
			WHEN "010" => S <= "001";	-- +A
			WHEN "110" => S <= "010";	-- -A
			WHEN "001" => S <= "001";	-- +A
			WHEN "101" => S <= "010";	-- -A
			WHEN "011" => S <= "011";	-- +2A

			WHEN OTHERS => S <= "000";

		END CASE ;

	END PROCESS ;

END BEHAVIOURAL;