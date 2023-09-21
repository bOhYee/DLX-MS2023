LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY PG_NETWORK_CIN IS
	PORT(A, B, CIn : IN std_logic;
		 P, G : OUT std_logic);	
END PG_NETWORK_CIN;

ARCHITECTURE BEHAVIORAL OF PG_NETWORK_CIN IS
BEGIN
    
    BehavProc: PROCESS(A,B)
    VARIABLE tempP: std_logic;
    BEGIN
        tempP := A XOR B;
        
        P <= tempP;
        G <= (A AND B) OR (tempP AND CIn);
    END PROCESS BehavProc;
    
END BEHAVIORAL;