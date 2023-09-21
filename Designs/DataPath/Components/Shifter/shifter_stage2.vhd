LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;
USE WORK.globals.ALL;

ENTITY Shift_stage2 IS

    PORT(GR_SH : IN std_logic_vector(NumBit-1 DOWNTO 0);
         R2 : IN std_logic_vector(2 DOWNTO 0);
         LOGICAL_OR_ARITHMETICAL, RIGHT_OR_LEFT : IN std_logic;  -- 0 -> RIGHT or LOGICAL, 1 -> LEFT or ARITHMETICAL
         A : OUT std_logic_vector(NumBit-1 DOWNTO 0)
        );

END Shift_stage2;

ARCHITECTURE BEHAVIORAL OF Shift_stage2 IS

    --SIGNAL sh_index, index : integer RANGE 0 TO 7;
    SIGNAL tmpA : std_logic_vector (NumBit-1 DOWNTO 0);
    
    BEGIN

    PROCESS (GR_SH) IS

	variable sh_index, index : integer;
    
    BEGIN

		sh_index := to_integer(unsigned(R2));
		index := NumBit-(sh_index+1);

        --IF RIGHT_OR_LEFT = '1' and LOGICAL_OR_ARITHMETICAL = '1' THEN           -- LEFT - ARITHMETICAL
        --    tmpA(NumBit-1 DOWNTO sh_index) <= GR_SH( NumBit - (h_index+1) DOWNTO 0);
        --    tmpA(sh_index-1 DOWNTO 0) <= (OTHERS => GR_SH(0));
        IF RIGHT_OR_LEFT = '0' and LOGICAL_OR_ARITHMETICAL = '1' THEN    -- RIGHT - ARITHMETICAL

			case sh_index is
				when 1 =>
					tmpA(NumBit-2 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 1);
					tmpA(NumBit-1 DOWNTO NumBit-1) <= (OTHERS => GR_SH(NumBit-1));
				when 2 =>
					tmpA(NumBit-3 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 2);
					tmpA(NumBit-1 DOWNTO NumBit-2) <= (OTHERS => GR_SH(NumBit-1));
				when 3 =>
					tmpA(NumBit-4 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 3);
					tmpA(NumBit-1 DOWNTO NumBit-3) <= (OTHERS => GR_SH(NumBit-1));
				when 4 =>
					tmpA(NumBit-5 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 4);
					tmpA(NumBit-1 DOWNTO NumBit-4) <= (OTHERS => GR_SH(NumBit-1));
				when 5 =>
					tmpA(NumBit-6 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 5);
					tmpA(NumBit-1 DOWNTO NumBit-5) <= (OTHERS => GR_SH(NumBit-1));
				when 6 =>
					tmpA(NumBit-7 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 6);
					tmpA(NumBit-1 DOWNTO NumBit-6) <= (OTHERS => GR_SH(NumBit-1));
				when 7 =>
					tmpA(NumBit-8 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 7);
					tmpA(NumBit-1 DOWNTO NumBit-7) <= (OTHERS => GR_SH(NumBit-1));
				when others =>
					tmpA <= (OTHERS => '0');
			end case;

        ELSIF RIGHT_OR_LEFT = '1' and LOGICAL_OR_ARITHMETICAL = '0' THEN    -- LEFT - LOGICAL

			case sh_index is
				when 1 =>
					tmpA(NumBit-1 DOWNTO 1) <= GR_SH(NumBit-2 DOWNTO 0);
					tmpA(1 DOWNTO 0) <= (OTHERS => GR_SH(NumBit-1));
				when 2 =>
					tmpA(NumBit-1 DOWNTO 2) <= GR_SH(NumBit-3 DOWNTO 0);
					tmpA(2 DOWNTO 0) <= (OTHERS => '0');
				when 3 =>
					tmpA(NumBit-1 DOWNTO 3) <= GR_SH(NumBit-4 DOWNTO 0);
					tmpA(3 DOWNTO 0) <= (OTHERS => '0');
				when 4 =>
					tmpA(NumBit-1 DOWNTO 4) <= GR_SH(NumBit-5 DOWNTO 0);
					tmpA(4 DOWNTO 0) <= (OTHERS => '0');
				when 5 =>
					tmpA(NumBit-1 DOWNTO 5) <= GR_SH(NumBit-6 DOWNTO 0);
					tmpA(5 DOWNTO 0) <= (OTHERS => '0');
				when 6 =>
					tmpA(NumBit-1 DOWNTO 6) <= GR_SH(NumBit-7 DOWNTO 0);
					tmpA(6 DOWNTO 0) <= (OTHERS => '0');
				when 7 =>
					tmpA(NumBit-1 DOWNTO 7) <= GR_SH(NumBit-8 DOWNTO 0);
					tmpA(7 DOWNTO 0) <= (OTHERS => '0');
				when others =>
					tmpA <= (OTHERS => '0');
			end case;

        ELSE                                                               -- RIGHT - LOGICAL
	
			case sh_index is
				when 1 =>
					tmpA(NumBit-2 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 1);
					tmpA(NumBit-1 DOWNTO NumBit-1) <= (OTHERS => '0');
				when 2 =>
					tmpA(NumBit-3 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 2);
					tmpA(NumBit-1 DOWNTO NumBit-2) <= (OTHERS => '0');
				when 3 =>
					tmpA(NumBit-4 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 3);
					tmpA(NumBit-1 DOWNTO NumBit-3) <= (OTHERS => '0');
				when 4 =>
					tmpA(NumBit-5 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 4);
					tmpA(NumBit-1 DOWNTO NumBit-4) <= (OTHERS => '0');
				when 5 =>
					tmpA(NumBit-6 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 5);
					tmpA(NumBit-1 DOWNTO NumBit-5) <= (OTHERS => '0');
				when 6 =>
					tmpA(NumBit-7 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 6);
					tmpA(NumBit-1 DOWNTO NumBit-6) <= (OTHERS => '0');
				when 7 =>
					tmpA(NumBit-8 DOWNTO 0) <= GR_SH(NumBit-1 DOWNTO 7);
					tmpA(NumBit-1 DOWNTO NumBit-7) <= (OTHERS => '0');
				when others =>
					tmpA <= (OTHERS => '0');
			end case;

        END IF;

    END PROCESS;

    A <= tmpA;

END BEHAVIORAL;