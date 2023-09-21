LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL; 

ENTITY FF IS
	PORT(D, D_SET: IN std_logic;
		 CLK, SET, RESET, ENABLE: IN std_logic;
		 Q: OUT	std_logic);
END FF;

-- Flip Flop of type D with syncronous reset
ARCHITECTURE BEHAVIOURAL_SYNCH OF FF IS 
BEGIN

	PSYNCH: PROCESS(CLK, RESET, ENABLE, SET, D, D_SET)
	BEGIN
		IF rising_edge(CLK) THEN
			-- Synchronous reset
			IF RESET='1' THEN 
				Q <= '0'; 
			ELSIF SET = '1' THEN
				Q <= D_SET; 
			ELSIF ENABLE = '1' THEN
				-- Input to output only when ENABLE active
				Q <= D; 
			END IF;
		END IF;
	END PROCESS;

END BEHAVIOURAL_SYNCH;