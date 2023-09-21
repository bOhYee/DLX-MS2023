LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY tb_DLX IS
END tb_DLX;

ARCHITECTURE TEST OF tb_DLX IS

    -- Clock and reset signals
    CONSTANT Period: Time := 20ns;
    SIGNAL clock_s, reset_s: std_logic;

    SIGNAL IR_enable_s, IR_ready_s: std_logic;
    SIGNAL IR_Addr_s, IR_Data_s: std_logic_vector(31 DOWNTO 0);
    
    SIGNAL DRAM_enable_s, DRAM_ready_s, DRAM_rw_s: std_logic;
    SIGNAL DRAM_Addr_s, DRAM_DataIn_s, DRAM_DataOut_s: std_logic_vector(31 DOWNTO 0);

    SIGNAL Result_s: std_logic_vector(31 DOWNTO 0);

    COMPONENT DLX IS
        PORT(clock, reset: IN std_logic;

             -- For IRAM
             IMEM_enable: OUT std_logic;
             IMEM_Addr: OUT std_logic_vector(31 DOWNTO 0);
 
             IMEM_ready: IN std_logic;
             IMEM_Data: IN std_logic_vector(31 DOWNTO 0);
 
             -- For DRAM
             DRAM_enable, DRAM_rw: OUT std_logic;
             DRAM_Addr, DRAM_Din: OUT std_logic_vector(31 DOWNTO 0);
 
             DRAM_ready: IN std_logic;
             DRAM_Dout: IN std_logic_vector(31 DOWNTO 0);
                 
             -- Output
             Result: OUT std_logic_vector(31 DOWNTO 0));  
    END COMPONENT;

    COMPONENT IRAM IS
        GENERIC(RAM_DEPTH : integer := 96;
                I_SIZE : integer := 32);

        PORT(Rst, enable: IN  std_logic;
             Addr: IN std_logic_vector(I_SIZE - 1 DOWNTO 0);
             ready: OUT std_logic;
             Dout: OUT std_logic_vector(I_SIZE - 1 DOWNTO 0));
    END COMPONENT;

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

    -- Instance of DLX 
    DUT_STRUCT: DLX PORT MAP(clock => clock_s, reset => reset_s,

                             -- IRAM signals
                             IMEM_enable => IR_enable_s, IMEM_Addr => IR_Addr_s,
                             IMEM_ready => IR_ready_s, IMEM_Data => IR_Data_s,
                             
                             -- DRAM signals
                             DRAM_enable => DRAM_enable_s, DRAM_rw => DRAM_rw_s, DRAM_Addr => DRAM_Addr_s, 
                             DRAM_ready => DRAM_ready_s, DRAM_Din => DRAM_DataIn_s, DRAM_Dout => DRAM_DataOut_s, 

                            Result => Result_s);

    -- Instruction memory
    IMEM: IRAM PORT MAP(Rst => reset_s, enable => IR_enable_s, ready => IR_ready_s,
                        Addr => IR_Addr_s, Dout => IR_Data_s);   
                        
    
    -- Data memory
    DMEM: DRAM PORT MAP(clock => clock_s, reset => reset_s, 
                        enable => DRAM_enable_s, rw => DRAM_rw_s, ready => DRAM_ready_s,
                        addr => DRAM_Addr_s, data_in => DRAM_DataIn_s, data_out => DRAM_DataOut_s);                        

    -- Process to manage the changing of the clock signal
    ClockProc: PROCESS
    BEGIN
        clock_s <= '1';
        WAIT FOR Period/2;
        clock_s <= '0';
        WAIT FOR Period/2;
    END PROCESS;

    reset_s <= '1', '0' AFTER 2*Period;
        
END TEST;