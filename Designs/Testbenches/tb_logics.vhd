LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY TB_LOGICS IS
END TB_LOGICS;

ARCHITECTURE TEST OF TB_LOGICS IS 

CONSTANT Period: Time := 20 ns;

SIGNAL sel_s : std_logic_vector(3 DOWNTO 0);
SIGNAL R1_s, R2_s, result : std_logic_vector(NumBit-1 DOWNTO 0);

COMPONENT Logics
    GENERIC (N: integer := NumBit);
    
    PORT (SEL: IN std_logic_vector(3 DOWNTO 0);
          R1, R2: IN std_logic_vector(N-1 DOWNTO 0);
          Y: OUT std_logic_vector(N-1 DOWNTO 0));
END COMPONENT;

BEGIN

    -- Unit to test
    DUT: LOGICS PORT MAP(SEL => sel_s, R1 => R1_s, R2 => R2_s, Y => result);
    
    InputProcess: PROCESS 
    BEGIN 
        
        -- R1_s <= "0001";
        -- R2_s <= "0101";
        R1_s <= "00000100000010000101110101000010";
        R2_s <= "00000000000010000100000000000010";
        
        sel_s <= "1000"; -- AND
        WAIT FOR Period/2; 
        
        sel_s <= "0111"; -- NAND
        WAIT FOR Period/2; 
        
        sel_s <= "1110"; -- OR
        WAIT FOR Period/2; 
        
        sel_s <= "0001"; -- NOR
        WAIT FOR Period/2; 
        
        sel_s <= "0110"; -- XOR
        WAIT FOR Period/2; 
        
        sel_s <= "1001"; -- XNOR
        WAIT FOR Period/2; 
        
        WAIT;

    END PROCESS; 
    
END TEST;