LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.Globals.ALL;

ENTITY ALU IS
    PORT(CLOCK: IN std_logic;
		 
		 -- Input operands
		 A, B: IN  std_logic_vector(31 DOWNTO 0);  

		 -- For function selection
    	 ALU_SEL: IN  std_logic_vector (EXE_WIDTH_ALU-1 DOWNTO 0);  

		 -- Output to produce
    	 ALU_OUT: OUT std_logic_vector(31 DOWNTO 0));
END ALU; 

ARCHITECTURE Structural OF ALU IS

	SIGNAL SEL_result: std_logic_vector(2 DOWNTO 0);

	SIGNAL B_adder_s: std_logic_vector(31 DOWNTO 0);
	SIGNAL Cin_adder_s, Cout_adder_s, Overflow_adder_s: std_logic;
	SIGNAL OV_s, OV_Enable_s: std_logic;
	SIGNAL Result_adder_s: std_logic_vector(31 DOWNTO 0);

	SIGNAL Result_logic_s: std_logic_vector(31 DOWNTO 0);
	SIGNAL SEL_logic_s: std_logic_vector(LOGIC_SELECTOR-1 DOWNTO 0);

	SIGNAL Result_shifter_s: std_logic_vector(31 DOWNTO 0);
	SIGNAL lr_shift_s, la_shift_s: std_logic;

	SIGNAL Result_comparator_s: std_logic_vector(31 DOWNTO 0);
	SIGNAL SEL_comparator_s: std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0);
	SIGNAL R_comp_s: std_logic;

	SIGNAL SEL_multiplier_result_s: std_logic;
	SIGNAL Result_multiplier_s: std_logic_vector(31 DOWNTO 0);

	SIGNAL Q_divider_s, R_divider_s: std_logic_vector(31 DOWNTO 0);
	SIGNAL DIV_enable_s: std_logic;
	
	COMPONENT P4_ADDER IS
		GENERIC(NBIT: integer := NumBit;
				NSTAGES: integer := NumStages);
		
		PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
			 CarryIn: IN std_logic;
			 Sum: OUT std_logic_vector(NBIT-1 DOWNTO 0);
			 Overflow, CarryOut: OUT std_logic);
	END COMPONENT;

	COMPONENT Logics IS 
		GENERIC(N: integer := NumBit);
		
		PORT(SEL: IN std_logic_vector(3 DOWNTO 0);
			 R1, R2: IN std_logic_vector(N-1 DOWNTO 0);
			 Y: OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT Shifter IS
		PORT(RIGHT_OR_LEFT: IN std_logic; 			-- 0: RIGHT, 1: LEFT 
			 LOGICAL_OR_ARITHMETICAL: IN std_logic; -- 0: LOGICAL, 1:ARITHMETICAL
			 R1 : IN std_logic_vector(NumBit-1 DOWNTO 0);
			 R2 : IN std_logic_vector(5 DOWNTO 0);
			 Z : OUT std_logic_vector(NumBit-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT Boothmul IS
		GENERIC(N_BIT : integer := NumBitMul);
		
		PORT(F1, F2: IN std_logic_vector(N_BIT/2-1 DOWNTO 0);   -- The two factors
			 HI_OR_LOW : in std_logic;                          -- 1 selects HI, 0 selects LOW
			 R: OUT std_logic_vector(N_BIT/2-1 DOWNTO 0));		-- Result
	END COMPONENT;

    COMPONENT Comparator IS
        GENERIC (NBIT: integer := NumBit);

        PORT (sum : IN std_logic_vector(NBIT-1 DOWNTO 0);
              carry, overflow : IN std_logic;
              sel : IN std_logic_vector(COMPARATOR_SELECTOR-1 DOWNTO 0);
              result : OUT std_logic);
    END COMPONENT;

	COMPONENT DividerComponent IS
		GENERIC(NBIT: integer := NumBit);
		
		PORT(CK: IN std_logic;
			 A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
			 ALU_enable: IN std_logic;
			 Q: OUT std_logic_vector(NBIT-1 DOWNTO 0);
			 R: OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT MUX_8TO1 IS
		GENERIC(NBIT : integer := NumBit);

		PORT(A, B, C, D, E, F, G, H: IN std_logic_vector(NBIT-1 DOWNTO 0);
			 S: IN std_logic_vector(2 DOWNTO 0);
			 Z: OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

BEGIN

	-- Process for enabling and sending different configuration signals here, instead of including it
	-- inside the control unit, for simplicity in including new instructions. Otherwise we would need a vector of many bits
	-- where each group is related to a specific block. We don't know if we will add more instructions so it is best to keep it 
	-- like this.
	DecoderProc: PROCESS(A, B, ALU_SEL)
	BEGIN
		-- Attempt at trying to reduce power consumption by inputting always zero
		-- to the disabled components. A sort of clock gating, but without clock.
		B_adder_s <= B;
		Cin_adder_s <= '1';
		OV_Enable_s <= '0';

		SEL_logic_s <= (OTHERS => '0');

		lr_shift_s <= '0';
		la_shift_s <= '0';

		SEL_comparator_s <= (OTHERS => '0');
        
		DIV_enable_s <= '0';

		-- Manage output multiplexer 
		CASE (ALU_SEL) IS
			WHEN EXE_ADD | EXE_SUB =>
				SEL_result <= "000";
			
			WHEN EXE_AND | EXE_NAND | EXE_OR | EXE_NOR | EXE_XOR | EXE_XNOR =>
				SEL_result <= "001";
			
			WHEN EXE_SLL | EXE_SRL | EXE_SRA =>
				SEL_result <= "010";
			
			WHEN EXE_SGE | EXE_SGEU |
				 EXE_SGT | EXE_SGTU | EXE_SEQ | 
				 EXE_SLT | EXE_SLTU | 
				 EXE_SLE | EXE_SLEU | EXE_SNE =>
				SEL_result <= "011";

			WHEN EXE_MULTLO | EXE_MULTHI => 
				SEL_result <= "100";

			WHEN EXE_DIV => 
				SEL_result <= "101";

			WHEN OTHERS => 
				SEL_result <= "110";
		END CASE;

		-- Manage input to blocks
		CASE (ALU_SEL) IS
		
			WHEN EXE_ADD => -- ADD
				Cin_adder_s <= '0';
				
			WHEN EXE_SUB => -- SUB
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';

			WHEN EXE_AND => -- Logic AND
				SEL_logic_s <= LOGIC_AND;

			WHEN EXE_NAND => -- Logic NAND
				SEL_logic_s <= LOGIC_NAND;

			WHEN EXE_OR => -- Logic OR
				SEL_logic_s <= LOGIC_OR;

			WHEN EXE_NOR => -- Logic NOR
				SEL_logic_s <= LOGIC_NOR;

			WHEN EXE_XOR => -- Logic XOR
				SEL_logic_s <= LOGIC_XOR;

			WHEN EXE_XNOR => -- Logic XNOR
				SEL_logic_s <= LOGIC_XNOR;

			WHEN EXE_SLL => -- Shift logical left
				lr_shift_s <= '1';
				la_shift_s <= '0';

			WHEN EXE_SRL => -- Shift logical right
				lr_shift_s <= '0';
				la_shift_s <= '0';

			WHEN EXE_SRA => -- Shift arithemtic right
				lr_shift_s <= '0';
				la_shift_s <= '1';
				
			WHEN EXE_SGE => -- Set if A is greater or equal than B (signed)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '1';

				SEL_comparator_s <= COMPARATOR_GE;

			WHEN EXE_SGEU => -- Set if A is greater or equal than B (unsigned)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '0';

				SEL_comparator_s <= COMPARATOR_GE;

			WHEN EXE_SGT => -- Set if A is greater than B (signed)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '1';

				SEL_comparator_s <= COMPARATOR_GT;

			WHEN EXE_SGTU => -- Set if A is greater than B (unsigned)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '0';

				SEL_comparator_s <= COMPARATOR_GT;

			WHEN EXE_SEQ => -- Set if A is equal to B
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '1';

				SEL_comparator_s <= COMPARATOR_EQ;

			WHEN EXE_SLT => -- Set if A is lower than B (signed)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '1';

				SEL_comparator_s <= COMPARATOR_LT;

			WHEN EXE_SLTU => -- Set if A is lower than B (unsigned)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '0';

				SEL_comparator_s <= COMPARATOR_LT;

			WHEN EXE_SNE => -- Set if the two operands are different
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				
				SEL_comparator_s <= COMPARATOR_NE;
			
			WHEN EXE_SLE => -- Set if A is lower or equal than B (signed)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '1';

				SEL_comparator_s <= COMPARATOR_LE;

			WHEN EXE_SLEU => -- Set if A is lower or equal than B (unsigned)
				B_adder_s <= NOT(B);
				Cin_adder_s <= '1';
				OV_Enable_s <= '0';

				SEL_comparator_s <= COMPARATOR_LE;
			
			WHEN EXE_MULTLO => -- MULTLO
				SEL_multiplier_result_s <= '0';
			
			WHEN EXE_MULTHI => -- MULTHI
				SEL_multiplier_result_s <= '1';

			WHEN EXE_DIV => -- Division between A and B
				DIV_enable_s <= '1';
			
			WHEN OTHERS => 
                B_adder_s <= B;
                Cin_adder_s <= '1';
        
                SEL_logic_s <= (OTHERS => '0');
        
                lr_shift_s <= '0';
                la_shift_s <= '0';
        
                SEL_comparator_s <= (OTHERS => '0');
                
				DIV_enable_s <= '0';
	
		END CASE;
	END PROCESS;

	ADDER: P4_ADDER PORT MAP(A => A, B => B_adder_s, CarryIn => Cin_adder_s,
							 Sum => Result_adder_s, CarryOut => Cout_adder_s, Overflow => Overflow_adder_s);

	-- Overflow flag to go to comparator
	OV_s <= Overflow_adder_s AND OV_Enable_s;

	LOGIC: Logics PORT MAP(R1 => A, R2 => B,
						   SEL => SEL_logic_s, 
						   Y => Result_logic_s);

	SHIFT: Shifter PORT MAP(R1 => A, R2 => B(5 DOWNTO 0),
							RIGHT_OR_LEFT => lr_shift_s, LOGICAL_OR_ARITHMETICAL => la_shift_s,
							Z => Result_shifter_s);

	MULT: Boothmul GENERIC MAP(N_BIT => NumBitMul)
				   PORT MAP(F1 => A, F2 => B, 
				   			HI_OR_LOW => SEL_multiplier_result_s,
				   		    R => Result_multiplier_s);

	-- Produces only a flag of one bit	
	COMPARE: Comparator PORT MAP(sum => Result_adder_s, carry => Cout_adder_s,
	                             overflow => OV_s,
								 sel => SEL_comparator_s,
								 result => R_comp_s);

	Result_comparator_s	<= "0000000000000000000000000000000" & R_comp_s;

	DIV: DividerComponent GENERIC MAP(NBIT => 32)
				 		  PORT MAP(CK => CLOCK, 
				 		  		   A => A, B => B, ALU_enable => DIV_enable_s,
						  		   Q => Q_divider_s, R => R_divider_s);

	-- Output mux
	RES_MUX: MUX_8TO1 GENERIC MAP(NBIT => 32)
					  PORT MAP(A => Result_adder_s, 
					  		   B => Result_logic_s, 
							   C => Result_shifter_s,
							   D => Result_comparator_s,
							   E => Result_multiplier_s,
							   F => Q_divider_s,
							   G => (OTHERS => '0'),
							   H => (OTHERS => '0'),
							   S => SEL_result, Z => ALU_OUT);
END Structural;