LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY DLX IS
    PORT(clock, reset: IN std_logic;

         -- For IRAM
         IMEM_enable: OUT std_logic;
         IMEM_Addr: OUT std_logic_vector(31 DOWNTO 0);

         IMEM_ready: IN std_logic;
         IMEM_Data: IN std_logic_vector(31 DOWNTO 0);

         -- For DRAM
         DRAM_enable, DRAM_rw: OUT std_logic;
         DRAM_Addr, DRAM_Din: OUT std_logic_vector(31 DOWNTO 0);

         DRAM_ready: IN std_logic;
         DRAM_Dout: IN std_logic_vector(31 DOWNTO 0);
             
         -- Output
         Result: OUT std_logic_vector(31 DOWNTO 0)); 
END DLX;

ARCHITECTURE Structural OF DLX IS

    -- Instruction signals
    SIGNAL IFID_instr_s, IDEXE_instr_s, EXEMEM_instr_s, MEMWB_instr_s: std_logic_vector(31 DOWNTO 0);
    
    -- Register enable per stage
    SIGNAL EN_Fetch_s, EN_Decod_s, EN_Exe_s, EN_Memory_s, EN_WriteBack_s: std_logic;
    
    -- Setter for the registers for managing stalls
    SIGNAL EN_setNOP_Fs, EN_setNOP_Ds, EN_setNOP_Es, EN_setNOP_Ms, EN_setNOP_Ws: std_logic;
    
    -- Fetch
    SIGNAL S_PC_in_s: std_logic;
    
    -- Decode
    SIGNAL EN_RF_1_s, EN_RF_2_s, EN_RF_W_s: std_logic;
    SIGNAL S_SEL_A_s, S_SEL_B_s, S_SIGN_EXT_OPTYPE_s, S_IMM_s: std_logic;
    SIGNAL IF_ID_IsBranch_s, ID_EXE_IsLoad_s, ID_EXE_HasDest_s, WB_HasDestA_s, WB_HasDestB_s: std_logic;
    SIGNAL Branch_cnt_reset_s, Branch_cnt_en_s, Branch_cnt_over_s: std_logic;

    -- Execution
    SIGNAL S_MUX_P1_s, S_MUX_P2_s, S_MUX_ZERO_s: std_logic_vector(1 DOWNTO 0);
    SIGNAL FW_A_s, FW_B_s: std_logic_vector(1 DOWNTO 0);
    SIGNAL S_ALU_s: std_logic_vector(EXE_WIDTH_ALU-1 DOWNTO 0);
    SIGNAL DIV_cnt_reset_s, DIV_cnt_en_s, DIV_cnt_over_s: std_logic;

    -- Memory
    SIGNAL S_WB_s: std_logic;
    
    COMPONENT DLX_CU IS    
        PORT(clock, reset: IN std_logic;
            
             -- Fetch stage
             S_PC_in: OUT std_logic;
             IR_Ready: IN std_logic; 
             IR_Enable: OUT std_logic;
             EN_setNOP_Fetch: OUT std_logic;
             EN_Fetch: OUT std_logic;
             
             -- Decod stage
             IF_ID_Instruction: IN std_logic_vector(31 DOWNTO 0);
             IF_ID_IsBranch: IN std_logic;
             ID_EXE_IsLoad: IN std_logic;
             ID_EXE_HasDest: IN std_logic;
             WB_HasDestA, WB_HasDestB: IN std_logic;
             Branch_cnt_over: IN std_logic;
             EN_RF_PORT1, EN_RF_PORT2: OUT std_logic;
             S_SEL_A, S_SEL_B, S_SIGN_EXT_OPTYPE, S_IMM: OUT std_logic;
             Branch_cnt_reset, Branch_cnt_en: OUT std_logic;
             EN_setNOP_Decod: OUT std_logic;
             EN_Decod: OUT std_logic;
             
             -- Execution stage
             ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
             FW_A, FW_B: IN std_logic_vector(1 DOWNTO 0);
             DIV_cnt_over: IN std_logic;
             S_MUX_P1, S_MUX_P2, S_MUX_ZERO: OUT std_logic_vector(1 DOWNTO 0);
             S_ALU_Op: OUT std_logic_vector(EXE_WIDTH_ALU-1 DOWNTO 0);
             DIV_cnt_reset, DIV_cnt_en: OUT std_logic;
             EN_setNOP_Exe: OUT std_logic;
             EN_Exe: OUT std_logic;
             
             -- Memory stage
             EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
             EN_Memory: OUT std_logic;
             EN_setNOP_MEM: OUT std_logic;
             DMEM_Ready: IN std_logic;
             S_MuxDOUT: OUT std_logic;
             DMEM_RW, DMEM_Enable: OUT std_logic;
             
             -- Write back stage
             MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
             EN_RF_WPORT: OUT std_logic         
        );   
    END COMPONENT;
    
    COMPONENT DLX_DP IS
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
    END COMPONENT;

BEGIN

    CU: DLX_CU PORT MAP(clock => clock, reset => reset,

                        -- Fetch
                        EN_Fetch => EN_Fetch_s, IR_Ready => IMEM_ready, IR_Enable => IMEM_enable, EN_setNOP_Fetch => EN_setNOP_Fs, S_PC_in => S_PC_in_s,
                        
                        -- Decode
                        EN_Decod => EN_Decod_s, EN_RF_PORT1 => EN_RF_1_s, EN_RF_PORT2 => EN_RF_2_s, EN_setNOP_Decod => EN_setNOP_Ds, IF_ID_Instruction => IFID_instr_s, 
                        S_SEL_A => S_SEL_A_s, S_SEL_B => S_SEL_B_s, S_IMM => S_IMM_s, S_SIGN_EXT_OPTYPE => S_SIGN_EXT_OPTYPE_s,
                        IF_ID_IsBranch => IF_ID_IsBranch_s, ID_EXE_IsLoad => ID_EXE_IsLoad_s,
                        ID_EXE_HasDest => ID_EXE_HasDest_s, WB_HasDestA => WB_HasDestA_s, WB_HasDestB => WB_HasDestB_s,
                        Branch_cnt_reset => Branch_cnt_reset_s, Branch_cnt_en => Branch_cnt_en_s, Branch_cnt_over => Branch_cnt_over_s,
                        
                        -- Execute
                        EN_Exe => EN_Exe_s, EN_setNOP_Exe => EN_setNOP_Es, ID_EXE_Instruction => IDEXE_instr_s, FW_A => FW_A_s, FW_B => FW_B_s,
                        S_MUX_P1 => S_MUX_P1_s, S_MUX_P2 => S_MUX_P2_s, S_MUX_ZERO => S_MUX_ZERO_s, S_ALU_Op => S_ALU_s,
                        DIV_cnt_reset => DIV_cnt_reset_s, DIV_cnt_en => DIV_cnt_en_s, DIV_cnt_over => DIV_cnt_over_s,
                        
                        -- Memory
                        EN_Memory => EN_Memory_s, DMEM_Ready => DRAM_ready, DMEM_RW => DRAM_rw, DMEM_Enable => DRAM_enable, EN_setNOP_MEM => EN_setNOP_Ms, 
                        EXE_MEM_Instruction => EXEMEM_instr_s, S_MuxDOUT => S_WB_s,
                        
                        -- Write back
                        EN_RF_WPORT => EN_RF_W_s, MEM_WB_Instruction => MEMWB_instr_s);

    Datapath: DLX_DP PORT MAP(CLOCK => clock, RESET => reset,

                              -- Fetch
                              EN_FETCH => EN_Fetch_s, IMEM_ADDR => IMEM_Addr, IMEM_IN => IMEM_Data, IF_ID_Instruction => IFID_instr_s,
                              SET_IR1 => EN_setNOP_Fs, S_MUX_PC => S_PC_in_s,
    
                              -- Decode
                              EN_Decod => EN_Decod_s, SET_IR2 => EN_setNOP_Ds,
                              RD_ENABLE_1 => EN_RF_1_s, RD_ENABLE_2 => EN_RF_2_s, ENABLE_WR => EN_RF_W_s,
                              SEL_MUX_A1 => S_SEL_A_s, SEL_MUX_B1 => S_SEL_B_s, SEL_IMM_LOAD => S_IMM_s, SEL_SIGNEXT_OPTYPE => S_SIGN_EXT_OPTYPE_s,
                              ID_EXE_Instruction => IDEXE_instr_s, IF_ID_IsBranch => IF_ID_IsBranch_s, ID_EXE_IsLoad => ID_EXE_IsLoad_s,
                              ID_EXE_HasDest => ID_EXE_HasDest_s, WB_HasDestA => WB_HasDestA_s, WB_HasDestB => WB_HasDestB_s,
                              Branch_cnt_reset => Branch_cnt_reset_s, Branch_cnt_en => Branch_cnt_en_s, Branch_cnt_over => Branch_cnt_over_s,
    
                              -- Execute
                              EN_EXECUTE => EN_Exe_s, SET_IR3 => EN_setNOP_Es,
                              SEL_MUX_A2 => S_MUX_P1_s, SEL_MUX_B2 => S_MUX_P2_s, SEL_MUX_ZERO => S_MUX_ZERO_s, 
                              ALU_SEL => S_ALU_s,
                              EXE_MEM_Instruction => EXEMEM_instr_s, FW_A => FW_A_s, FW_B => FW_B_s,
                              DIV_cnt_reset => DIV_cnt_reset_s, DIV_cnt_en => DIV_cnt_en_s, DIV_cnt_over => DIV_cnt_over_s,
                            
                              -- MEM/WB
                              EN_MEMORY => EN_Memory_s, SET_IR4 => EN_setNOP_Ms,
                              MEM_WB_Instruction => MEMWB_instr_s,
                              MEM_ADDR => DRAM_Addr, MEM_DATA_WR => DRAM_Din, DATA_MEM_IN => DRAM_Dout,
                              S_MUX_LMD => S_WB_s, RESULT => Result);

END Structural;