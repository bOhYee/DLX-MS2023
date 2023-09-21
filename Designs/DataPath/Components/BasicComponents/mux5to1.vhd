LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.all;
USE WORK.Globals.ALL;
 
ENTITY MUX_5TO1 IS 
    GENERIC(NBIT: integer:= NumBit);

    PORT(A,B,C,D,E: in std_logic_vector(NumBit-1 DOWNTO 0);
         S: in std_logic_vector(2 DOWNTO 0);
         Z: out std_logic_vector(NumBit-1 DOWNTO 0));
END MUX_5TO1;

ARCHITECTURE STRUCTURAL OF MUX_5TO1 IS 

    COMPONENT MUX21_GENERIC 
        GENERIC(NBIT: integer:= NumBit);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             SEL: IN std_logic;
             Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
    SIGNAL Y0, Y1, Y2: std_logic_vector(NumBit-1 DOWNTO 0);
    
BEGIN
    
    MUX0: MUX21_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => A, B => B, SEL => NOT(S(0)), Y => Y0);
    MUX1: MUX21_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => C, B => D, SEL =>  NOT(S(0)), Y => Y1);
    MUX2: MUX21_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => Y0, B => Y1, SEL =>  NOT(S(1)), Y => Y2);
    MUX3: MUX21_GENERIC GENERIC MAP (NBIT => NumBit) PORT MAP (A => Y2, B => E, SEL =>  NOT(S(2)), Y => Z);
    
END STRUCTURAL;