LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Adder_PC IS
    PORT(A: IN std_logic_vector(31 DOWNTO 0);
         SUM: OUT std_logic_vector (31 DOWNTO 0));
END Adder_PC;

ARCHITECTURE Structural OF Adder_PC IS

    SIGNAL STMP: std_logic_vector(31 DOWNTO 0);
    SIGNAL CTMP: std_logic_vector(32 DOWNTO 0);

    COMPONENT HA IS
        PORT(A,B: IN std_logic;          
             SUM, CARRYOUT: OUT std_logic);
    END COMPONENT;

BEGIN

    -- Since the first two bits don't ever change
    STMP(0) <= A(0);
    STMP(1) <= A(1);
    CTMP(0) <= '0';
    CTMP(1) <= '0';
    CTMP(2) <= '1';
    
    -- Computed sum
    SUM <= STMP;
    
    -- Sum all the other bits
    ADDITION: FOR i IN 2 TO 31 GENERATE
		HAi: HA PORT MAP(A => A(I), B => CTMP(I), SUM => STMP(I), CARRYOUT => CTMP(I+1));
	END GENERATE;

END Structural;