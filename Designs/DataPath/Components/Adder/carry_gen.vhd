LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.math_real.ALL;
USE WORK.Globals.ALL;

ENTITY CARRY_GENERATOR IS
    GENERIC(NBIT: integer := NumBit;
            NSTAGES: integer := NumStages);

    PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
         Cin: IN std_logic;
         Overflow: OUT std_logic;
         Carries: OUT std_logic_vector(NSTAGES DOWNTO 0));
END CARRY_GENERATOR;

ARCHITECTURE STRUCTURAL OF CARRY_GENERATOR IS 
    
    CONSTANT LEVELS: integer := integer(log2(real(NBIT)));
    CONSTANT BITS_PER_BLOCK: integer := NBIT/NSTAGES;    
    TYPE vectors IS ARRAY (0 TO LEVELS) OF std_logic_vector(NBIT DOWNTO 1);
    
    SIGNAL P, G: vectors;
    SIGNAL carrys: std_logic_vector(NSTAGES DOWNTO 0);
    
    COMPONENT PG_BLOCK IS
        PORT(Ph, Gh, Pl, Gl: IN std_logic;
             Phl, Ghl : OUT std_logic); 
    END COMPONENT;

    COMPONENT GENERATE_BLOCK IS
        PORT(Ph, Gh, Gl: IN std_logic;
             Ghl : OUT std_logic);  
    END COMPONENT;

    COMPONENT PG_NETWORK IS
        PORT (A, B : IN std_logic;
              P, G : OUT std_logic);
    END COMPONENT;
    
    COMPONENT PG_NETWORK_CIN IS
        PORT(A, B, CIn : IN std_logic;
             P, G : OUT std_logic);	
    END COMPONENT;

    COMPONENT OVERFLOW_GENERATOR IS
        GENERIC(NBIT: integer := NumBit);

        PORT(P, G: IN std_logic_vector(NBIT-1 DOWNTO 0);
             CIn, COut: IN std_logic;
             Overflow: OUT std_logic);
    END COMPONENT;
    
BEGIN
    
--    If carry isn't generated correctly and the ARCHITECTURE is on 32 bits use this to verify the results
--    If the results are correct then the process isn't acting as generic as i hoped
--    Carries(0) <= Cin;
--    Carries(1) <= G(2)(4);
--    Carries(2) <= G(3)(8);
--    Carries(3) <= G(4)(12);
--    Carries(4) <= G(4)(16);
--    Carries(5) <= G(5)(20);
--    Carries(6) <= G(5)(24);
--    Carries(7) <= G(5)(28);
--    Carries(8) <= G(5)(32);
    Carries <= carrys;

    -- Simple process to connect the output of Gs to the carry out signals
    -- in order for them to go towards the sum generator block 
    ConnectToCarries: PROCESS(Cin, G)
    VARIABLE index_c: integer;
    VARIABLE gap: integer;
    BEGIN
        index_c := 1;
        gap := 0;
        
        carrys(0) <= Cin; 
        FOR i IN 1 TO LEVELS LOOP
            gap := ((2**i) - (2**(i-1)))/BITS_PER_BLOCK;
            
            -- Since the gap is not big enough to fit more than one carry per level,
            -- once the carry is linked to the respective G signal, move to the next level
            IF (gap <= 1) AND (((2**i) mod BITS_PER_BLOCK) = 0) THEN
                carrys(index_c) <= G(i)(2**i);
                index_c := index_c + 1;
                NEXT;
            END IF;
            
            IF (gap > 1) THEN
                -- Decremental loop for generating the correct order of carry bits
                -- (otherwise we would have, for 4th level, G(4)(16) and then G(4)(12)
                FOR m IN gap-1 DOWNTO 0 LOOP
                    carrys(index_c) <= G(i)((2**i)-(m*BITS_PER_BLOCK));
                    index_c := index_c + 1;
                END LOOP;
            END IF;
        END LOOP;
    END PROCESS ConnectToCarries;

    -- Need to cycle between the different levels of the sparse tree carry generator structure
    -- Number of levels depends on the bits of the operands: n_levels = log_2(length(A)) + 1
    -- We start counting from 0 so we reach log_2(length(A)) at the end
    -- EX: A on 32 bits -> 6 levels
    -- EX: A on 8 bits -> 4 levels
    CYCLE_LEVELS: FOR i IN 0 TO LEVELS GENERATE
    
        -- Cycle through the bits contained in the input data to pass them to the various blocks
        CYCLE_BITS: FOR j IN 1 TO NBIT GENERATE
            
            -- First level: ALL pg blocks that interacts with the bits of the input operands
            PGNW: IF (i = 0) GENERATE
                -- First PG block must be different from the others if carry in is to be considered
                -- This allows for more flexibility of managing subtractions and compositions of same type adders      
                PGNW_CIN: IF ((j/(2**i)) = 1 AND (j mod (2**i)) = 0) GENERATE
                    PG_NW_BLOCK_CIN: PG_NETWORK_CIN PORT MAP(A => A(j-1), B => B(j-1), CIn => Cin, P => P(i)(j), G => G(i)(j));
                END GENERATE;
                
                -- All other PG blocks are standard: P = A XOR B; G = A * B
                PG_NW_BLOCKS: IF ((j/(2**i)) /= 1 AND (j mod (2**i)) = 0) GENERATE
                    PG_NW_BLOCK: PG_NETWORK PORT MAP(A => A(j-1), B => B(j-1), P => P(i)(j), G => G(i)(j));
                END GENERATE;  
            END GENERATE;
            
            -- Now, after the first level, we want to consider all of the levels which have only one G (generator) block
            -- To do this, we need to take into account the number of bits used by the RCA in the sum generator because we want a carry 
            -- for each group of bits -> BITS_PER_BLOCK = (N_BITS / NSTAGES)
            -- (2**i - 2**(i-1))/BITS_PER_BLOCK means that if between two levels the carry generated have a difference greater than the group of bits
            -- for the RCA we need more G blocks, otherwise we need only one for this level
            
            -- EX time: RCA of 4 bits
            -- i = 1 => (2 - 1)/4 <= 1 YES: only one G block
            -- i = 2 => (4 - 2)/4 <= 1 YES: only one G block
            -- i = 3 => (8 -4)/4 <= 1 YES: only one G block
            -- i = 4 => (16-8)/4 <= 1 NO: we need more than 1 G block. Precisely (16-8)/4 = 2 G blocks
            -- This is because between C_16 and C_8 we have C_12 to produce
            ONE_G_LEVELS: IF (i > 0) AND ((((2**i) - (2**(i-1)))/BITS_PER_BLOCK) <= 1) GENERATE
            
                -- G block is the first block so place it if quotient between j and 2**i is 1 (4 div 4 or 8 div 8)
                -- (2**i used because the first levels can be seen as a reversed binary tree)
                -- Otherwise PG (12 div 4 or 16 div 4 /= from 1 BUT 12 mod 4 or 16 mod 4 are 0)
                G_BLOCKS_0: IF ((j/(2**i)) = 1 AND (j mod (2**i)) = 0) GENERATE
                
                    G_BLOCK_0: GENERATE_BLOCK PORT MAP(Ph => P(i-1)(j), Gh => G(i-1)(j), Gl => G(i-1)(j-(2**(i-1))),
                                                       Ghl => G(i)(j));
                                                     
                END GENERATE;                                                     
                                         
                -- All other blocks are PG block
                -- We find them using the modulus since they are positioned at multiple of 2**i            
                PG_BLOCKS_0: IF ((j/(2**i)) /= 1 AND (j mod (2**i)) = 0) GENERATE
                     
                    PG_BLOCK_0: PG_BLOCK PORT MAP(Ph => P(i-1)(j), Gh => G(i-1)(j), Pl => P(i-1)(j-(2**(i-1))), Gl => G(i-1)(j-(2**(i-1))),
                                                  Phl => P(i)(j), Ghl => G(i)(j));   
                                                                               
                END GENERATE;
            END GENERATE;        
            
            -- This is performed for every level where there is more than one G block
            MORE_G_LEVELS: IF (i > 0) AND ((((2**i) - (2**(i-1)))/BITS_PER_BLOCK) > 1) GENERATE
            
                -- Same principle as before but with a little more complexity added
                -- We find the location of the first G but since we know that there is a gap bewteen THIS G and the PREVIOUS LEVEL G we go backwards with a loop 
                -- in order to add them. (((2**1) - (2**(i-1)))/BITS_PER_BLOCK) indicates how many blocks we need in total at the current level.
                -- (Problem is, simply put: we don't have the needed carry in between. For EX with RCA on 4 bits: current G produces C16 while the previous produces C8
                -- we need to include a G to produce also C12)
                G_BLOCKS_1: IF ((j/(2**i)) = 1 AND (j mod (2**i)) = 0) GENERATE
                
                    -- G block that we need to add following the reversed binary tree
                    G_BLOCK_1: GENERATE_BLOCK PORT MAP(Ph => P(i-1)(j), Gh => G(i-1)(j), Gl => G(i-1)(j-(2**(i-1))),
                                                         Ghl => G(i)(j));
                    
                    -- Intermediate G blocks
                    -- Inserted by going back of the RCA bits                                                        
                    G_BLOCKS_BACK: FOR m IN 1 TO ((((2**i) - (2**(i-1)))/BITS_PER_BLOCK)-1) GENERATE
                    
                        -- I tried to generalize the interconnections made at the 4th and 5th level 
                        -- but I didn't see any pattern to harness. This is all I could come up with for now.
                        G_BLOCKS_EVEN_BACK: IF ((i mod 2) = 0) GENERATE
                        
                            G_BLOCK_EVEN_BACK_0: GENERATE_BLOCK PORT MAP(Ph => P(i-m*2)(j-(BITS_PER_BLOCK*m)), Gh => G(i-m*2)(j-(BITS_PER_BLOCK*m)), Gl => G(i-1)(j-(2**(i-1))),
                                                                         Ghl => G(i)(j-(BITS_PER_BLOCK*m)));
                                                                
                        END GENERATE;

                        G_BLOCKS_ODD_BACK: IF ((i mod 2) /= 0) GENERATE
                        
                            G_BLOCK_ODD_BACK_0: GENERATE_BLOCK PORT MAP(Ph => P(i-m)(j-(BITS_PER_BLOCK*m)), Gh => G(i-m)(j-(BITS_PER_BLOCK*m)), Gl => G(i-1)(j-(2**(i-1))),
                                                                        Ghl => G(i)(j-(BITS_PER_BLOCK*m)));
                                                                    
                        END GENERATE;                                                         
                    END GENERATE;
                                                     
                END GENERATE; 
                
                -- Same thing as G blocks is applied here
                PG_BLOCKS_1: IF ((j/(2**i)) /= 1 AND (j mod (2**i)) = 0) GENERATE
                  
                    -- PG block that we need to add following the reversed binary tree
                    PG_BLOCK_1: PG_BLOCK PORT MAP(Ph => P(i-1)(j), Gh => G(i-1)(j), Pl => P(i-1)(j-(2**(i-1))), Gl => G(i-1)(j-(2**(i-1))),
                                                  Phl => P(i)(j), Ghl => G(i)(j));
                                                         
                    P_BLOCKS_BACK: FOR m IN 1 TO ((((2**i) - (2**(i-1)))/BITS_PER_BLOCK)-1) GENERATE
                    
                        -- I tried to generalize the interconnections made at the 4th and 5th level 
                        -- but I didn't see any pattern to harness. This is all I could come up with for now.
                        P_BLOCKS_EVEN_BACK: IF ((i mod 2) = 0) GENERATE
                        
                            P_BLOCK_EVEN_BACK_1: PG_BLOCK PORT MAP(Ph => P(i-m*2)(j-(BITS_PER_BLOCK*m)), Gh => G(i-m*2)(j-(BITS_PER_BLOCK*m)), Pl => P(i-1)(j-(2**(i-1))), Gl => G(i-1)(j-(2**(i-1))),
                                                                   Phl => P(i)(j-(BITS_PER_BLOCK*m)), Ghl => G(i)(j-(BITS_PER_BLOCK*m)));
                                                                                                                        
                        END GENERATE;
                        
                        P_BLOCKS_ODD_BACK: IF ((i mod 2) /= 0) GENERATE
                        
                            P_BLOCK_ODD_BACK_1: PG_BLOCK PORT MAP(Ph => P(i-m)(j-(BITS_PER_BLOCK*m)), Gh => G(i-m)(j-(BITS_PER_BLOCK*m)), Pl => P(i-1)(j-(2**(i-1))), Gl => G(i-1)(j-(2**(i-1))),
                                                                  Phl => P(i)(j-(BITS_PER_BLOCK*m)), Ghl => G(i)(j-(BITS_PER_BLOCK*m)));
                                                                                                                        
                        END GENERATE;
                                                         
                    END GENERATE;               
                           
                                                                     
                END GENERATE;
            END GENERATE;
        
        END GENERATE;
    END GENERATE;
    
    -- Check if overflow verifies
    OGEN: OVERFLOW_GENERATOR GENERIC MAP(NBIT => NBIT/NSTAGES)
                             PORT MAP(P => P(0)(NBIT DOWNTO NBIT+1-(NBIT/NSTAGES)),
                                      G => G(0)(NBIT DOWNTO NBIT+1-(NBIT/NSTAGES)),
                                      CIn => carrys(NSTAGES-1),
                                      COut => carrys(NSTAGES),
                                      Overflow => Overflow);

END STRUCTURAL;
















