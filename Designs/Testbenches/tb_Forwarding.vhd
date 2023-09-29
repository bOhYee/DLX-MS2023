LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY TB_FORWARDING IS
END TB_FORWARDING;

ARCHITECTURE TEST OF TB_FORWARDING IS
    
    CONSTANT Period: Time := 20NS;
	SIGNAL IF_ID_Instruction_s, ID_EXE_Instruction_s, EXE_MEM_Instruction_s, MEM_WB_Instruction_s: std_logic_vector(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL IF_ID_IsBranch_Behav_s, ID_EXE_IsLoad_Behav_s, ID_EXE_HasDest_Behav_s, WB_HasDestA_Behav_s, WB_HasDestB_Behav_s: std_logic;
	SIGNAL IF_ID_IsBranch_Struct_s, ID_EXE_IsLoad_Struct_s, ID_EXE_HasDest_Struct_s, WB_HasDestA_Struct_s, WB_HasDestB_Struct_s: std_logic;
    SIGNAL FW_A_Behav_s, FW_B_Behav_s: std_logic_vector(1 DOWNTO 0);
    SIGNAL FW_A_Struct_s, FW_B_Struct_s: std_logic_vector(1 DOWNTO 0);
	
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
             FW_A, FW_B: OUT std_logic_vector(1 DOWNTO 0));
    END COMPONENT;

BEGIN 
		
	-- Unit to test
	DUT_BEHAV: FORWARDING_UNIT PORT MAP(IF_ID_Instruction => IF_ID_Instruction_s, 
                                        ID_EXE_Instruction => ID_EXE_Instruction_s,
                                        EXE_MEM_Instruction => EXE_MEM_Instruction_s,
                                        MEM_WB_Instruction => MEM_WB_Instruction_s,
                                        
                                        IF_ID_IsBranch => IF_ID_IsBranch_Behav_s, ID_EXE_IsLoad => ID_EXE_IsLoad_Behav_s, 
                                        ID_EXE_HasDest => ID_EXE_HasDest_Behav_s, 
                                        WB_HasDestA => WB_HasDestA_Behav_s, WB_HasDestB => WB_HasDestB_Behav_s, 
                                        FW_A => FW_A_Behav_s, FW_B => FW_B_Behav_s);

    DUT_STRUCT: FORWARDING_UNIT PORT MAP(IF_ID_Instruction => IF_ID_Instruction_s, 
                                         ID_EXE_Instruction => ID_EXE_Instruction_s,
                                         EXE_MEM_Instruction => EXE_MEM_Instruction_s,
                                         MEM_WB_Instruction => MEM_WB_Instruction_s,
                                         
                                         IF_ID_IsBranch => IF_ID_IsBranch_Struct_s, ID_EXE_IsLoad => ID_EXE_IsLoad_Struct_s, 
                                         ID_EXE_HasDest => ID_EXE_HasDest_Struct_s, 
                                         WB_HasDestA => WB_HasDestA_Struct_s, WB_HasDestB => WB_HasDestB_Struct_s,
                                         FW_A => FW_A_Struct_s, FW_B => FW_B_Struct_s);

    -- Process to test DUT by inputting test vectors
    InputProc: PROCESS
    BEGIN
        IF_ID_Instruction_s <= x"08000088";      -- JMP
        ID_EXE_Instruction_s <= x"00432820";     -- ADD r5, r2, r3
        EXE_MEM_Instruction_s <= x"54000000";    -- NOP
        MEM_WB_Instruction_s <= x"00221822";     -- SUB r3, r1, r2

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;

        IF_ID_Instruction_s <= x"00222820";      -- ADD r5, r1, r2
        ID_EXE_Instruction_s <= x"8c810000";     -- LW r1, 0(r4)
        EXE_MEM_Instruction_s <= x"54000000";    -- NOP
        MEM_WB_Instruction_s <= x"00222022";     -- SUB r4, r1, r2

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;

        IF_ID_Instruction_s <= x"ac000000";      -- SW r5, 0(r4)
        ID_EXE_Instruction_s <= x"00222020";     -- ADD r4, r1, r2
        EXE_MEM_Instruction_s <= x"00660822";    -- SUB r1, r3, r6
        MEM_WB_Instruction_s <= x"006c1022";     -- SUB r2, r3, r12

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;
        
        IF_ID_Instruction_s <= x"00221822";      -- SUB r3, r1, r2
        ID_EXE_Instruction_s <= x"54000000";     -- NOP
        EXE_MEM_Instruction_s <= x"54000000";    -- NOP
        MEM_WB_Instruction_s <= x"006c1022";     -- SUB r2, r3, r12

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;
        
        IF_ID_Instruction_s <= x"00430820";      -- ADD r1, r2, r3
        ID_EXE_Instruction_s <= x"54000000";     -- NOP
        EXE_MEM_Instruction_s <= x"54000000";    -- NOP
        MEM_WB_Instruction_s <= x"00620820";     -- ADD r4, r1, r1

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;
        
        IF_ID_Instruction_s <= x"00430820";      -- ADD r1, r2, r3
        ID_EXE_Instruction_s <= x"00422020";     -- ADD r4, r2, r2
        EXE_MEM_Instruction_s <= x"00231022";    -- SUB r2, r1, r3
        MEM_WB_Instruction_s <= x"0025101e";     -- MULTLO r2, r1, r5

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT FOR 20NS;
        
        IF_ID_Instruction_s <= x"54000000";      -- NOP
        ID_EXE_Instruction_s <= x"00412020";     -- ADD r4, r2, r1
        EXE_MEM_Instruction_s <= x"00230822";    -- SUB r1, r1, r3
        MEM_WB_Instruction_s <= x"00e5181e";     -- MULTLO r3, r7, r5

        ASSERT IF_ID_IsBranch_Behav_s = IF_ID_IsBranch_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_IsLoad_Behav_s = ID_EXE_IsLoad_Struct_s REPORT "ERROR";
        ASSERT ID_EXE_HasDest_Behav_s = ID_EXE_HasDest_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestA_Behav_s = WB_HasDestA_Struct_s REPORT "ERROR";
        ASSERT WB_HasDestB_Behav_s = WB_HasDestB_Struct_s REPORT "ERROR";
        ASSERT FW_A_Behav_s = FW_A_Struct_s REPORT "ERROR";
        ASSERT FW_B_Behav_s = FW_B_Struct_s REPORT "ERROR";
        WAIT;
    END PROCESS;
END TEST;