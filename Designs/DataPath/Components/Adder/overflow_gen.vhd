LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY OVERFLOW_GENERATOR IS
    GENERIC(NBIT: integer := NumBit);

    PORT(P, G: IN std_logic_vector(NBIT-1 DOWNTO 0);
         CIn, COut: IN std_logic;
         Overflow: OUT std_logic);
END OVERFLOW_GENERATOR;

ARCHITECTURE STRUCTURAL OF OVERFLOW_GENERATOR IS 

    SIGNAL Carries: std_logic_vector(NBIT-1 DOWNTO 0);
    SIGNAL Gs: std_logic_vector(NBIT DOWNTO 0);
    
    COMPONENT AND2_GENERIC IS
        GENERIC(NBIT: integer := NumBit);

        PORT(A, B:	IN std_logic_vector(NBIT-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT OR2_GENERIC IS
        GENERIC(NBIT: integer := NumBit);

        PORT(A, B:	IN std_logic_vector(NBIT-1 DOWNTO 0);
             Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

BEGIN

    Carries(0) <= CIn;
    Overflow <= COut XOR Carries(NBIT-1);

    CARRY_GEN_STRUCT_i: FOR i IN 1 TO NBIT-1 GENERATE

        AND_i: AND2_GENERIC GENERIC MAP(NBIT => 1)
                            PORT MAP(A => P(i-1 DOWNTO i-1), B => Carries(i-1 DOWNTO i-1), Y => Gs(i DOWNTO i));

        OR_i: OR2_GENERIC GENERIC MAP(NBIT => 1)
                          PORT MAP(A => G(i-1 DOWNTO i-1), B => Gs(i DOWNTO i), Y => Carries(i DOWNTO i));

    END GENERATE;
    
END STRUCTURAL;