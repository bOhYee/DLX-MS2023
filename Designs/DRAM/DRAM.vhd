LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY DRAM IS
    GENERIC(DATA_DEPTH: integer := 50;
            ADDRESS_WIDTH: integer := 32;
            DATA_WIDTH: integer := 32);
             
    PORT(clock, reset: IN std_logic;
         enable, rw: IN std_logic;
         data_in: IN std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
         addr: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
         ready: OUT std_logic;
         data_out: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0));
END DRAM;

ARCHITECTURE Behavioral OF DRAM IS
    
    -- Register file
    TYPE memory IS ARRAY(0 TO DATA_DEPTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
    SIGNAL CurrDRAM: memory;

    SIGNAL write_ready, read_ready: std_logic;
        
BEGIN

    -- Save new data or manage reset operation
    WriteProcess: PROCESS(clock, reset, enable, rw, data_in)
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '1' THEN
                -- Resetting the entire DRAM memory
                -- Put all 0s in every row contained inside
                FOR i IN 0 TO DATA_DEPTH-1 LOOP
                    CurrDRAM(i) <= (OTHERS => '0');
                END LOOP;
                
                CurrDRAM(0) <= X"00000003";
                CurrDRAM(1) <= X"00000007";
                CurrDRAM(2) <= X"00000001";
                CurrDRAM(3) <= X"00000004";
                CurrDRAM(4) <= X"00000002";

                write_ready <= '1';
            ELSE
                -- When write enabled we compute the new values to be stored inside the DRAM
                IF enable = '1' AND rw = '1' THEN
                    CurrDRAM(to_integer(unsigned(addr))) <= data_in;
                    write_ready <= '1';
                ELSE
                    write_ready <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS WriteProcess;
    
    -- Asynchronous read
    ReadProcess: PROCESS(reset, CurrDRAM, enable, rw, addr)
    BEGIN 
        IF reset = '1' OR enable = '0' OR rw = '1' THEN
            data_out <= (OTHERS => 'Z');
            read_ready <= '1';
        ELSIF enable = '1' AND rw = '0' THEN
            data_out <= CurrDRAM(to_integer(unsigned(addr)));    
            read_ready <= '1';
        END IF;
    END PROCESS ReadProcess;

    ready <= write_ready AND read_ready;
    
END Behavioral;