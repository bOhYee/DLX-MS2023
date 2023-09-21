LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY SUM_GEN_BLOCK IS
    GENERIC(NBIT: integer := NumBit;
            NSTAGES: integer := NumStages);
    
    PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
         Carries: IN std_logic_vector(NSTAGES-1 DOWNTO 0);
         Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0));
END SUM_GEN_BLOCK;

ARCHITECTURE STRUCTURAL OF SUM_GEN_BLOCK IS

    CONSTANT BitsPerStage : integer := (NBIT/NSTAGES);
    
    COMPONENT CARRY_SEL_BLOCK IS
        GENERIC(NBIT: integer := NumBit);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             Cin: IN std_logic;
             Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
BEGIN

    CSBs: FOR i IN 1 TO NSTAGES GENERATE
        Stage: CARRY_SEL_BLOCK GENERIC MAP(NBIT => (NBIT/NSTAGES))
                               PORT MAP(A => A(((i*BitsPerStage)-1) DOWNTO ((i-1)*BitsPerStage)),
                                        B => B(((i*BitsPerStage)-1) DOWNTO ((i-1)*BitsPerStage)),
                                        Cin => Carries(i-1),
                                        Sum => Sum(((i*BitsPerStage)-1) DOWNTO ((i-1)*BitsPerStage)));
    END GENERATE;

END STRUCTURAL;