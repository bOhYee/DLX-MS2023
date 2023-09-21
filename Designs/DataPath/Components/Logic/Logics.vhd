LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY Logics IS 
    GENERIC (N: integer := NumBit);
    
    PORT (SEL: IN std_logic_vector(3 DOWNTO 0);
          R1, R2: IN std_logic_vector(N-1 DOWNTO 0);
          Y: OUT std_logic_vector(N-1 DOWNTO 0));
END Logics;

ARCHITECTURE Structural OF Logics IS 

    SIGNAL SEL_0, SEL_1, SEL_2, SEL_3: std_logic_vector(31 DOWNTO 0);
   
    COMPONENT NAND3_GENERIC
        GENERIC(N: integer := NumBit);
        
        PORT(A, B, C: IN std_logic_vector(N-1 DOWNTO 0);
             Y: OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT NAND4_GENERIC
        GENERIC(N: integer:= NumBit);
    
        PORT(A, B, C, D: IN std_logic_vector(N-1 DOWNTO 0);
             Y: OUT std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;
    
    COMPONENT IV_GENERIC 
        GENERIC(NBIT: integer := NumBit);
    
        PORT(A:	IN std_logic_vector(N-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(N-1 DOWNTO 0));
    END COMPONENT;
   
SIGNAL R1_Inv, R2_Inv : std_logic_vector(N-1 DOWNTO 0);
SIGNAL L0, L1, L2, L3 : std_logic_vector(N-1 DOWNTO 0);
 
BEGIN 
    SEL_0 <= (OTHERS => SEL(0));
    SEL_1 <= (OTHERS => SEL(1));
    SEL_2 <= (OTHERS => SEL(2));
    SEL_3 <= (OTHERS => SEL(3));

    IV0: IV_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => R1, Y => R1_Inv);
    IV1: IV_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => R2, Y => R2_Inv);
    
    NAND3_0 : NAND3_GENERIC GENERIC MAP (N =>  NumBit) PORT MAP (A => SEL_0, B => R1_Inv, C => R2_Inv, Y => L0);
    NAND3_1 : NAND3_GENERIC GENERIC MAP (N =>  NumBit) PORT MAP (A => SEL_1, B => R1_Inv, C => R2, Y => L1);
    NAND3_2 : NAND3_GENERIC GENERIC MAP (N =>  NumBit) PORT MAP (A => SEL_2, B => R1, C => R2_Inv, Y => L2);
    NAND3_3 : NAND3_GENERIC GENERIC MAP (N =>  NumBit) PORT MAP (A => SEL_3, B => R1, C => R2, Y => L3);
    
    NAND4_0 : NAND4_GENERIC GENERIC MAP (N =>  NumBit) PORT MAP (A => L0, B => L1, C => L2, D => L3, Y => Y);
    
END Structural;