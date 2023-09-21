LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE Globals is
    
    -- Number of bits for current configuration of the architecture
    CONSTANT NumBit : integer := 32;
    CONSTANT NumBitMul : integer := 64;

    -- Number of clock cycles to wait for a proper division
    -- Need to subtract one to the value before applying (ex. 16 clk cycles, put 15)
    -- This is because of how the counter is activated by the Control Unit
    CONSTANT DIV_CLOCK_CYCLES: integer := 32;

    -- Number of cycles the divider has to perform (more cycles -> more precision for big numbers)
    CONSTANT DIV_CYCLES: integer := 16;

    -- Number of Carry Select Block in the Sum Generator 
    CONSTANT NumStages : integer := 8;

    -- Configuration of address and data bus of the RF
    CONSTANT ADDRESS_WIDTH: integer := 5;
    CONSTANT DATA_WIDTH: integer := 32;
    
    -- Number of bits for OPCODE and FUNCT of the instruction for better readibility
    CONSTANT OP_CODE_SIZE : integer := 6;
    CONSTANT FUNC_SIZE : integer := 11;

    -- INSTRUCTIONS
    -- R-Type instruction -> OPCODE field
    CONSTANT RTYPE : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

    -- R-Type instruction -> FUNC field
    CONSTANT RTYPE_ADD    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100000";    -- ADD    RS1,RS2,RD
    CONSTANT RTYPE_ADDU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100001";    -- ADDU   RS1,RS2,RD
    CONSTANT RTYPE_SUB    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100010";    -- SUB    RS1,RS2,RD
    CONSTANT RTYPE_SUBU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100011";    -- SUBU   RS1,RS2,RD
    CONSTANT RTYPE_AND    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100100";    -- AND    RS1,RS2,RD 
    CONSTANT RTYPE_NAND   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00001000000";    -- NAND   RS1,RS2,RD 
    CONSTANT RTYPE_OR     : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100101";    -- OR     RS1,RS2,RD
    CONSTANT RTYPE_NOR    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00001000001";    -- NOR    RS1,RS2,RD
    CONSTANT RTYPE_XOR    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000100110";    -- XOR    RS1,RS2,RD
    CONSTANT RTYPE_XNOR   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00001000010";    -- XNOR   RS1,RS2,RD
    CONSTANT RTYPE_SLL    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000000100";    -- SLL    RS1,RS2,RD
    CONSTANT RTYPE_SRL    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000000110";    -- SRL    RS1,RS2,RD
    CONSTANT RTYPE_SRA    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000000111";    -- SRA    RS1,RS2,RD
    CONSTANT RTYPE_SGT    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101011";    -- SGT    RS1,RS2,RD
    CONSTANT RTYPE_SGTU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000111011";    -- SGTU   RS1,RS2,RD
    CONSTANT RTYPE_SEQ    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101000";    -- SEQ    RS1,RS2,RD
    CONSTANT RTYPE_SGE    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101101";    -- SGE    RS1,RS2,RD
    CONSTANT RTYPE_SGEU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000111101";    -- SGEU   RS1,RS2,RD
    CONSTANT RTYPE_SLT    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101010";    -- SLT    RS1,RS2,RD
    CONSTANT RTYPE_SLTU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000111010";    -- SLTU   RS1,RS2,RD
    CONSTANT RTYPE_SNE    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101001";    -- SNE    RS1,RS2,RD
    CONSTANT RTYPE_SLE    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000101100";    -- SLE    RS1,RS2,RD
    CONSTANT RTYPE_SLEU   : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000111100";    -- SLEU   RS1,RS2,RD
    CONSTANT RTYPE_MULTLO : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000011110";    -- MULTLO RS1,RS2,RD
    CONSTANT RTYPE_MULTHI : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000011111";    -- MULTHI RS1,RS2,RD
    CONSTANT RTYPE_DIV    : std_logic_vector(FUNC_SIZE - 1 DOWNTO 0) := "00000001111";    -- DIV    RS1,RS2,RD

    -- I-Type instruction -> OPCODE field
    CONSTANT ITYPE_ADDI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001000";    -- ADDI    RS1,RD,INP2
    CONSTANT ITYPE_ADDUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001001";    -- ADDUI   RS1,RD,INP2
    CONSTANT ITYPE_SUBI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001010";    -- SUBI    RS1,RD,INP2 
    CONSTANT ITYPE_SUBUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001011";    -- SUBUI   RS1,RD,INP2 
    CONSTANT ITYPE_ANDI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001100";    -- ANDI    RS1,RD,INP2 
    CONSTANT ITYPE_NANDI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "110000";    -- NANDI   RS1,RD,INP2 
    CONSTANT ITYPE_ORI     : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001101";    -- ORI     RS1,RD,INP2 
    CONSTANT ITYPE_NORI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "110001";    -- NORI    RS1,RD,INP2 
    CONSTANT ITYPE_XORI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "001110";    -- XORI    RS1,RD,INP2
    CONSTANT ITYPE_XNORI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "110010";    -- XNORI   RS1,RD,INP2
    CONSTANT ITYPE_BEQZ    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "000100";    -- BEQZ    RS1,RD,LABEL
    CONSTANT ITYPE_BNEZ    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "000101";    -- BENZ    RS1,RD,LABEL
    CONSTANT ITYPE_NOP     : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "010101";    -- NOP   
    CONSTANT ITYPE_LOAD    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "100011";    -- LW      RS1,RD,INP2 
    CONSTANT ITYPE_SW      : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "101011";    -- SW      RS1,RD,INP2 
    CONSTANT ITYPE_SLLI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "010100";    -- SLLI    RS1,RD,INP2 
    CONSTANT ITYPE_SRLI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "010110";    -- SRLI    RS1,RD,INP2
    CONSTANT ITYPE_SRAI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "010111";    -- SRAI    RS1,RD,INP2
    CONSTANT ITYPE_SGTI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011011";    -- SGTI    RS1,RD,INP2
    CONSTANT ITYPE_SGTUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "111011";    -- SGTUI   RS1,RD,INP2
    CONSTANT ITYPE_SEQI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011000";    -- SEQI    RS1,RD,INP2
    CONSTANT ITYPE_SGEI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011101";    -- SGEI    RS1,RD,INP2 
    CONSTANT ITYPE_SGEUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "111101";    -- SGEUI   RS1,RD,INP2 
    CONSTANT ITYPE_SNEI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011001";    -- SNEI    RS1,RD,INP2 
    CONSTANT ITYPE_SLTI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011010";    -- SLTI    RS1,RD,INP2 
    CONSTANT ITYPE_SLTUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "111010";    -- SLTUI   RS1,RD,INP2 
    CONSTANT ITYPE_SLEI    : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "011100";    -- SLEI    RS1,RD,INP2 
    CONSTANT ITYPE_SLEUI   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "111100";    -- SLEUI   RS1,RD,INP2 
    CONSTANT ITYPE_MULTLOI : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "101110";    -- MULTLOI RS1,RD,INP2
    CONSTANT ITYPE_MULTHII : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "101111";    -- MULTHII RS1,RD,INP2
    CONSTANT ITYPE_DIV     : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "111111";    -- DIV     RS1,RD,INP2
    
    -- J-Type instruction -> OPCODE field
    CONSTANT JTYPE_J   : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "000010";    -- J   INP1,INP2 
    CONSTANT JTYPE_JAL : std_logic_vector(OP_CODE_SIZE - 1 DOWNTO 0) :=  "000011";    -- JAL INP1,INP2 

    -- CONTROL WORD SIGNALS
    -- IF SIGNALS (IR_EN|REG_SET|REG_EN)
    CONSTANT FETCH_WIDTH : integer := 3;

    -- DECOD SIGNALS (RF1|RF2|SEL_A|SEL_B|OPTYPE_SIGNEXT|S_IMM)
    CONSTANT DECOD_WIDTH : integer := 6;
    CONSTANT DEC_RTYPE       : std_logic_vector(DECOD_WIDTH - 1 DOWNTO 0) := "110000";
    CONSTANT DEC_ITYPE       : std_logic_vector(DECOD_WIDTH - 1 DOWNTO 0) := "100000";
    CONSTANT DEC_ITYPE_USIGN : std_logic_vector(DECOD_WIDTH - 1 DOWNTO 0) := "100010";
    CONSTANT DEC_JTYPE       : std_logic_vector(DECOD_WIDTH - 1 DOWNTO 0) := "000001";

    -- EXE SIGNALS  (S_MUX_A|S_MUX_B|S_MUX_ZERO|S_ALU_OP)
    CONSTANT EXE_WIDTH : integer := 11;
    CONSTANT EXE_WIDTH_NOALU: integer := 6;
    CONSTANT EXE_WIDTH_ALU: integer := 5;

    -- Without ALU selection signals
    CONSTANT EXE_RTYPE: std_logic_vector(EXE_WIDTH_NOALU - 1 DOWNTO 0) := "101010";
    CONSTANT EXE_ITYPE: std_logic_vector(EXE_WIDTH_NOALU - 1 DOWNTO 0) := "101110";
    CONSTANT EXE_JTYPE: std_logic_vector(EXE_WIDTH_NOALU - 1 DOWNTO 0) := "111110";

    -- ALU signals
    CONSTANT EXE_ADD:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00000";
    CONSTANT EXE_SUB:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00001";
    CONSTANT EXE_AND:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00010";
    CONSTANT EXE_OR:       std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00011";
    CONSTANT EXE_XOR:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00100";
    CONSTANT EXE_NAND:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00101";
    CONSTANT EXE_NOR:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00110";
    CONSTANT EXE_XNOR:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "00111";
    CONSTANT EXE_SLL:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01000";
    CONSTANT EXE_SRL:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01001";
    CONSTANT EXE_SRA:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01010";
    CONSTANT EXE_SGE:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01011";
    CONSTANT EXE_SLE:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01100";
    CONSTANT EXE_SNE:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01101";
    CONSTANT EXE_NOP:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01110";
    CONSTANT EXE_SGT:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "01111";
    CONSTANT EXE_SLT:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10000";
    CONSTANT EXE_SEQ:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10001";
    CONSTANT EXE_MULTLO:   std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10010";
    CONSTANT EXE_MULTHI:   std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10011";
    CONSTANT EXE_DIV:      std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10101";
    CONSTANT EXE_SGEU:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10110";
    CONSTANT EXE_SLEU:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "10111";
    CONSTANT EXE_SGTU:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "11000";
    CONSTANT EXE_SLTU:     std_logic_vector(EXE_WIDTH_ALU - 1 DOWNTO 0) := "11001";

    -- Logic selector signals
    CONSTANT LOGIC_SELECTOR: integer := 4;
    CONSTANT LOGIC_AND:  std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "1000";
    CONSTANT LOGIC_NAND: std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "0111";
    CONSTANT LOGIC_OR:   std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "1110";
    CONSTANT LOGIC_NOR:  std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "0001";
    CONSTANT LOGIC_XOR:  std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "0110";
    CONSTANT LOGIC_XNOR: std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0) := "1001";

    -- Comparator selector signals
    CONSTANT COMPARATOR_SELECTOR: integer := 3;
    CONSTANT COMPARATOR_LE:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "000"; -- <=
    CONSTANT COMPARATOR_LT:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "001"; -- <    
    CONSTANT COMPARATOR_GT:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "010"; -- >
    CONSTANT COMPARATOR_GE:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "011"; -- >= 
    CONSTANT COMPARATOR_EQ:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "100"; -- =
    CONSTANT COMPARATOR_NE:  std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0) := "101"; -- != 
    
    -- MEM SIGNALS (MEM_RW|MEM_ENABLE|S_MUX_DOUT)
    CONSTANT MEM_WIDTH : integer := 3;

    CONSTANT MEM_ITYPE_LOAD : std_logic_vector(MEM_WIDTH-1 DOWNTO 0) := "010";
    CONSTANT MEM_ITYPE_SW   : std_logic_vector(MEM_WIDTH-1 DOWNTO 0) := "111";
    CONSTANT MEM_OTHERS     : std_logic_vector(MEM_WIDTH-1 DOWNTO 0) := "001";

    -- WB SIGNALS (WR_ENABLE_RF)
    CONSTANT WB_WIDTH : integer := 1;

    CONSTANT WB_SAVE        : std_logic_vector(WB_WIDTH-1 DOWNTO 0) := "1";
    CONSTANT WB_NOT_SAVE    : std_logic_vector(WB_WIDTH-1 DOWNTO 0) := "0";

END Globals;