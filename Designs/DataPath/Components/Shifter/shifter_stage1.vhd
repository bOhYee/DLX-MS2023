LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY Grain_shift_stage1 IS

    PORT(R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
         RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;
         A,B,C,D : OUT std_logic_vector(NumBit-1 DOWNTO 0) );

END Grain_shift_stage1;

ARCHITECTURE BEHAVIORAL OF Grain_shift_stage1 IS

    -- signal tmpA, tmp_shift: std_logic_vector(NumBit-1 DOWNTO 0);
    
    TYPE vectors IS ARRAY (0 to 3) OF std_logic_vector(NumBit-1 DOWNTO 0);
    SIGNAL tmp_OUT : vectors;

    COMPONENT Shifter_8_pos IS
        PORT(R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
             RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;
             A : OUT std_logic_vector(NumBit-1 DOWNTO 0) );
    END COMPONENT;

    BEGIN

        tmp_OUT(0) <= R1;

        shifter_8 : FOR i IN 0 TO 2 GENERATE
            shifter8pos : Shifter_8_pos PORT MAP ( R1 => tmp_OUT(i), RIGHT_OR_LEFT => RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL => LOGICAL_OR_ARITHMETICAL, A => tmp_OUT(i+1) );
        END GENERATE;

        A <= tmp_OUT(0);
        B <= tmp_OUT(1);
        C <= tmp_OUT(2);
        D <= tmp_OUT(3);

END BEHAVIORAL;