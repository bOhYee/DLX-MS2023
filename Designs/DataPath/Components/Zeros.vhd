LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY ZEROS is
    GENERIC (NBIT : integer := NumBit);
    PORT(A: IN std_logic_vector (NBIT-1 DOWNTO 0);
         B: OUT std_logic);
END ZEROS;

ARCHITECTURE Structural OF ZEROS IS
    SIGNAL tmp : std_logic_vector(NBIT DOWNTO 0);
    
BEGIN
    
    result : FOR I IN 0 TO NumBit-1 GENERATE
        tmp (i+1) <= A(i) OR tmp(i);
    END GENERATE;
    
    B <= NOT (tmp(NBIT));
    
END Structural;