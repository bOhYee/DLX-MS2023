LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY Comparator IS 
    GENERIC (NBIT: integer := NumBit);

    PORT (sum : IN std_logic_vector(NBIT-1 DOWNTO 0);
          carry, overflow : IN std_logic;
          sel : IN std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0);
          result : OUT std_logic);
END Comparator;


ARCHITECTURE Structural OF Comparator IS

    COMPONENT IV_GENERIC
        GENERIC(NBIT: integer := NumBit);
    
        PORT(A:	IN std_logic_vector(NBIT-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT OR2_GENERIC
        GENERIC(NBIT: integer := NumBit);
    
        PORT(A, B:	IN std_logic_vector(NBIT-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT AND2_GENERIC
        GENERIC(NBIT: integer := NumBit);
    
        PORT(A, B:	IN std_logic_vector(NBIT-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT MUX21_GENERIC
        GENERIC(NBIT: integer:= NumBit);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             SEL: IN std_logic;
             Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT MUX_8TO1 
        GENERIC(NBIT : integer := NumBit);
        PORT(A,B,C,D,E,F,G,H: in std_logic_vector(NBIT-1 DOWNTO 0);
             S: in std_logic_vector(2 DOWNTO 0);
             Z: out std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    SIGNAL Z, C, not_carry, isLessEqual, isLess, isGreater, isGreaterEqual, isEqual, isNotEqual : std_logic;
    SIGNAL tmp_not_carry, tmp_carry, tmp_C, tmp_isLessEqual, tmp_isLess, tmp_isGreater, tmp_isGreaterEqual, tmp_isEqual, tmp_isNotEqual, tmp_result : std_logic_vector(31 DOWNTO 0);
    SIGNAL tmp : std_logic_vector(NBIT DOWNTO 0);
     
BEGIN

    -- NOR result between all bits contained in tmp(NBIT)
    ProcZCalc: FOR i IN 0 TO NBIT-1 GENERATE 
        Sum0: IF (i = 0) GENERATE
            tmp(i+1) <= sum(i);
        END GENERATE;
        
        Sumi: IF (i > 0) GENERATE
            tmp(i+1) <= tmp(i) OR sum(i);
        END GENERATE;
    END GENERATE;        
    
    not_carry <= NOT(carry);
    Z <= NOT(tmp(NBIT));
    isNotEqual <= tmp(NBIT);

    
    -- To select carry that takes into account the possibile overflow
    tmp_not_carry <= (OTHERS => not_carry);
    tmp_carry <= (OTHERS => carry);

    mux2to1_0: MUX21_GENERIC GENERIC MAP (NBIT => 32) 
                             PORT MAP (A => tmp_not_carry, B => tmp_carry, 
                                       SEL => overflow, 
                                       Y => tmp_C);

    C <= tmp_C(0);                                       
    isLess <= NOT(C);

    isLessEqual <= isLess OR Z;
    isGreater <= C AND isNotEqual;
    isGreaterEqual <= C;
    isEqual <= Z;
    
    tmp_isLessEqual <= (OTHERS => isLessEqual);
    tmp_isLess <= (OTHERS => isLess);
    tmp_isGreater <= (OTHERS => isGreater);
    tmp_isGreaterEqual <= (OTHERS => isGreaterEqual);
    tmp_isEqual <= (OTHERS => isEqual);
    tmp_isNotEqual <= (OTHERS => isNotEqual);
    
    mux8to1_0 : MUX_8TO1 GENERIC MAP (NBIT => 32) PORT MAP (A => tmp_isLessEqual, B => tmp_isLess, C => tmp_isGreater, 
                                                            D => tmp_isGreaterEqual, E =>  tmp_isEqual, F => tmp_isNotEqual, G => (OTHERS => '0'), H => (OTHERS => '0'), 
                                                            S => sel, Z => tmp_result);
                        
    result <= tmp_result(0);

END Structural;