LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE WORK.GLOBALS.ALL;


ENTITY Boothmul IS
GENERIC (N_BIT : integer := NumBitMul);

	PORT (F1,F2	: IN STD_LOGIC_VECTOR (N_BIT/2-1 DOWNTO 0);	-- two operands input (the two factors)
	      HI_OR_LOW : in std_logic;                         -- 1 selects HI, 0 selects LOW
          R	: OUT STD_LOGIC_VECTOR (N_BIT/2-1 DOWNTO 0));		-- multiplication result

END Boothmul;


ARCHITECTURE STRUCTURAL OF Boothmul IS

	TYPE mux_input_array IS ARRAY (0 TO (5*(N_BIT/4))-1 ) OF std_logic_vector(N_BIT-1 DOWNTO 0);
	SIGNAL mux_input: mux_input_array;

	TYPE mux_array IS ARRAY (0 TO ((N_BIT/4)-1) ) OF std_logic_vector(2 DOWNTO 0);
	SIGNAL mux_selector: mux_array;
	
	TYPE adder_entry_array IS ARRAY (0 TO ((N_BIT/4)-1) ) OF std_logic_vector(N_BIT-1 DOWNTO 0);
	SIGNAL adder_entry : adder_entry_array;

	TYPE adder_array IS ARRAY (0 TO ((N_BIT/4)-1) ) OF std_logic_vector(N_BIT-1 DOWNTO 0);
	SIGNAL adder_result: adder_array;

	SIGNAL F2_extend : std_logic_vector (N_BIT/2 DOWNTO 0);


			-- COMPONENT DECLARATION

-- BLOCK FOR THE GENERATION OF THE INPUT OF THE MUX
COMPONENT Mult_num_generation IS
GENERIC ( N_BIT : integer := NumBit);

	PORT (	S				: IN INTEGER;
				X				: IN STD_LOGIC_VECTOR (N_BIT/2-1 DOWNTO 0);		
				A,B,C,D,E	: OUT STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0));

END COMPONENT;

-- BLOCK FOR THE 5 INPUT MUX
COMPONENT Mult_mux IS
GENERIC ( N_BIT : integer := NumBit);

	PORT (	A,B,C,D,E	: IN STD_LOGIC_VECTOR(N_BIT-1 DOWNTO 0);
	
				S				: IN STD_LOGIC_VECTOR (2 DOWNTO 0);

				Y				: OUT STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0));

END COMPONENT;

-- BLOCK FOR GENERATION OF THE SELECTOR FOR THE MUX
COMPONENT Mult_encoder IS

	PORT (	A0,A1,A2		: IN STD_LOGIC;

				S				: OUT STD_LOGIC_VECTOR (2 DOWNTO 0));

END component;

-- BLOCK FOR THE 2'S COMPLEMENT ADDITION

COMPONENT rca IS
	GENERIC (NBIT : integer := NumBit);

	PORT (A	:	IN STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0);
		  B	:	IN STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0);
		  Ci :	IN STD_LOGIC;
		  S	:	OUT STD_LOGIC_VECTOR (N_BIT-1 DOWNTO 0);
		  Co :	OUT STD_LOGIC);

END COMPONENT;

COMPONENT MUX21_GENERIC IS
	GENERIC(NBIT: integer:= NumBit);

	PORT(A, B: IN std_logic_vector(NBIT-1 DOWNTO 0);
		 SEL: IN std_logic;
		 Y: OUT std_logic_vector(NBIT-1 DOWNTO 0));

END COMPONENT;

				-- MAIN BLOCK STRUCTURE

BEGIN

				-- COMPONENTS GENERATION

	F2_extend <= F2 & '0';

	MUX_INPUT_GENERATION : FOR I IN 0 TO N_BIT/4-1 GENERATE
	
		MUX_I : Mult_mux GENERIC MAP (N_BIT) PORT MAP (A => mux_input(I*5), B => mux_input((I*5)+1), C => mux_input((I*5)+2), D => mux_input((I*5)+3), E => mux_input((I*5)+4), S => mux_selector(I), Y => adder_entry(I));

	-- INPUT NUMBER GENERATION
		INPUT_NUM_I : Mult_num_generation GENERIC MAP (N_BIT) PORT MAP (S => 2*I, X => F1, A => mux_input(I*5), B => mux_input((I*5)+1), C => mux_input((I*5)+2), D => mux_input((I*5)+3), E => mux_input((I*5)+4));

	END GENERATE;

	ENCODER_GENERATION : FOR I IN 0 TO N_BIT/4-1 GENERATE
	-- ENCODER GENERATION
		ENCODER_I : Mult_encoder PORT MAP (A0 => F2_extend(2*I), A1 => F2_extend((2*I)+1), A2 => F2_extend((2*I)+2), S => mux_selector(I));
	END GENERATE;

	adder_result(0) <= adder_entry(0);

	ADDER_GENERATION: FOR I IN 0 TO (N_BIT/4)-2 GENERATE
	-- ADDER GENERATION
		ADDER_I : rca GENERIC MAP (N_BIT) PORT MAP (A => adder_result(I), B => adder_entry(I+1), Ci => '0', S => adder_result(I+1), Co => open);
	END GENERATE;
	
	-- R <= adder_result((N_BIT/4)-1);
	
	MUX21_SELECTOR_HI_LO_MUL : MUX21_GENERIC GENERIC MAP (N_BIT/2) PORT MAP (A => adder_result((N_BIT/4)-1)(N_BIT-1 DOWNTO (N_BIT/2)), B => adder_result((N_BIT/4)-1)((N_BIT/2)-1 DOWNTO 0), SEL => HI_OR_LOW, Y => R);

END STRUCTURAL;