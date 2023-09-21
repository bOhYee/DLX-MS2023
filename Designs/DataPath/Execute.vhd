LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY EXECUTE IS
    PORT(CLOCK, RESET: IN std_logic;

        -- For branch management
        CounterOver: IN std_logic;
        BranchTaken: OUT std_logic;
        
         -- Control signals from CU
         EN_REG, SET_IR: IN std_logic;
		 SEL_MUX_A, SEL_MUX_B, SEL_MUX_ZERO, SEL_MUX_MEM: IN std_logic_vector (1 DOWNTO 0);
		 ALU_SEL: IN std_logic_vector (EXE_WIDTH_ALU-1 DOWNTO 0);
         
         -- Data from previous stages
         A_IN, B_IN, IMM_IN, NPC_IN, IR_IN: IN std_logic_vector (31 DOWNTO 0);

         -- Data from MEM stage for forwarding purposes
         DATA_FROM_MEM: IN std_logic_vector (31 DOWNTO 0);

         -- Produced output values
         COND_OUT: OUT std_logic;
         ALU_OUT, IR_OUT, B_OUT, NPC_OUT: OUT std_logic_vector (31 DOWNTO 0));
END EXECUTE;

ARCHITECTURE Structural of EXECUTE is

    SIGNAL ALU_RES, ALU_REG, ALU_IN_1, ALU_IN_2, Z_IN, B_FORW_SW : std_logic_vector (31 DOWNTO 0);
    SIGNAL MUX_PC: std_logic;
    SIGNAL REG_COND_IN, REG_COND_OUT: std_logic_vector(31 DOWNTO 0);
	SIGNAL Z_OUT : std_logic;
    SIGNAL BranchTaken_s, setIR_s: std_logic;

    COMPONENT REGISTER_GENERIC is
        GENERIC(NBIT: integer := NumBit);
        
        PORT(DATA_IN: IN std_logic_vector(NBIT-1 DOWNTO 0);
             CLK, RESET, ENABLE, SET: IN std_logic;
             DATA_OUT: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT MUX_4TO1 is
        GENERIC(NBIT: integer:= NumBit);

        PORT(A,B,C,D: in std_logic_vector(NBIT-1 DOWNTO 0);

             S: in std_logic_vector(1 DOWNTO 0);
             Z: out std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT ZEROS IS
        PORT(A: IN std_logic_vector (31 DOWNTO 0);
             B: OUT std_logic);
    END COMPONENT;

	COMPONENT ALU IS
        PORT(CLOCK: IN std_logic;

             -- Input operands
             A, B: IN  std_logic_vector(31 DOWNTO 0);  

             -- For function selection
             ALU_SEL: IN  std_logic_vector (EXE_WIDTH_ALU-1 DOWNTO 0);  
 
             -- Output to produce
             ALU_OUT: OUT std_logic_vector(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT COND is
		PORT(ZEROS_OUT: IN std_logic;
             IR: IN std_logic_vector (31 DOWNTO 0);
             B: OUT std_logic);
	END COMPONENT;

BEGIN

    ALU_OUT <= ALU_REG;
    COND_OUT <= REG_COND_OUT(0);
    BranchTaken <= BranchTaken_s;

    BranchTaken_s <= CounterOver AND REG_COND_OUT(0);
    setIR_s <= BranchTaken_s OR SET_IR;
    
    -- ALU OUT register
    ALU_OUT_REGISTER: REGISTER_GENERIC GENERIC MAP(NumBit) 
                                       PORT MAP(DATA_IN => ALU_RES, 
                                                CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                                DATA_OUT => ALU_REG);
    
    -- First input of ALU: A
    MUX_1 : MUX_4TO1 PORT MAP(A => DATA_FROM_MEM, B => ALU_REG, C => A_IN, D => NPC_IN, 
                              S => SEL_MUX_A, 
                              Z => ALU_IN_1);

    -- Second input of ALU: B
    MUX_2 : MUX_4TO1 PORT MAP(A => DATA_FROM_MEM, B => ALU_REG, C => B_IN, D => IMM_IN, 
                              S => SEL_MUX_B, 
                              Z => ALU_IN_2);

    
    -- ALU component
	ALU_BLOCK : ALU PORT MAP(CLOCK => CLOCK, A => ALU_IN_1, B => ALU_IN_2, 
                             ALU_SEL => ALU_SEL,
                             ALU_OUT => ALU_RES);

    -- Multiplexer for ZEROS block: used by branch operations
    MUX_3 : MUX_4TO1 GENERIC MAP(NBIT => NumBit)
                     PORT MAP(A => DATA_FROM_MEM, B => ALU_REG, C => A_IN, D => NPC_IN,
                              S => SEL_MUX_ZERO, 
                              Z => Z_IN);

    -- Multiplexer for forwarding the right value to store in memory (DRAM)
    MUX_4 : MUX_4TO1 GENERIC MAP(NBIT => NumBit)
                     PORT MAP(A => B_IN, B => DATA_FROM_MEM, C => ALU_REG, D => ALU_REG,
                              S => SEL_MUX_MEM, 
                              Z => B_FORW_SW);                            

    -- Data to write for STORE operations: B (rt)
    STORE_REGISTER: REGISTER_GENERIC GENERIC MAP(NumBit) 
                                     PORT MAP (DATA_IN => B_FORW_SW, 
                                               CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                               DATA_OUT => B_OUT);

    -- Zero detection block
    ZERO_BLOCK : ZEROS PORT MAP(A => Z_IN, B => Z_OUT);

    -- COND block
    COND_BLOCK : COND PORT MAP(ZEROS_OUT => Z_OUT, 
                               IR => IR_IN,
                               B => MUX_PC);

    -- IR replication portmap
    INSTRUCTION_REGISTER_3 : REGISTER_GENERIC GENERIC MAP(NumBit) 
                                              PORT MAP (DATA_IN => IR_IN, 
                                                        CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => setIR_s, 
                                                        DATA_OUT => IR_OUT);

    -- COND result registered in a register since the mux operates at the next stage
    REG_COND_IN <= "0000000000000000000000000000000" & MUX_PC;
    COND_REGISTER : REGISTER_GENERIC GENERIC MAP(NumBit) 
                                     PORT MAP (DATA_IN => REG_COND_IN, 
                                               CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                               DATA_OUT => REG_COND_OUT);

    -- NPC register
    NPC : REGISTER_GENERIC GENERIC MAP(NumBit) 
                           PORT MAP (DATA_IN => NPC_IN, 
                                     CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                     DATA_OUT => NPC_OUT);

END Structural;