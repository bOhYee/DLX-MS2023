LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_IRAM IS
END tb_IRAM;

ARCHITECTURE Behavioral OF tb_MEM IS
    
    CONSTANT Period: Time := 20NS;
    SIGNAL clock_s: std_logic;
    SIGNAL reset_s, enable_s, ready_s: std_logic;
    SIGNAL addr_s, data_s: std_logic_vector(31 DOWNTO 0);
    
    COMPONENT IRAM IS
        GENERIC(RAM_DEPTH : integer := 48;
                I_SIZE : integer := 32);
        
        PORT(Rst, enable: IN  std_logic;
             Addr: IN std_logic_vector(I_SIZE - 1 DOWNTO 0);
             ready: OUT std_logic;
             Dout: OUT std_logic_vector(I_SIZE - 1 DOWNTO 0));
    END COMPONENT;
    
BEGIN
    
    -- Unit to test
    DUT: IRAM PORT MAP(Rst => reset_s, enable => enable_s, ready => ready_s,
                       Addr => addr_s, Dout => data_s);
                     
    ClockProc: PROCESS                     
    BEGIN
        clock_s <= '0';
        WAIT FOR Period/2;
        clock_s <= '1';
        WAIT FOR Period/2;        
    END PROCESS;
    
    
    InputProc: PROCESS
    BEGIN
        -- Reset the memory component
        reset_s <= '1';
        enable_s <= '0';
        addr_s <= (OTHERS => '0');
        WAIT FOR Period;
        WAIT FOR 5 NS;
        
        -- Test some addresses
        reset_s <= '0';
        enable_s <= '1';
        addr_s <= std_logic_vector(to_unsigned(5, 32));
        WAIT FOR Period;
        
        WAIT;        
    END PROCESS;

END Behavioral;