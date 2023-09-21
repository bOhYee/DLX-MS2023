LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY WRITEBACK is
    PORT(-- Data from MEM stage
         IR_IN, NPC_IN: IN std_logic_vector(31 DOWNTO 0);
         WR_ADDR_IN, WR_DATA_IN: IN std_logic_vector (31 DOWNTO 0);

        -- Address and data for writing on RF
         WR_ADDR_OUT, WR_DATA_OUT: OUT std_logic_vector (31 DOWNTO 0));
END WRITEBACK;

ARCHITECTURE Structural of WRITEBACK IS

    CONSTANT AddressJAL: std_logic_vector(31 DOWNTO 0) := "00000000000000000000000000011111";
    SIGNAL IR_IsJAL: std_logic;

    COMPONENT MUX21_GENERIC IS
        GENERIC(NBIT: integer:= NumBit);
        
        PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
            SEL: IN std_logic;
            Y:	OUT	std_logic_vector(NBIT-1 DOWNTO 0));
    END COMPONENT;

    COMPONENT IR_COMPARATOR IS 
        PORT(A, B: IN std_logic_vector(5 DOWNTO 0);
             AreEqual: OUT std_logic);
    END COMPONENT;

BEGIN

    -- Verify that the instruction is or isn't a JAL
    IR_JAL: IR_COMPARATOR PORT MAP (A => IR_IN(31 DOWNTO 26), B => JTYPE_JAL,
                                    AreEqual => IR_IsJAL);

    -- Multiplexer for address to send back to the RF
    ADDR_MUX: MUX21_GENERIC GENERIC MAP (NumBit) 
                        PORT MAP (A => AddressJAL, B => WR_ADDR_IN, 
                                    SEL => IR_IsJAL, 
                                    Y => WR_ADDR_OUT);

    -- Multiplexer for data to send back to the RF
    DATA_MUX: MUX21_GENERIC GENERIC MAP (NumBit) 
                            PORT MAP (A => NPC_IN, B => WR_DATA_IN, 
                                      SEL => IR_IsJAL, 
                                      Y => WR_DATA_OUT);

END Structural;