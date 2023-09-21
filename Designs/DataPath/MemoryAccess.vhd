LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY MEMORY_ACCESS is
    PORT(CLOCK, RESET: IN std_logic;
         
         -- Control unit signals
         EN_REG, SET_IR: IN std_logic;
         COND_IN, S_MUX_LMD: IN std_logic;

         -- Data from EXE stage
         -- NEXT_PC represents the program counter of the next instruction to fetch in the case that the branch
         -- was not taken. NPC_IN represents the NPC computed when the current instruction was fetched. It is useful for storing
         -- the return address of a JAL instruction.
         NEXT_PC: IN std_logic_vector(31 DOWNTO 0);
         NPC_IN: IN std_logic_vector(31 DOWNTO 0);
         IR_IN, ALU_OUT, DATA_MEM_IN: IN std_logic_vector (31 DOWNTO 0);

         -- Program counter produced after eval of branching conditions
         NEW_PC: OUT std_logic_vector (31 DOWNTO 0);

         -- Program counter to go to WB stage
         NPC_OUT: OUT std_logic_vector(31 DOWNTO 0);

        -- Address and data for writing on RF
         WR_ADDR: OUT std_logic_vector (31 DOWNTO 0);
         WR_DATA: OUT std_logic_vector (31 DOWNTO 0);
         IR_OUT: OUT std_logic_vector (31 DOWNTO 0));
END MEMORY_ACCESS;

ARCHITECTURE Structural of MEMORY_ACCESS IS

    SIGNAL LMD_IN, IR_REG_IN, ADDR_IN: std_logic_vector(31 DOWNTO 0);
    SIGNAL ADDR_EXTRACTED: std_logic_vector(4 DOWNTO 0);

    COMPONENT MUX21_GENERIC IS
        GENERIC(NBIT: integer:= NumBit);
        
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
            SEL: IN std_logic;
            Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT REGISTER_GENERIC IS
        GENERIC(NBIT: integer := NumBit);
        
        PORT(DATA_IN: IN std_logic_vector(NBIT-1 DOWNTO 0);
             CLK, RESET, ENABLE, SET: IN std_logic;
             DATA_OUT: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT OUT_EXTRACTOR IS
        PORT(IR: IN std_logic_vector(31 DOWNTO 0);
             ADDR: OUT std_logic_vector(4 DOWNTO 0));
    END COMPONENT;

BEGIN

    IR_REG_IN <= IR_IN;

    -- Multiplexer for computing new program counter after a conditional branch
    MUX_PC: MUX21_GENERIC GENERIC MAP (NumBit) 
                          PORT MAP (A => ALU_OUT, B => NEXT_PC, 
                                    SEL => COND_IN, 
                                    Y => NEW_PC);

    -- Multiplexer for computing data to write in regster file
    MUX_LMD : MUX21_GENERIC GENERIC MAP (NumBit)
                            PORT MAP (A => ALU_OUT, B => DATA_MEM_IN, 
                                      SEL => S_MUX_LMD, 
                                      Y => LMD_IN);
    
    -- LMD register
    LMD_REGISTER: REGISTER_GENERIC GENERIC MAP (NumBit) 
                                   PORT MAP (DATA_IN => LMD_IN, 
                                             CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                             DATA_OUT => WR_DATA);

  	-- Instruction register for WB stage
    INSTRUCTION_REGISTER_4: REGISTER_GENERIC GENERIC MAP (NumBit) 
                                             PORT MAP (DATA_IN => IR_REG_IN, 
                                                       CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => SET_IR, 
                                                       DATA_OUT => IR_OUT);

    -- Instruction register address for write back in RF extractor
    IR_EXTRACTOR: OUT_EXTRACTOR PORT MAP (IR => IR_REG_IN, ADDR => ADDR_EXTRACTED);
    ADDR_IN <= "000000000000000000000000000" & ADDR_EXTRACTED;

    -- Register for containing address of RF write
    ADDRESS_REGISTER: REGISTER_GENERIC GENERIC MAP (NumBit) 
                                       PORT MAP (DATA_IN => ADDR_IN, 
                                                 CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                                 DATA_OUT => WR_ADDR);

    -- NPC register
    NPC : REGISTER_GENERIC GENERIC MAP(NumBit) 
                           PORT MAP (DATA_IN => NPC_IN, 
                                     CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                     DATA_OUT => NPC_OUT);    

END Structural;