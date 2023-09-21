LIBRARY ieee; 
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_unsigned.ALL;
USE WORK.GLOBALS.ALL;

ENTITY RCA IS
	GENERIC (NBIT : integer := NumBit);

	PORT (A:	IN	std_logic_vector(NBIT-1 DOWNTO 0);
        B:	IN	std_logic_vector(NBIT-1 DOWNTO 0);
        Ci:	IN	std_logic;
        S:	OUT	std_logic_vector(NBIT-1 DOWNTO 0);
        Co:	OUT	std_logic);
END RCA; 

ARCHITECTURE STRUCTURAL of RCA is

  SIGNAL STMP : std_logic_vector(NBIT-1 DOWNTO 0);
  SIGNAL CTMP : std_logic_vector(NBIT DOWNTO 0);

  COMPONENT FA
      PORT (A:	IN	std_logic;
            B:	IN	std_logic;
            Ci:	IN	std_logic;
            S:	OUT	std_logic;
            Co:	OUT	std_logic);
  END COMPONENT; 

BEGIN

  CTMP(0) <= Ci;
  S <= STMP;
  Co <= CTMP(NBIT);

  ADDER1: FOR I IN 1 TO NBIT GENERATE
    FAI : FA PORT MAP (A(I-1), B(I-1), CTMP(I-1), STMP(I-1), CTMP(I)); 
  END GENERATE;

END STRUCTURAL;