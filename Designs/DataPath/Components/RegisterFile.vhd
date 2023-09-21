LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RegisterFile IS
    GENERIC(ADDRESS_WIDTH: integer := 5;
            DATA_WIDTH: integer := 64);
             
    PORT(clock, reset: IN std_logic;
         wr_data: IN std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
         wr_addr: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
         wr_enable: IN std_logic;
         rd_data_1: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
         rd_addr_1: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
         rd_enable_1: IN std_logic;           
         rd_data_2: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
         rd_addr_2: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
         rd_enable_2: IN std_logic);
END RegisterFile;

ARCHITECTURE Behavioral OF RegisterFile IS
    
    -- Register file
    TYPE regfile_type IS ARRAY(0 TO 2**ADDRESS_WIDTH-1) OF std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
    SIGNAL RegFile, NextRegFile: regfile_type;
        
BEGIN

    SaveProcess: PROCESS(clock, reset, wr_enable)
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '1' THEN
                -- Resetting the entire register file 
                -- Put all 0s in every register contained inside
                FOR i IN 0 TO 2**ADDRESS_WIDTH-1 LOOP
                    RegFile(i) <= (OTHERS => '0');
                END LOOP;
            ELSE
                -- When write enable is on we compute the new values to be stored inside the registers
                IF wr_enable = '1' THEN
                    RegFile <= NextRegFile;
                END IF;
            END IF;
        END IF;
    END PROCESS SaveProcess;
    
    -- Synchronous write
    WriteProcess: PROCESS(RegFile, wr_data, wr_addr)
    VARIABLE RegFileMod: regfile_type;
    BEGIN 
        RegFileMod := RegFile;
        RegFileMod(to_integer(unsigned(wr_addr))) := wr_data;

        NextRegFile <= RegFileMod;
    END PROCESS WriteProcess;
    
    -- Asynchronous read
    ReadProcessOne: PROCESS(reset, RegFile, rd_enable_1, rd_addr_1)
    BEGIN 
        IF reset = '1' OR rd_enable_1 = '0' THEN
            -- 0 and not Z since the first instruction can have problem 
            -- in data returning from EXE stage to the muxed
            rd_data_1 <= (OTHERS => '0');           
        ELSIF rd_enable_1 = '1' THEN
            rd_data_1 <= RegFile(to_integer(unsigned(rd_addr_1)));    
        END IF;
    END PROCESS ReadProcessOne;
    
    -- Asynchronous read
    ReadProcessTwo: PROCESS(reset, RegFile, rd_enable_2, rd_addr_2)
    BEGIN 
        IF reset = '1' OR rd_enable_2 = '0' THEN
            -- 0 and not Z since the first instruction can have problem 
            -- in data returning from EXE stage to the muxed
            rd_data_2 <= (OTHERS => '0');
        ELSIF rd_enable_2 = '1' THEN
            rd_data_2 <= RegFile(to_integer(unsigned(rd_addr_2)));    
        END IF;
    END PROCESS ReadProcessTwo;
    
END Behavioral;
