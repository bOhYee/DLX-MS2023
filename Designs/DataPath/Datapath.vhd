LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY DLX_DP IS
    PORT(CLOCK, RESET: IN std_logic;
    
        -- Fetch stage
        IMEM_IN : IN std_logic_vector (31 DOWNTO 0);
        IMEM_ADDR: OUT std_logic_vector(31 DOWNTO 0);
        EN_FETCH, SET_IR1, S_MUX_PC: IN std_logic;
        IF_ID_Instruction: OUT std_logic_vector(31 DOWNTO 0);
        
        -- Decode stage
        EN_DECOD: IN std_logic;
        SEL_MUX_A1, SEL_MUX_B1, SEL_SIGNEXT_OPTYPE, SEL_IMM_LOAD, RD_ENABLE_1, RD_ENABLE_2, ENABLE_WR : IN std_logic;
        SET_IR2 : IN std_logic;
        Branch_cnt_reset, Branch_cnt_en: IN std_logic;
        ID_EXE_Instruction: OUT std_logic_vector(31 DOWNTO 0);
        IF_ID_IsBranch: OUT std_logic;
        ID_EXE_IsLoad: OUT std_logic;
        ID_EXE_HasDest: OUT std_logic;
        WB_HasDestA, WB_HasDestB: OUT std_logic;
        Branch_cnt_over: OUT std_logic;
                                                    
        -- Execution stage
        EN_EXECUTE, SET_IR3: IN std_logic;
        SEL_MUX_A2, SEL_MUX_B2, SEL_MUX_ZERO: IN std_logic_vector (1 DOWNTO 0);
        ALU_SEL: IN std_logic_vector (EXE_WIDTH_ALU-1 DOWNTO 0);
        DIV_cnt_reset, DIV_cnt_en: IN std_logic;
        EXE_MEM_Instruction: OUT std_logic_vector(31 DOWNTO 0);
        MEM_ADDR, MEM_DATA_WR: OUT std_logic_vector(31 DOWNTO 0);
        FW_A, FW_B: OUT std_logic_vector(1 DOWNTO 0);
        DIV_cnt_over: OUT std_logic;
        
        -- Memory and write back stage
        EN_MEMORY, SET_IR4, S_MUX_LMD : IN std_logic;
        RESULT : OUT std_logic_vector (31 DOWNTO 0);
        DATA_MEM_IN : IN std_logic_vector (31 DOWNTO 0);
        MEM_WB_Instruction: OUT std_logic_vector(31 DOWNTO 0)
    );         
END DLX_DP;

ARCHITECTURE Structural OF DLX_DP IS

    -- BRANCH MANAGEMENT 
    SIGNAL Branch_eval, BranchTaken_s: std_logic;
    SIGNAL CURR_NPC, NPC_IF, NPC_ID, NPC_EXE, NPC_MEM: std_logic_vector(31 DOWNTO 0);

    -- FETCH SIGNALS
    SIGNAL IR1, IR2, IR3, IR4 : std_logic_vector (31 DOWNTO 0);
    SIGNAL MEM_PC : std_logic_vector (31 DOWNTO 0);

    -- DECODE SIGNALS
    SIGNAL A, B, B_2, IMM_LOAD: std_logic_vector (31 DOWNTO 0);
    SIGNAL WB_DATA : std_logic_vector (31 DOWNTO 0);

    -- EXECUTE SIGNALS
    SIGNAL FW_MUX_MEM: std_logic_vector (1 DOWNTO 0);
    SIGNAL ALU : std_logic_vector (31 DOWNTO 0);
	SIGNAL COND : std_logic;

    -- MEMORY SIGNALS
    SIGNAL WR_ADDR_MEM, WR_DATA_MEM: std_logic_vector(31 DOWNTO 0);

    -- WB SIGNALS
    SIGNAL WR_ADDR, DATA_WB : std_logic_vector(31 DOWNTO 0);

    COMPONENT FORWARDING_UNIT IS
        PORT(IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
             ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
             EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
             MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
 
             -- For ID stage management only
             IF_ID_IsBranch: OUT std_logic;
             ID_EXE_IsLoad: OUT std_logic;
             ID_EXE_HasDest: OUT std_logic;
             WB_HasDestA, WB_HasDestB: OUT std_logic;
 
             -- For EXE stage management only
             FW_A, FW_B, FW_MEM: OUT std_logic_vector(1 DOWNTO 0));
    END COMPONENT;

    COMPONENT DOWN_COUNTER IS
        GENERIC(START_VALUE: integer := 1);

        PORT(clock, reset, enable: IN std_logic;
             ZeroReached: OUT std_logic);
    END COMPONENT;

    COMPONENT FETCH IS 
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
    END COMPONENT;

    COMPONENT DECODE is
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
    END COMPONENT;

    COMPONENT EXECUTE IS
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
    END COMPONENT;

    COMPONENT MEMORY_ACCESS is
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
    END COMPONENT;

    COMPONENT WRITEBACK is
        PORT(-- Data from MEM stage
             IR_IN, NPC_IN: IN std_logic_vector(31 DOWNTO 0);
             WR_ADDR_IN, WR_DATA_IN: IN std_logic_vector (31 DOWNTO 0);
    
            -- Address and data for writing on RF
             WR_ADDR_OUT, WR_DATA_OUT: OUT std_logic_vector (31 DOWNTO 0));
    END COMPONENT;

BEGIN

    IF_ID_Instruction <= IR1;
    ID_EXE_Instruction <= IR2;
    EXE_MEM_Instruction <= IR3;
    MEM_WB_Instruction <= IR4;
    RESULT <= DATA_WB;
    MEM_ADDR <= ALU;
    MEM_DATA_WR <= B_2;
    Branch_cnt_over <= Branch_eval;

    -- FORWARDING UNIT
    FUNIT: FORWARDING_UNIT PORT MAP(-- Instructions to evaluate
                                    IF_ID_Instruction => IR1, 
                                    ID_EXE_Instruction => IR2,
                                    EXE_MEM_Instruction => IR3,
                                    MEM_WB_Instruction => IR4,
                                    
                                    -- For ID stage        
                                    IF_ID_IsBranch => IF_ID_IsBranch,
                                    ID_EXE_IsLoad => ID_EXE_IsLoad,
                                    ID_EXE_HasDest => ID_EXE_HasDest,
                                    WB_HasDestA => WB_HasDestA, WB_HasDestB => WB_HasDestB,

                                    -- For EXE stage
                                    FW_A => FW_A, FW_B => FW_B, FW_MEM => FW_MUX_MEM);

    -- DOWN COUNTER (branch management)
    DCNT: DOWN_COUNTER PORT MAP(clock => CLOCK, reset => Branch_cnt_reset, 
                                enable => Branch_cnt_en, 
                                ZeroReached => Branch_eval); 

    -- DOWN COUNTER (Division management)
    DCNT_DIV: DOWN_COUNTER GENERIC MAP(START_VALUE => DIV_CLOCK_CYCLES)
                           PORT MAP(clock => CLOCK, reset => DIV_cnt_reset, 
                                    enable => DIV_cnt_en, 
                                    ZeroReached => DIV_cnt_over); 

    -- FETCH STAGE
    FETCH_STAGE : FETCH PORT MAP (CLOCK => CLOCK, RESET => RESET, EN_REG_F => EN_FETCH, SET_IR => SET_IR1,

                                  -- From Control Unit to handle PC multiplexer
                                  S_MUX_PC => S_MUX_PC,  

                                  -- For branch management
                                  BranchTaken => BranchTaken_s,
                                   
                                  -- Data from IRAM
                                  IMEM_IN => IMEM_IN, 
                                  
                                  -- Program counter computed in MEM stage for branching operations
                                  MEM_PC => MEM_PC, 
                                  
                                  -- Program counter value to go towards the IRAM for accessing next instruction
                                  MEM_ADDR => IMEM_ADDR, 
                                  
                                  -- To decode stage
                                  CURR_NPC_OUT => CURR_NPC, NPC_OUT => NPC_IF, IR_OUT => IR1);

    -- DECODE STAGE
    DECODE_STAGE : DECODE PORT MAP (CLOCK => CLOCK, RESET => RESET,
                                    
                                    -- Control Unit signals
                                    EN_REG => EN_DECOD, SET_IR => SET_IR2,
                                    RD_ENABLE_1 => RD_ENABLE_1, RD_ENABLE_2 => RD_ENABLE_2, ENABLE_WR => ENABLE_WR, 
                                    SEL_MUX_A => SEL_MUX_A1, SEL_MUX_B => SEL_MUX_B1, SEL_IMM_LOAD => SEL_IMM_LOAD,
                                    SEL_SIGNEXT_OPTYPE => SEL_SIGNEXT_OPTYPE,

                                    -- For branch management
                                    BranchTaken => BranchTaken_s,
                                    NPC_IN => NPC_IF,

                                    -- Instruction register from IF stage
                                    IR_IN => IR1, 

                                    -- Data to write on RF by write back stage
                                    WB_DATA => DATA_WB, WR_ADDR => WR_ADDR(4 DOWNTO 0),

                                    -- Registers to write for EXE stage
                                    A_OUT => A, B_OUT => B, NPC_OUT => NPC_ID,
                                    IMM_OUT => IMM_LOAD, IR_OUT => IR2);

    -- EXECUTE STAGE
    EXECUTION_STAGE : EXECUTE PORT MAP (CLOCK => CLOCK, RESET => RESET,
    
                                        -- For branch management
                                        CounterOver => Branch_eval,
                                        BranchTaken => BranchTaken_s,

                                        -- Control signals from CU
                                        EN_REG => EN_EXECUTE, SET_IR => SET_IR3,
                                        SEL_MUX_A => SEL_MUX_A2, SEL_MUX_B => SEL_MUX_B2, SEL_MUX_ZERO => SEL_MUX_ZERO,
                                        SEL_MUX_MEM => FW_MUX_MEM, ALU_SEL => ALU_SEL,

                                        -- Data from previous stages
                                        A_IN => A, B_IN => B, IMM_IN => IMM_LOAD,
                                        NPC_IN => NPC_ID, IR_IN => IR2,

                                        -- Data from MEM stage for forwarding purposes
                                        DATA_FROM_MEM => WR_DATA_MEM, 
                                        
                                        -- Produced output values
                                        ALU_OUT => ALU, COND_OUT => COND,
                                        IR_OUT => IR3, B_OUT => B_2, NPC_OUT => NPC_EXE);

    -- MEMORY STAGE
    MEMORY_STAGE : MEMORY_ACCESS PORT MAP (CLOCK => CLOCK, RESET => RESET, 

                                           -- Control unit signals
                                           EN_REG => EN_MEMORY, SET_IR => SET_IR4,
                                           COND_IN => COND,  S_MUX_LMD => S_MUX_LMD,   

                                           -- Data from EXE stage
                                           NEXT_PC => CURR_NPC, NPC_IN => NPC_EXE, 
                                           ALU_OUT => ALU, 
                                           IR_IN => IR3, DATA_MEM_IN => DATA_MEM_IN,  
                                            
                                           -- Program counter produced after eval of branching conditions
                                           NEW_PC => MEM_PC, 
                                           
                                           -- To WB stage
                                           NPC_OUT => NPC_MEM,
                                           
                                           -- Address and data for writing on RF
                                           IR_OUT => IR4,
                                           WR_ADDR => WR_ADDR_MEM,
                                           WR_DATA => WR_DATA_MEM);

    -- WB STAGE
    WB_STAGE: WRITEBACK PORT MAP (IR_IN => IR4, NPC_IN => NPC_MEM,
                                  WR_ADDR_IN => WR_ADDR_MEM, WR_DATA_IN => WR_DATA_MEM,
                                  WR_ADDR_OUT => WR_ADDR, WR_DATA_OUT => DATA_WB);

END Structural;