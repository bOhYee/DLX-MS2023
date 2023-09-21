LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DOWN_COUNTER IS 
    GENERIC(START_VALUE: integer := 1);

    PORT(clock, reset, enable: IN std_logic;
         ZeroReached: OUT std_logic);
END DOWN_COUNTER;

ARCHITECTURE BEHAVIORAL OF DOWN_COUNTER IS

    SIGNAL Count: integer;

BEGIN

    PROCESS (clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF reset = '1' THEN
                Count <= START_VALUE;
            ELSIF enable = '1' THEN
                Count <= Count - 1;
            END IF;
        END IF;
    END PROCESS;

    ZeroReached <= '1' WHEN Count = 0 ELSE '0';

END BEHAVIORAL;