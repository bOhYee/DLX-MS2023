LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY HA IS
    PORT(A,B: in std_logic;          
         SUM, CARRYOUT: out std_logic);
END HA;

ARCHITECTURE Behavioral OF HA IS
BEGIN

    SUM <= A xor B;
    CARRYOUT <= A and B;

END Behavioral;