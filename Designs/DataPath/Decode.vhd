LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DECODE is
    PORT(CLOCK, RESET: IN std_logic;

         -- Control Unit signals
         EN_REG, SET_IR: IN std_logic;
         RD_ENABLE_1, RD_ENABLE_2, ENABLE_WR: IN std_logic;
         SEL_MUX_A, SEL_MUX_B, SEL_SIGNEXT_OPTYPE, SEL_IMM_LOAD: IN std_logic;

         -- For branch management
         BranchTaken: IN std_logic;
         NPC_IN: IN std_logic_vector (31 DOWNTO 0);

         -- Instruction register from IF stage
         IR_IN: IN std_logic_vector (31 DOWNTO 0);
         
         -- Data to write on RF by write back stage
         WR_ADDR: IN std_logic_vector (4 DOWNTO 0);
         WB_DATA: IN std_logic_vector (31 DOWNTO 0);

         -- Registers to write for EXE stage
         A_OUT, B_OUT, IMM_OUT, IR_OUT, NPC_OUT: OUT std_logic_vector (31 DOWNTO 0));
END DECODE;

ARCHITECTURE Structural of DECODE is

    SIGNAL SIGN_EXTENDED_IMM, SIGN_EXTENDED_LOAD, IMM_IN : std_logic_vector (31 DOWNTO 0);
    SIGNAL A_IN, B_IN, RD_1, RD_2: std_logic_vector (31 DOWNTO 0);
    SIGNAL setIR_s: std_logic;

    COMPONENT REGISTER_GENERIC IS
        GENERIC(NBIT: integer := NumBit);
        
        PORT(DATA_IN: IN std_logic_vector(NBIT-1 DOWNTO 0);
             CLK, RESET, ENABLE, SET: IN std_logic;
             DATA_OUT: OUT std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT SIGN_EXT_16_TO_32 IS
        PORT(A : IN std_logic_vector (15 DOWNTO 0);
             
             -- 0: Normal operation; 1: Logic operation
             OPTYPE: IN std_logic;
             B : OUT std_logic_vector (31 DOWNTO 0));
    END COMPONENT;

	COMPONENT SIGN_EXT_26_TO_32 IS
    	PORT(A : IN std_logic_vector (25 DOWNTO 0);
        	 B : OUT std_logic_vector (31 DOWNTO 0));
	END COMPONENT;

	COMPONENT MUX21_GENERIC IS
		GENERIC(NBIT: integer:= NumBit);

		PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
			 SEL: IN std_logic;
		     Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

    COMPONENT RegisterFile IS
        GENERIC(ADDRESS_WIDTH: integer := 5;
                DATA_WIDTH: integer := 32);

        PORT(clock, reset: IN std_logic;
            wr_data: IN std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
            wr_addr: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
            wr_enable: IN std_logic;
            rd_data_1: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
            rd_addr_1: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
            rd_enable_1: IN std_logic;           
            rd_data_2: OUT std_logic_vector(DATA_WIDTH-1 DOWNTO 0);
            rd_addr_2: IN std_logic_vector(ADDRESS_WIDTH-1 DOWNTO 0);
            rd_enable_2: IN std_logic);
    END COMPONENT;

BEGIN

    setIR_s <= SET_IR OR BranchTaken;

    -- Register file
    REGISTER_FILE : RegisterFile GENERIC MAP (ADDRESS_WIDTH, DATA_WIDTH)
                                 PORT MAP (clock => CLOCK, reset => RESET,
                                           wr_data => WB_DATA,              -- FROM WB stage
                                           wr_addr => WR_ADDR,-------------------------------------------------
                                           wr_enable => ENABLE_WR,			-- FROM CU
                                           rd_data_1 => RD_1,
                                           rd_addr_1 => IR_IN(25 DOWNTO 21),
                                           rd_enable_1 => RD_ENABLE_1,		-- FROM CU          
                                           rd_data_2 => RD_2,
                                           rd_addr_2 => IR_IN(20 DOWNTO 16),
                                           rd_enable_2 => RD_ENABLE_2);	    -- FROM CU
	-- MUX 2 TO 1 A
	MUX_A : MUX21_GENERIC GENERIC MAP (NumBit) 
                          PORT MAP (A => WB_DATA, B => RD_1, 
                                    SEL => SEL_MUX_A, 
                                    Y => A_IN);

	-- MUX 2 TO 1 B
	MUX_B : MUX21_GENERIC GENERIC MAP (NumBit) 
                          PORT MAP (A => WB_DATA, B => RD_2, 
                                    SEL => SEL_MUX_B, 
                                    Y => B_IN);

    -- Register A portmap
    A_REGISTER : REGISTER_GENERIC GENERIC MAP (NumBit) 
                                  PORT MAP (DATA_IN => A_IN, 
                                            CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                            DATA_OUT => A_OUT);

    -- Register B portmap
    B_REGISTER : REGISTER_GENERIC GENERIC MAP(NumBit) 
                                  PORT MAP (DATA_IN => B_IN, 
                                            CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                            DATA_OUT => B_OUT);

    -- Sign extension for IMMEDIATE portmap
    SIGN_EXTENSION : SIGN_EXT_16_TO_32 PORT MAP(A => IR_IN(15 DOWNTO 0), OPTYPE => SEL_SIGNEXT_OPTYPE, B => SIGN_EXTENDED_IMM);

	-- Sign extension for JUMP/JAL operations
	SIGN_EXTENSION_LOAD : SIGN_EXT_26_TO_32 PORT MAP(A => IR_IN(25 DOWNTO 0), B => SIGN_EXTENDED_LOAD);

	-- MUX 2 TO 1
	MUX_2_TO_1_IMM_LOAD : MUX21_GENERIC GENERIC MAP(NumBit) 
                                        PORT MAP(A => SIGN_EXTENDED_LOAD, B => SIGN_EXTENDED_IMM, 
                                                 SEL => SEL_IMM_LOAD, 
                                                 Y => IMM_IN);

    -- Immediate or target address register portmap
    IMM_LOAD_REGISTER : REGISTER_GENERIC GENERIC MAP(NumBit) 
                                         PORT MAP(DATA_IN => IMM_IN, 
                                                  CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                                  DATA_OUT => IMM_OUT);
    
    -- IR replication portmap
    INSTRUCTION_REGISTER_2 : REGISTER_GENERIC GENERIC MAP(NumBit) 
                                              PORT MAP (DATA_IN => IR_IN, 
                                                        CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => setIR_s, 
                                                        DATA_OUT => IR_OUT);
    
    -- NPC replication portmap
    NPC: REGISTER_GENERIC GENERIC MAP(NumBit) 
                          PORT MAP (DATA_IN => NPC_IN, 
                                    CLK => CLOCK, RESET => RESET, ENABLE => EN_REG, SET => '0', 
                                    DATA_OUT => NPC_OUT);

END Structural;