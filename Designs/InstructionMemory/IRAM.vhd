LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;
USE IEEE.std_logic_textio.ALL;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
ENTITY IRAM IS
    GENERIC(RAM_DEPTH : integer := 96;
            I_SIZE : integer := 32);
    
    PORT(Rst, enable: IN  std_logic;
         Addr: IN std_logic_vector(I_SIZE - 1 DOWNTO 0);
         ready: OUT std_logic;
         Dout: OUT std_logic_vector(I_SIZE - 1 DOWNTO 0));
END IRAM;

ARCHITECTURE Behavioral OF IRAM IS

    TYPE RAMtype IS ARRAY (0 to RAM_DEPTH - 1) of integer;
    SIGNAL IRAM_mem : RAMtype;

BEGIN
    
    RecValue: PROCESS(IRAM_mem, Addr, enable)
    VARIABLE index: integer;
    BEGIN
        index := to_integer(unsigned(Addr)) / 4;
        
        IF enable = '1' THEN
            Dout <= std_logic_vector(to_unsigned(IRAM_mem(index), I_SIZE));
            ready <= '1';
        ELSE
            Dout <= (OTHERS => 'Z');
            ready <= '0';
        END IF;
    END PROCESS RecValue;

    -- This process is in charge of filling the Instruction RAM with the firmware
    FILL_MEM_P: PROCESS(Rst)
    FILE mem_fp: text;
    VARIABLE file_line : line;
    VARIABLE index : integer;
    VARIABLE tmp_data_u : std_logic_vector(I_SIZE-1 DOWNTO 0);
    BEGIN
        index := 0;
        
        IF (Rst = '1') THEN
            file_open(mem_fp,"test.asm.mem",READ_MODE);
            
            WHILE (NOT endfile(mem_fp)) LOOP
                readline(mem_fp,file_line);
                hread(file_line,tmp_data_u);
                IRAM_mem(index) <= to_integer(unsigned(tmp_data_u));       
                index := index + 1;
            END LOOP;
        END IF;
    END PROCESS FILL_MEM_P;

END Behavioral;