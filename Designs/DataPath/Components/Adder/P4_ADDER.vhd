LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY P4_ADDER IS
    GENERIC(NBIT: integer := NumBit;
            NSTAGES: integer := NumStages);
            
    PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
         CarryIn: IN std_logic;
         Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0);
         Overflow, CarryOut: OUT std_logic);
END P4_ADDER;

ARCHITECTURE STRUCTURAL OF P4_ADDER IS

    SIGNAL Cout_s: std_logic_vector(NSTAGES DOWNTO 0);

    COMPONENT CARRY_GENERATOR IS
        GENERIC(NBIT: integer := NumBit;
                NSTAGES: integer := NumStages);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             Cin: IN std_logic;
             Overflow: OUT std_logic;
             Carries: OUT std_logic_vector(NSTAGES DOWNTO 0));
    END COMPONENT;

    COMPONENT SUM_GEN_BLOCK IS
        GENERIC(NBIT: integer := NumBit;
                NSTAGES: integer := NumStages);
        
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             Carries: IN std_logic_vector(NSTAGES-1 DOWNTO 0);
             Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
BEGIN

    CarryOut <= Cout_s(NSTAGES);
    
    CGEN: CARRY_GENERATOR GENERIC MAP(NBIT => NBIT, NSTAGES => NSTAGES)
                          PORT MAP(A => A, B => B, Cin => CarryIn, Overflow => Overflow, Carries => Cout_s);

    SGEN: SUM_GEN_BLOCK GENERIC MAP(NBIT => NBIT, NSTAGES => NSTAGES)
                        PORT MAP(A => A, B => B, Carries => Cout_s(NSTAGES-1 DOWNTO 0), Sum => Sum);

END STRUCTURAL;



















