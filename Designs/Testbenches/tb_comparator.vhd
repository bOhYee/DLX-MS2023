LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE WORK.Globals.ALL;

ENTITY TB_COMPARATOR IS
END TB_COMPARATOR;

ARCHITECTURE TEST OF TB_COMPARATOR IS 

CONSTANT Period: Time := 20 ns;

SIGNAL sum_s : std_logic_vector(NumBit-1 DOWNTO 0);
SIGNAL sel_s : std_logic_vector(2 DOWNTO 0); 
SIGNAL C_s, overflow_s, result_s : std_logic;

COMPONENT Comparator
    GENERIC (NBIT: integer := NumBit);
    
    PORT (sum : IN std_logic_vector(NBIT-1 DOWNTO 0);
          carry, overflow : IN std_logic;
          sel : IN std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0);
          result : OUT std_logic);
		 
END COMPONENT;

BEGIN

    -- Unit to test
    DUT: Comparator GENERIC MAP (NBIT => NumBit) PORT MAP(sum => sum_s, carry => C_s, 
                            overflow => overflow_s, sel => sel_s, result => result_s);
    
    InputProcess: PROCESS 
    BEGIN     
        sum_s <= "00000000000000000000000000010000"; -- 32
        C_s <= '0';
        overflow_s <= '0';
        
        sel_s <= "000";
        WAIT FOR Period / 2;
        
        sel_s <= "001";
        WAIT FOR Period / 2;
        
        sel_s <= "010";
        WAIT FOR Period / 2;
        
        sel_s <= "011";
        WAIT FOR Period / 2;
        
        sel_s <= "100";
        WAIT FOR Period / 2;
        
        sel_s <= "101";
        WAIT FOR Period / 2;
        
        
        sum_s <= "01110010011001000001101001100011"; 
        C_s <= '1';
        overflow_s <= '1';
        
        sel_s <= "000";
        WAIT FOR Period / 2;
        
        sel_s <= "001";
        WAIT FOR Period / 2;
        
        sel_s <= "010";
        WAIT FOR Period / 2;
        
        sel_s <= "011";
        WAIT FOR Period / 2;
        
        sel_s <= "100";
        WAIT FOR Period / 2;
        
        sel_s <= "101";
        WAIT FOR Period / 2;
        
        WAIT;

    END PROCESS; 
    
END TEST;