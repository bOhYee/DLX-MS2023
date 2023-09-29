LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DividerComponent IS 
    GENERIC (NBIT: integer := NumBit);
    PORT (CK: IN std_logic;
          A, B : IN std_logic_vector(NBIT-1 DOWNTO 0);
          ALU_enable: IN std_logic;
          Q : OUT std_logic_vector(NBIT-1 DOWNTO 0);
          R : OUT std_logic_vector(NBIT-1 DOWNTO 0));
END DividerComponent;

ARCHITECTURE Behavioral OF DividerComponent IS

    CONSTANT cyclesToPerform : integer := DIV_CYCLES; 

    SIGNAL isQ_neg, isR_neg : std_logic;
    SIGNAL result_ready: std_logic := '0';
    SIGNAL A_positive, B_positive, Q_partial, R_partial : std_logic_vector(NBIT-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL enable, nextEnable : std_logic := '0';

    COMPONENT Divider IS 
        GENERIC (NBIT: integer := NumBit);
        PORT (CK : IN std_logic;
            A: IN std_logic_vector(NBIT-1 DOWNTO 0);
            B: IN std_logic_vector(NBIT-1 DOWNTO 0);
            enable : IN std_logic;
            Q : OUT std_logic_vector(NBIT-1 DOWNTO 0);
            R : OUT std_logic_vector(NBIT-1 DOWNTO 0);
            result_ready : OUT std_logic);
    END COMPONENT;

BEGIN
    clk : PROCESS(CK) 
    BEGIN 
        IF rising_edge(CK) THEN 
            
            enable <= nextEnable;
            IF result_ready = '1' THEN
                enable <= '0';  
            END IF;
        END IF;
    
    END PROCESS;

    setup : PROCESS (A, B, ALU_enable) 
        VARIABLE A_positive_tmp, B_positive_tmp : std_logic_vector(NBIT-1 DOWNTO 0) := (OTHERS => '0'); 
        
        BEGIN 
            IF (rising_edge(result_ready) AND result_ready = '1') OR ALU_enable = '0' THEN
                nextEnable <= '0';
                
            ELSIF ALU_enable = '1' AND enable = '0' THEN
            
                A_positive_tmp := (OTHERS => '0');
                B_positive_tmp := (OTHERS => '0');
                
                isQ_neg <= A(NBIT-1) XOR B(NBIT-1);
                isR_neg <= A(NBIT-1);
                
                -- Make A and B positive 
                IF A(NBIT-1) = '1' THEN 
                    A_positive_tmp := std_logic_vector(unsigned(NOT(A)) + 1);
                ELSE    
                    A_positive_tmp := A;        
                END IF;
                
                IF B(NBIT-1) = '1' THEN 
                    B_positive_tmp := std_logic_vector(unsigned(NOT(B)) + 1);
                ELSE    
                    B_positive_tmp := B;        
                END IF;
                
                A_positive <= A_positive_tmp;
                nextEnable <= '1';
                
                B_positive(NBIT-1 DOWNTO 0) <= B_positive_tmp;
            END IF;        
    END PROCESS;
    
    generateFinalResult: PROCESS (Q_partial, R_partial, result_ready, ALU_enable)    
    BEGIN
        
        IF (rising_edge(ALU_enable) AND ALU_enable = '1') THEN
            Q <= (OTHERS => '0');
            R <= (OTHERS => '0');  
        END IF;      
        
        IF result_ready = '1' THEN
            IF isQ_neg = '1' THEN 
                Q <= std_logic_vector(unsigned(NOT(Q_partial)) + 1);
            ELSE 
                Q <= Q_partial; 
            END IF;
            
            IF isR_neg = '1' THEN 
                R <= std_logic_vector(unsigned(NOT(R_partial)) + 1);           
            ELSE 
                R <= R_partial;
            END IF;
            
        END IF;
        
    END PROCESS;
    
    Div1 : Divider GENERIC MAP (NBIT => NumBit) 
            PORT MAP(CK => CK, A => A_positive, B => B_positive, 
                enable => enable, Q => Q_partial, R => R_partial, result_ready => result_ready); 
 
END Behavioral;
