LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY tb_DRAM IS
END tb_DRAM;

ARCHITECTURE Behavioral OF tb_DRAM IS
    
    CONSTANT Period: Time := 20NS;
    SIGNAL clock_s: std_logic;
    SIGNAL reset_s, enable_s, rw_s, ready_s: std_logic;
    SIGNAL addr_s, data_in_s, data_out_s: std_logic_vector(31 DOWNTO 0);
    
    COMPONENT DRAM IS
        GENERIC(ADDRESS_WIDTH: integer := 32;
                DATA_WIDTH: integer := 32);
                 
        PORT(clock, reset: IN std_logic;
             enable, rw: IN std_logic;
             data_in: IN std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
             addr: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
             ready: OUT std_logic;
             data_out: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0));
    END COMPONENT;
    
BEGIN
    
    -- Unit to test
    DUT: DRAM PORT MAP(clock => clock_s, reset => reset_s, 
                       enable => enable_s, rw => rw_s, ready => ready_s,
                       addr => addr_s, data_in => data_in_s, data_out => data_out_s);
        
    -- Process to manage clock signal changes             
    ClockProc: PROCESS                     
    BEGIN
        clock_s <= '0';
        WAIT FOR Period/2;
        clock_s <= '1';
        WAIT FOR Period/2;        
    END PROCESS;
    
    
    -- Process to test DUT by inputting test vectors
    InputProc: PROCESS
    BEGIN
        -- Reset the memory component
        reset_s <= '1';
        enable_s <= '0';
        rw_s <= '0';
        addr_s <= (OTHERS => '0');
        WAIT FOR Period;
        WAIT FOR 5 NS;
        
        -- Write some data
        reset_s <= '0';
        enable_s <= '1';
        rw_s <= '1';
        
        addr_s <= std_logic_vector(to_unsigned(0, 32));
        data_in_s <= std_logic_vector(to_unsigned(56, 32));
        WAIT FOR Period;
        
        enable_s <= '0';                
        WAIT FOR 3*Period;
        
        FOR i IN 0 TO 30 LOOP
            addr_s <= std_logic_vector(to_unsigned(i, 32));
            data_in_s <= std_logic_vector(to_unsigned(2*i, 32));
            WAIT FOR Period;
        END LOOP;
        
        -- Finish writing operations
        enable_s <= '0';
        rw_s <= '0';
        WAIT FOR Period;
        
        -- Read some data
        enable_s <= '1';
        addr_s <= std_logic_vector(to_unsigned(4, 32));
        WAIT FOR Period;
        
        addr_s <= std_logic_vector(to_unsigned(12, 32));
        WAIT FOR Period;
        WAIT;        
    END PROCESS;

END Behavioral;