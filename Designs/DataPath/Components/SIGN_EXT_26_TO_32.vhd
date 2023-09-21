LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SIGN_EXT_26_TO_32 IS
    PORT(A: IN std_logic_vector (25 DOWNTO 0);
         B: OUT std_logic_vector (31 DOWNTO 0));
END SIGN_EXT_26_TO_32;

ARCHITECTURE Behavioral OF SIGN_EXT_26_TO_32 is
BEGIN

    PROCESS(A)
    VARIABLE tmpResult: std_logic_vector (31 DOWNTO 0);
    BEGIN
        tmpResult(31 DOWNTO 26) := (OTHERS => A(15));
        tmpResult(25 DOWNTO 0) := A;

        B <= tmpResult;
    END PROCESS;

END Behavioral;