LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.globals.ALL;

ENTITY REGISTER_GENERIC is
	GENERIC(NBIT: integer := 32);

	PORT(DATA_IN: IN std_logic_vector(NBIT-1 DOWNTO 0);
		 CLK, RESET, ENABLE, SET: IN std_logic;
		 DATA_OUT: OUT std_logic_vector(NBIT-1 DOWNTO 0));
END REGISTER_GENERIC;

ARCHITECTURE STRUCTURAL OF REGISTER_GENERIC IS

    COMPONENT FF IS
        PORT(D, D_SET: IN std_logic;
             CLK, SET, RESET, ENABLE: IN std_logic;
             Q: OUT	std_logic);
    END COMPONENT;

BEGIN

    REG: FOR i IN 0 TO NBIT-1 GENERATE
        SET_ZEROS: IF (i < 26) GENERATE
            FFi_ZEROS: FF PORT MAP(D => DATA_IN(i), D_SET => '0',
                                   CLK => CLK, RESET => RESET, SET => SET, ENABLE => ENABLE,
                                   Q => DATA_OUT(i));
        END GENERATE;


        SET_NOPS: IF (i >= 26) GENERATE
            FFi_SETS: FF PORT MAP(D => DATA_IN(i), D_SET => ITYPE_NOP(i-26),
                                  CLK => CLK, RESET => RESET, SET => SET, ENABLE => ENABLE,
                                  Q => DATA_OUT(i));
        END GENERATE;
    END GENERATE;

END STRUCTURAL;