LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY tb_divider_component IS
END tb_divider_component;

ARCHITECTURE test OF tb_divider_component IS
    CONSTANT Period : Time := 20 ns;
    
    COMPONENT DividerComponent IS 
        GENERIC (NBIT: integer := NumBit);
        PORT (CK : IN std_logic;
              A, B : IN std_logic_vector(NBIT-1 DOWNTO 0);
              ALU_enable: IN std_logic;
              Q, R : OUT std_logic_vector(NBIT-1 DOWNTO 0) := (OTHERS => '0'));
    END COMPONENT;
    
    SIGNAL A_s, B_s, Q_s, R_s : std_logic_vector(NumBit-1 DOWNTO 0);
    SIGNAL clock_s, ALU_enable_s : std_logic;
    
BEGIN
    
    -- Unit to test
    DUT: DividerComponent GENERIC MAP (NBIT => NumBit) 
            PORT MAP(CK => clock_s, A => A_s, B => B_s, ALU_enable => ALU_enable_s,
                     Q => Q_s, R => R_s);
    
    ClockProc: PROCESS                     
    BEGIN
        clock_s <= '0';
        WAIT FOR Period/2;
        clock_s <= '1';
        WAIT FOR Period/2;        
    END PROCESS;
    
    InputProcess: PROCESS 
    BEGIN
    
        --A_s <= "00000000000000000000000001100100"; -- +50
        --B_s <= "00000000000000000000000000000010"; -- + 2
        
        --A_s <= "00000000000000000000000001100111"; -- +103
        --B_s <= "11111111111111111111111111111101"; -- - 3
        
        --A_s <= "11111111111111111111111110011001"; -- - 103
        --B_s <= "11111111111111111111111111111101"; -- - 3
        --WAIT FOR 160 ns;
        
        
        --WAIT FOR 500 ns;
        
        --A_s <= "00000000000000000000000001100111"; -- + 103
        --B_s <= "00000000000000000000000000000011"; --  + 3
        
        --WAIT FOR 160 ns;
        
        --A_s <= "11111111111111111111111110011001"; -- -103
        --B_s <= "00000000000000000000000000000011"; -- + 3
        
        
--        A_S <= "00101011";
--        B_s <= "01100000";
        
--        A_S <= "00110010";
--        B_s <= "01000000";
        ALU_enable_s <= '1';

        A_s <= "00000000000000000000000000101100"; -- 44
        B_s <= "00000000000000000000000000000011"; -- 3
        
        WAIT FOR 500 ns;
        --A_s <= "00000000000000000000000000000010"; 
        --B_s <= "00000000000000000000000000000100"; 
        
        -- Not working
        --A_s <= "01000111110100001001110111011110"; -- 1204854238
        --B_s <= "00000000000010000100100000111110"; -- 542782
        
        WAIT; 
    END PROCESS;
       
END test;