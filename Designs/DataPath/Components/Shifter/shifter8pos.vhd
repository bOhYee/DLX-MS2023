LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY Shifter_8_pos IS

    PORT(R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
         RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;
         A : OUT std_logic_vector(NumBit-1 DOWNTO 0) );

END Shifter_8_pos;

ARCHITECTURE BEHAVIORAL OF Shifter_8_pos IS
BEGIN
    
    PROCESS (R1, RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL) IS
    VARIABLE tmpA : std_logic_vector (NumBit-1 DOWNTO 0);    
    BEGIN

        if RIGHT_OR_LEFT = '1' and LOGICAL_OR_ARITHMETICAL = '1' THEN       -- LEFT - ARITHMETICAL
            tmpA(NumBit-1 DOWNTO 8) := R1(Numbit-9 DOWNTO 0);
            tmpA(7 DOWNTO 0) := (OTHERS => R1(0));
        ELSIF RIGHT_OR_LEFT = '0' and LOGICAL_OR_ARITHMETICAL = '1' THEN    -- RIGHT - ARITHMETICAL
            tmpA(NumBit-9 DOWNTO 0) := R1(Numbit-1 DOWNTO 8);
            tmpA(NumBit-1 DOWNTO NumBit-8) := (OTHERS => R1(NumBit-1));
        ELSIF RIGHT_OR_LEFT = '1' and LOGICAL_OR_ARITHMETICAL = '0' THEN    -- LEFT - LOGICAL
            tmpA(NumBit-1 DOWNTO 8) := R1(Numbit-9 DOWNTO 0);
            tmpA(7 DOWNTO 0) := (OTHERS => '0');
        ELSE                                                                -- RIGHT - LOGICAL
            tmpA(NumBit-9 DOWNTO 0) := R1(Numbit-1 DOWNTO 8);
            tmpA(NumBit-1 DOWNTO NumBit-8) := (OTHERS => '0');
        END IF;
    A <= tmpA;
    END PROCESS;


END BEHAVIORAL;