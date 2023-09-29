LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY Divider IS 
    GENERIC(NBIT: integer := NumBit);

    PORT(CK : IN std_logic;
         A : IN std_logic_vector(NBIT-1 DOWNTO 0);
         B : IN std_logic_vector(NBIT-1 DOWNTO 0);
         enable : IN std_logic;
         Q : OUT std_logic_vector(NBIT-1 DOWNTO 0);
         R : OUT std_logic_vector(NBIT-1 DOWNTO 0);
         result_ready : OUT std_logic);
END Divider;

ARCHITECTURE Behavioral OF Divider IS

    CONSTANT cyclesToPerform : integer := DIV_CYCLES;  

    SIGNAL tmpQ_pos, next_tmpQ_pos, tmpQ_neg, next_tmpQ_neg: std_logic_vector(NBIT-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter, nextCounter : integer;
    SIGNAL next_result_ready, done, nextDone : std_logic := '0';
    SIGNAL tmp_r, next_tmp_r : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL B_extended_s : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0'); -- Just for test reasons

BEGIN     
    setup: PROCESS(CK)
        BEGIN
            IF rising_edge(CK) THEN 
                IF enable = '1' THEN 
                    tmp_r <= next_tmp_r;
                    tmpQ_pos <= next_tmpQ_pos;
                    tmpQ_neg <= next_tmpQ_neg;
                    counter <= nextCounter;
                    result_ready <= next_result_ready;
                    done <= nextDone;
                ELSIF done = '1' THEN 
                    result_ready <= '0';
                    done <= '0';
                ELSE 
                    result_ready <= '0';
                    done <= '0'; 
                    tmpQ_pos <= (OTHERS => '0');
                    tmpQ_neg <= (OTHERS => '0');
                    tmp_r <= (OTHERS => '0');
                    counter <= NBIT-1;
                END IF;
            END IF;          
        END PROCESS;    
    
    division: PROCESS(enable, tmp_r, tmpQ_pos, tmpQ_neg, counter)
        VARIABLE R_tmp : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0');
        VARIABLE B_extended : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0');
        
        BEGIN
        R_tmp := (OTHERS => '0');
        B_extended := (OTHERS => '0');
        B_extended(2*NBIT-1 DOWNTO NBIT) := B;
        
        B_extended_s <= B_extended;
        
        
        IF enable = '1' THEN
        
            IF counter = NBIT-1 THEN 
                R_tmp(NBIT-1 DOWNTO 0) := A; 
            ELSE 
                R_tmp := tmp_r;
            END IF;         
                   
            IF counter >= 0 AND done = '0' THEN
                IF signed(R_tmp) >= 0 THEN 
                    next_tmpQ_pos(counter) <= '1';
                    next_tmpQ_neg(counter) <= '0';
                    R_tmp := std_logic_vector(signed((R_tmp(2*NBIT-2 DOWNTO 0) & '0')) - signed(B_extended));
                ELSE 
                    next_tmpQ_pos(counter) <= '0';
                    next_tmpQ_neg(counter) <= '1';
                    
                    R_tmp := std_logic_vector(signed((R_tmp(2*NBIT-2 DOWNTO 0) & '0')) + signed(B_extended));
                    
                END IF; 
         
                nextCounter <= counter - 1;
                nextDone <= '0';
                next_tmp_r <= R_tmp;
            END IF; 
                
            IF counter = 0 THEN 
                nextDone <= '1';
                nextCounter <= NBIT-1;
                next_result_ready <= '1';                
            END IF;
            
        ELSE 
            nextCounter <= 0;
            next_tmpQ_pos <= (OTHERS => '0');
            next_tmpQ_neg <= (OTHERS => '0');
            next_tmp_r <= (OTHERS => '0');  
            next_result_ready <= '0';
        END IF;
               
        END PROCESS;
        
    result : PROCESS(done, enable)
    VARIABLE temporary_q : std_logic_vector(NBIT-1 DOWNTO 0) := (OTHERS => '0');
    VARIABLE temporary_r : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0');
    VARIABLE B_extended : std_logic_vector(2*NBIT-1 DOWNTO 0) := (OTHERS => '0');
    
    BEGIN
        temporary_q := (OTHERS => '0');
        temporary_r := (OTHERS => '0');
        B_extended := (OTHERS => '0');
        B_extended(2*NBIT-1 DOWNTO NBIT) := B;
        
        IF (rising_edge(enable) AND enable = '1') THEN
            Q <= (OTHERS => '0');
            R <= (OTHERS => '0');  
        END IF;
        
        IF done = '1' THEN 
            temporary_q := std_logic_vector(unsigned(tmpQ_pos) - unsigned(tmpQ_neg));
            R <= tmp_r(2*NBIT-1 DOWNTO NBIT);
                        
            IF signed(tmp_r) < 0 THEN 
                temporary_q := std_logic_vector(unsigned(temporary_q) - 1);
                temporary_r := std_logic_vector(signed(tmp_r) + signed(B_extended));
                R <= temporary_r(2*NBIT-1 DOWNTO NBIT);
            END IF; 
            
            Q <= temporary_q;
            
        END IF;
    
    END PROCESS;
     
END Behavioral;
