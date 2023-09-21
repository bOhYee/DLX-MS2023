LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.Globals.ALL;
 
ENTITY MUX_8TO1 IS 
    GENERIC(NBIT : integer := NumBit);
    
    PORT(A,B,C,D,E,F,G,H: in std_logic_vector(NBIT-1 DOWNTO 0);
         S: in std_logic_vector(2 DOWNTO 0);
         Z: out std_logic_vector(NBIT-1 DOWNTO 0));
END MUX_8TO1;

ARCHITECTURE STRUCTURAL OF MUX_8TO1 IS 

    SIGNAL Y0, Y1 : std_logic_vector(NBIT-1 DOWNTO 0);
    SIGNAL Sel : std_logic_vector (2 DOWNTO 0);

    COMPONENT MUX21_GENERIC 
        GENERIC(NBIT: integer:= NBIT);
    
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
             SEL: IN std_logic;
             Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT MUX_4TO1
        GENERIC(NBIT: integer:= NumBit);
        
        PORT(A,B,C,D: in std_logic_vector(NBIT-1 DOWNTO 0);
             S: in std_logic_vector(1 DOWNTO 0);
             Z: out std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;
    
BEGIN

    Sel <= S;
    
    MUX0: MUX_4TO1 GENERIC MAP (NBIT => NBIT) PORT MAP (A => A, B => B, C => C, D => D, S => Sel(1 DOWNTO 0), Z => Y0);
    MUX1: MUX_4TO1 GENERIC MAP (NBIT => NBIT) PORT MAP (A => E, B => F, C => G, D => H, S =>  Sel(1 DOWNTO 0), Z => Y1);
    MUX2: MUX21_GENERIC GENERIC MAP (NBIT => NBIT) PORT MAP (A => Y1, B => Y0, SEL =>  Sel(2), Y => Z);
    
END STRUCTURAL;