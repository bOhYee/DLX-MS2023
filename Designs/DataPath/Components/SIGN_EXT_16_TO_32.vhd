LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SIGN_EXT_16_TO_32 is
    PORT(A: IN std_logic_vector (15 DOWNTO 0);

         -- 0: Normal operation; 1: Logic operation
         OPTYPE: IN std_logic;
         B: OUT std_logic_vector (31 DOWNTO 0));
END SIGN_EXT_16_TO_32;

ARCHITECTURE Behavioral OF SIGN_EXT_16_TO_32 IS
BEGIN

    PROCESS(A, OPTYPE)
    VARIABLE tmpResult: std_logic_vector (31 DOWNTO 0);
    BEGIN
        IF OPTYPE = '0' THEN
            tmpResult(31 DOWNTO 16) := (OTHERS => A(15));
        ELSE
            tmpResult(31 DOWNTO 16) := (OTHERS => '0');
        END IF;

        tmpResult(15 DOWNTO 0) := A;
        B <= tmpResult;
    END PROCESS;

END Behavioral;