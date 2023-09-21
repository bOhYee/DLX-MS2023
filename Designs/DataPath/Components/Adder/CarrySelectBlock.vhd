LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY CARRY_SEL_BLOCK IS
    GENERIC(NBIT: integer := NumBit);
    
    PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
         Cin: IN std_logic;
         Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0));
END CARRY_SEL_BLOCK;

ARCHITECTURE STRUCTURAL OF CARRY_SEL_BLOCK IS

    SIGNAL Sum_C0, Sum_C1: std_logic_vector(NBIT-1 DOWNTO 0);
    SIGNAL C0_out_s, C1_out_s: std_logic;
    
    COMPONENT RCA IS
        GENERIC(NBIT: integer := NumBit);
                
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             Ci: IN std_logic;
             S: OUT std_logic_vector(NBIT-1 DOWNTO 0);
             Co: OUT std_logic);                
    END COMPONENT;
    
    COMPONENT MUX21_GENERIC IS
        GENERIC(NBIT: integer:= NumBit);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             SEL: IN std_logic;
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
BEGIN
    
    RCA_CIN_0: RCA GENERIC MAP(NBIT => NBIT)
                   PORT MAP(A => A, B => B, Ci => '0', S => Sum_C0, Co => C0_out_s);
                  
    RCA_CIN_1: RCA GENERIC MAP(NBIT => NBIT)
                   PORT MAP(A => A, B => B, Ci => '1', S => Sum_C1, Co => C1_out_s);
               
    -- Note: if SEL = 1 then Y = A
    -- This is why i mapped the input the inverse               
    MUX_0: MUX21_GENERIC GENERIC MAP(NBIT => NBIT)
                         PORT MAP(A => Sum_C1, B => Sum_C0, SEL => Cin, Y => Sum); 

END STRUCTURAL;

























