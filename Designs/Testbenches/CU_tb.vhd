LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.Globals.ALL;

ENTITY CU_tb IS
END CU_tb;

ARCHITECTURE TEST OF CU_tb IS

    -- CU to test
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
            EN_setNOP_Decod: OUT std_logic;
            EN_Decod: OUT std_logic;
            EN_RF_PORT1, EN_RF_PORT2: OUT std_logic;
            S_SEL_A, S_SEL_B: OUT std_logic;
            S_IMM: OUT std_logic;
            
            -- Execution stage
            ID_EXE_Instruction: IN std_logic_vector(31 DOWNTO 0);
            ALU_OpCompleted: IN std_logic;
            EN_setNOP_Exe: OUT std_logic;
            EN_Exe: OUT std_logic;
            S_MuxPort2: OUT std_logic;
            S_ALU_Op: OUT std_logic_vector(ALU_OP_WIDTH-1 DOWNTO 0);
            
            -- Memory stage
            EXE_MEM_Instruction: IN std_logic_vector(31 DOWNTO 0);
            EN_Memory: OUT std_logic;
            EN_setNOP_MEM: OUT std_logic;
            DMEM_Ready: IN std_logic;
            DMEM_RW, DMEM_Enable: OUT std_logic;
            
            -- Write back stage
            MEM_WB_Instruction: IN std_logic_vector(31 DOWNTO 0);
            EN_WriteBack: OUT std_logic;
            S_MuxOut: OUT std_logic;
            EN_RF_WPORT: OUT std_logic         
        );  
    END COMPONENT;
    
    -- Clock and reset signals
    CONSTANT Period: Time := 20ns;
    SIGNAL clock_s, reset_s: std_logic;

    -- Test start signals
    SIGNAL tcount: integer := 0;
    SIGNAL IF_start, ID_start: std_logic := '0';
    
    -- Instruction related signals
    SIGNAL IFID_instr_s, IDEXE_instr_s, EXEMEM_instr_s, MEMWB_instr_s: std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
    
    -- Output signals
    SIGNAL S_ALU_s: std_logic_vector(ALU_OP_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL S_PC_in_s, EN_Fetch_s, IR_Ready_s, IR_Enable_s, EN_setNOP_Fs, EN_Decod_s, EN_RF_1_s, EN_setNOP_Ds, EN_RF_2_s, S_SEL_A_s, S_SEL_B_s, S_Imm_s, EN_Exe_s: std_logic := '0';
    SIGNAL S_Exe_s, EN_Memory_s, EN_setNOP_Es, ALU_OpC_s, DMEM_Ready_s, DMEM_RW_s, DMEM_Enable_s, EN_setNOP_Ms, EN_WriteBack_s, S_WB_s, EN_RF_W_s: std_logic := '0';

BEGIN

       -- Instance of CU 
       -- Generics left with default values
       CU: DLX_CU PORT MAP(clock => clock_s, reset => reset_s,
                           S_PC_in => S_PC_in_s, EN_Fetch => EN_Fetch_s, IR_Ready => IR_Ready_s, IR_Enable => IR_Enable_s, EN_setNOP_Fetch => EN_setNOP_Fs,
                           EN_Decod => EN_Decod_s, EN_RF_PORT1 => EN_RF_1_s, EN_RF_PORT2 => EN_RF_2_s, EN_setNOP_Decod => EN_setNOP_Ds, S_SEL_A => S_SEL_A_s, S_SEL_B => S_SEL_B_s, S_IMM => S_Imm_s, IF_ID_Instruction => IFID_instr_s,
                           EN_Exe => EN_Exe_s, S_MuxPort2 => S_Exe_s, S_ALU_Op => S_ALU_s, EN_setNOP_Exe => EN_setNOP_Es, ALU_OpCompleted => ALU_OpC_s, ID_EXE_Instruction => IDEXE_instr_s, 
                           EN_Memory => EN_Memory_s, DMEM_Ready => DMEM_Ready_s, DMEM_RW => DMEM_RW_s, DMEM_Enable => DMEM_Enable_s, EN_setNOP_MEM => EN_setNOP_Ms, EXE_MEM_Instruction => EXEMEM_instr_s,
                           EN_WriteBack => EN_WriteBack_s, S_MuxOut => S_WB_s, EN_RF_WPORT => EN_RF_W_s, MEM_WB_Instruction => MEMWB_instr_s);

        -- Process to manage the changing of the clock signal
        ClockProc: PROCESS
        BEGIN
            clock_s <= '0';
            WAIT FOR Period/2;
            clock_s <= '1';
            WAIT FOR Period/2;
        END PROCESS;
        
        -- Process to manage input vectors
        InputProc: PROCESS
        VARIABLE RTYPE_zeros: std_logic_vector(31-OP_CODE_SIZE-FUNC_SIZE DOWNTO 0);
        VARIABLE ITYPE_zeros: std_logic_vector(31-OP_CODE_SIZE DOWNTO 0);
        BEGIN      
            RTYPE_zeros := (OTHERS => '0');
            ITYPE_zeros := (OTHERS => '0');
              
            -- Reset the CU
            reset_s <= '1';
            WAIT FOR 3 NS;
            WAIT FOR Period;
            
            -- Test the IF stage
            reset_s <= '0';
            
            ----------------------- IF STAGE -----------------------
            -- To prevent stalls from successive FSMs
            ALU_OpC_s <= '1';
            DMEM_Ready_s <= '1';
    
            -- Normal execution
            tcount <= 1;
            IR_Ready_s <= '1';
            IFID_instr_s <= X"2001002a";
            WAIT FOR Period;
            
            IFID_instr_s <= X"00221825";
            WAIT FOR Period;

            -- Instruction memory stalls situation (instruction not present, etc...)
            tcount <= 2;
            IR_Ready_s <= '0';
            IFID_instr_s <= (OTHERS => 'Z');
            WAIT FOR 2*Period;
            
            -- Decod stage stalls
            tcount <= 3;
            ALU_OpC_s <= '0';
            WAIT FOR Period;
            
            IR_Ready_s <= '1';
            IFID_instr_s <= X"00614007";
            WAIT FOR Period;
            
            ALU_OpC_s <= '1';
            -- Finish test
            
            ----------------------- ID STAGE -----------------------
            -- To avoid stalls
            ALU_OpC_s <= '1';
            DMEM_Ready_s <= '1';
            WAIT UNTIL rising_edge(clock_s);
            
            -- Test normal behaviour
            tcount <= 1;
            ID_start <= '1';
            IFID_instr_s <= X"00614007";  -- R-type
            IDEXE_instr_s <= X"2002aaaa"; -- I-type
            WAIT FOR Period;
            
            IFID_instr_s <= X"50650002";  -- I-type
            IDEXE_instr_s <= X"00614007"; -- I-type
            WAIT FOR Period;
            
            -- Test forwarding behaviour
            tcount <= 2;
            IFID_instr_s <= X"8c220004";  -- LW r2, 0(r1)
            IDEXE_instr_s <= X"50650002"; -- I-type
            WAIT FOR Period;
                     
            IFID_instr_s <= X"00430820";  -- ADD r1, r2, r3
            IDEXE_instr_s <= X"8c220004"; -- LW r2, 0(r1)
            WAIT FOR 2*Period;
            
            -- Test execution stage stall
            tcount <= 3;
            IFID_instr_s <= X"4ce00000";  -- JAL
            IDEXE_instr_s <= X"20070000"; -- ADDI
            ALU_OpC_s <= '0' AFTER 5 NS;   
            WAIT FOR Period;
            
            -- Test execution stage stall with forwarding  
            tcount <= 4;          
            IFID_instr_s <= X"1440ffe8";  -- BNEZ r2, something
            IDEXE_instr_s <= X"8c220004"; -- LW r2, 0(r1)
            ALU_OpC_s <= '1' AFTER 5NS, '0' AFTER Period, '1' AFTER Period;
            WAIT FOR 4*Period;
            
            -- Test branching
            tcount <= 5;
            IFID_instr_s <= X"1440ffe8";  -- BNEZ r2, something
            IDEXE_instr_s <= X"2002aaaa"; -- I-type            
            WAIT FOR 3*Period;
            
            -- Finish test
            IFID_instr_s <= X"00614007";  -- R-type
            IDEXE_instr_s <= X"2002aaaa"; -- I-type
            WAIT;
        END PROCESS;
        
END TEST;