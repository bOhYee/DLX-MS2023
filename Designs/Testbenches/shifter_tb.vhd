LIBRARY ieee;
use ieee.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY TB_SHIFTER is

END TB_SHIFTER;

ARCHITECTURE BEHAVIORAL OF TB_SHIFTER is

    signal R1 : std_logic_vector (NumBit-1 DOWNTO 0);
    signal R2 : std_logic_vector (5 DOWNTO 0);
    signal Z : std_logic_vector (NumBit-1 DOWNTO 0);
    signal RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL : std_logic;

    COMPONENT Shifter IS
        PORT(RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;  -- 0 -> RIGHT or LOGICAL, 1 -> LEFT or ARITHMETICAL
             R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
             R2 : IN std_logic_vector(5 DOWNTO 0);
             Z : OUT std_logic_vector(NumBit-1 DOWNTO 0) );
    END COMPONENT;

    begin

        -- shift right logical 6 pos, shift left logical 22 pos, shift left arithmetical 15 pos & shift right arithmetical 17 pos
        R1 <= "00110011001100110011001100110011";
        R2 <= "000110", "010110" after 10ns, "001111" after 20ns, "010001" after 30ns;
        RIGHT_OR_LEFT <= '0' , '1' after 10 ns, '0' after 30 ns;
        LOGICAL_OR_ARITHMETICAL <= '0', '1' after 20 ns;
        
        Shifter_component : Shifter PORT MAP (RIGHT_OR_LEFT => RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL => LOGICAL_OR_ARITHMETICAL, R1 => R1, R2 => R2, Z => Z);

END BEHAVIORAL;