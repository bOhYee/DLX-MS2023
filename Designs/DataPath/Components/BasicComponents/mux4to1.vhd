LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;
 
ENTITY MUX_4TO1 IS
    GENERIC(NBIT: integer:= NumBit);
    
    PORT(A,B,C,D: in std_logic_vector(NBIT-1 DOWNTO 0);
         S: in std_logic_vector(1 DOWNTO 0);
         Z: out std_logic_vector(NBIT-1 DOWNTO 0));
END MUX_4TO1;

ARCHITECTURE STRUCTURAL OF MUX_4TO1 IS 

    COMPONENT MUX21_GENERIC 
        GENERIC(NBIT: integer:= NumBit);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             SEL: IN std_logic;
             Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    SIGNAL Y0, Y1: std_logic_vector(NBIT-1 DOWNTO 0);
    SIGNAL Sel : std_logic_vector (1 DOWNTO 0);
    
BEGIN

    Sel <= NOT(S);
    
    MUX0: MUX21_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => A, B => B, SEL => Sel(0), Y => Y0);
    MUX1: MUX21_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => C, B => D, SEL =>  Sel(0), Y => Y1);
    MUX2: MUX21_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => Y0, B => Y1, SEL =>  Sel(1), Y => Z);
    
END STRUCTURAL;