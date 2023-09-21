LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY FETCH IS
    PORT(CLOCK, RESET, EN_REG_F, SET_IR: IN std_logic;

         -- From Control Unit to handle PC multiplexer
         S_MUX_PC: IN std_logic;

         -- For branch management
         BranchTaken: IN std_logic;

         -- Data from IRAM
         IMEM_IN: IN std_logic_vector (31 DOWNTO 0);
        
         -- Program counter computed in MEM stage for branching operations
         MEM_PC: IN std_logic_vector (31 DOWNTO 0);

         -- Program counter value to go towards the IRAM for accessing next instruction
         MEM_ADDR: OUT std_logic_vector (31 DOWNTO 0);
         
        -- To memory stage in case branch is not to be performed
         CURR_NPC_OUT: OUT std_logic_vector (31 DOWNTO 0);
         
         -- To decode stage
         NPC_OUT, IR_OUT: OUT std_logic_vector (31 DOWNTO 0));
END FETCH;

ARCHITECTURE Structural OF FETCH IS

    SIGNAL NPC_IN : std_logic_vector (31 DOWNTO 0);
	SIGNAL PC_IN : std_logic_vector (31 DOWNTO 0);
	SIGNAL NPC_RET : std_logic_vector (31 DOWNTO 0);
    SIGNAL PC_OUT: std_logic_vector(31 DOWNTO 0);
    SIGNAL setIR_s: std_logic;

    COMPONENT REGISTER_GENERIC IS
        GENERIC(NBIT: integer := NumBit);
        
        PORT(DATA_IN: IN std_logic_vector(NBIT-1 DOWNTO 0);
             CLK, RESET, ENABLE, SET: IN std_logic;
             DATA_OUT: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT Adder_PC is
        port(A: IN std_logic_vector(31 DOWNTO 0);
             SUM : OUT std_logic_vector (31 DOWNTO 0));
    END COMPONENT;

	COMPONENT MUX21_GENERIC IS
		GENERIC(NBIT: integer:= NumBit);
                
		PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
			 SEL: IN std_logic;
			 Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

BEGIN

    CURR_NPC_OUT <= NPC_RET;
	NPC_IN <= NPC_RET;
    MEM_ADDR <= PC_OUT;
    setIR_s <= SET_IR OR BranchTaken;

    -- Program counter component
    PROGRAM_COUNTER : REGISTER_GENERIC PORT MAP (DATA_IN => PC_IN, 
                                                 CLK => CLOCK, RESET => RESET, ENABLE => EN_REG_F, SET => '0', 
                                                 DATA_OUT => PC_OUT);

    -- Adder +4 to the PC instruction
    ADDER_PLUS_FOR : Adder_PC PORT MAP (A => PC_OUT, SUM => NPC_RET);

    -- NPC register
    NPC_REGISTER : REGISTER_GENERIC GENERIC MAP (NumBit) 
                                    PORT MAP (DATA_IN => NPC_IN, 
                                              CLK => CLOCK, RESET => RESET, ENABLE => EN_REG_F, SET => '0', 
                                              DATA_OUT => NPC_OUT);

	-- MUX 2 TO 1 FOR THE PROGRAM COUNTER
	MUX_PC : MUX21_GENERIC GENERIC MAP (NumBit) 
                           PORT MAP (A => MEM_PC, B => NPC_RET, 
                                     SEL => S_MUX_PC, 
                                     Y => PC_IN);

    -- IR register
    INSTRUCTION_REGISTER_1 : REGISTER_GENERIC GENERIC MAP (NumBit) 
                                              PORT MAP (DATA_IN => IMEM_IN, 
                                                        CLK => CLOCK, RESET => RESET, ENABLE => EN_REG_F, SET => setIR_s, 
                                                        DATA_OUT => IR_OUT);

END Structural;