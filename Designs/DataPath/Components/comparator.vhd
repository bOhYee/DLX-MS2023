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
SIGNAL tmp : std_logic_vector(NBIT DOWNTO 0) := (OTHERS => '0'); 
 
BEGIN
    z_calculation : FOR i IN 0 TO NBIT-1 GENERATE 
        tmp(i+1) <= tmp(i) OR sum(i);
    END GENERATE;
    
    iv_0 : IV_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => tmp(NBIT), Y(0) => Z); -- For Z
    
    iv_1 : IV_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => carry, Y(0) => not_carry); -- not_carry
    
    -- To select carry that takes into account the possibile overflow
    mux2to1_0: MUX21_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => not_carry, B(0) => carry, SEL => overflow, Y(0) => C);  
    
    iv_2 : IV_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => Z, Y(0) => isNotEqual);
    
    iv_3 : IV_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => C, Y(0) => isLess);    
    
    or_0 : OR2_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => isLess, B(0) => Z, Y(0) => isLessEqual); 
    and_0: AND2_GENERIC GENERIC MAP (NBIT => 1) PORT MAP (A(0) => C, B(0) => isNotEqual, Y(0) => isGreater);
    isGreaterEqual <= C;
    isEqual <= Z;
    
    mux8to1_0 : MUX_8TO1 GENERIC MAP (NBIT => 1) PORT MAP (A(0) => isLessEqual, 
                        B(0) => isLess, C(0) => isGreater, D(0) => isGreaterEqual, E(0) =>  isEqual, 
                        F(0) => isNotEqual, G(0) => '0', H(0) => '0', S => sel, Z(0) => result);

END Structural;