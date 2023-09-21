LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY IR_COMPARATOR IS 
    PORT(A, B: IN std_logic_vector(5 DOWNTO 0);
         AreEqual: OUT std_logic);
END IR_COMPARATOR;

ARCHITECTURE STRUCTURAL OF IR_COMPARATOR IS

    SIGNAL XNOR_Result: std_logic_vector(5 DOWNTO 0);

BEGIN

    XNOR_Result <= std_logic_vector(unsigned(A) XNOR unsigned(B));
    AreEqual <= ((XNOR_Result(0) AND XNOR_Result(1)) AND 
                 (XNOR_Result(2) AND XNOR_Result(3))) AND (XNOR_Result(4) AND XNOR_Result(5));

END STRUCTURAL;