LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY Shifter IS

    PORT(RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;  -- 0 -> RIGHT or LOGICAL, 1 -> LEFT or ARITHMETICAL
         R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
         R2 : IN std_logic_vector(5 DOWNTO 0);
         Z : OUT std_logic_vector(NumBit-1 DOWNTO 0)
        );

END Shifter;

ARCHITECTURE STRUCTURAL OF Shifter IS

    -- signals associated to the results of the grain shift (stage 1)
    signal GR_SH_A, GR_SH_B, GR_SH_C, GR_SH_D : std_logic_vector (NumBit-1 DOWNTO 0);
    
    -- result of the grain shift after the 8to1 mux
    signal tmp_grain_shift : std_logic_vector (NumBit-1 DOWNTO 0);

    -- Grain shift component
    COMPONENT Grain_shift_stage1
        PORT(R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
             RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL: IN std_logic;
             A,B,C,D : OUT std_logic_vector(NumBit-1 DOWNTO 0) );
    END COMPONENT;
    
    -- Mux 4 to 1 component
    COMPONENT MUX_4TO1 IS 
        GENERIC(NBIT: integer:= NumBit);
        PORT(A,B,C,D: in std_logic_vector(NumBit-1 DOWNTO 0);
         S: in std_logic_vector(1 DOWNTO 0);
         Z: out std_logic_vector(NumBit-1 DOWNTO 0));
    END COMPONENT;

    -- Final shift component
    COMPONENT Shift_stage2
        PORT (GR_SH : IN std_logic_vector(NumBit-1 DOWNTO 0);
              R2 : IN std_logic_vector(2 DOWNTO 0);
              LOGICAL_OR_ARITHMETICAL, RIGHT_OR_LEFT : IN std_logic;  -- 0 -> RIGHT or LOGICAL, 1 -> LEFT or ARITHMETICAL
              A : OUT std_logic_vector(NumBit-1 DOWNTO 0) );
    END COMPONENT;

    BEGIN

        -- Grain shift component (stage 1)
        -- This component create 4 masks (0 , 8, 16, 24)
        STAGE1_GRAIN_SHIFT : Grain_shift_stage1 PORT MAP (R1 => R1, RIGHT_OR_LEFT => RIGHT_OR_LEFT, LOGICAL_OR_ARITHMETICAL => LOGICAL_OR_ARITHMETICAL, A => GR_SH_A, B => GR_SH_B, C => GR_SH_C, D => GR_SH_D);

        -- Mux 4 to 1 for selecting the output from the grain shift component (stage 1)
        STAGE1_MUX4TO1 : MUX_4TO1 GENERIC MAP (NBIT => NumBit) PORT MAP (A => GR_SH_A, B => GR_SH_B, C => GR_SH_C, D => GR_SH_D, S => R2 (4 DOWNTO 3), Z => tmp_grain_shift);

        -- Component for computing the real shift (stage 2)
        STAGE2_SHIFT : Shift_stage2 PORT MAP (GR_SH => tmp_grain_shift, R2 => R2 (2 DOWNTO 0), LOGICAL_OR_ARITHMETICAL => LOGICAL_OR_ARITHMETICAL, RIGHT_OR_LEFT => RIGHT_OR_LEFT, A => Z);

END STRUCTURAL;