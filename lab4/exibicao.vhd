
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.estruturas.all;

entity exibicao is
	port(
		CLK_50MHZ          : in  std_logic;
		NUMERO 				 : in ByteT;
		SAIDA_J1, SAIDA_J2 : out NibbleT
	);
end exibicao;

architecture rtl of exibicao is
	signal C: std_logic := '0';
	signal NUM_DISPLAY : std_logic_vector(6 downto 0) := (others => '0');
	signal NIBBLE_EXIBIDO : NibbleT := "0000";
begin
	process (CLK_50MHZ, NUMERO, C, NIBBLE_EXIBIDO) is
		variable QTD : integer range 0 to 50000 := 0;
	begin
		if rising_edge(CLK_50MHZ) then
			QTD := QTD + 1;
			if QTD = 50000 then
				C <= not C;
				QTD := 0;
			end if;
		end if;
		if C = '0' then
			NIBBLE_EXIBIDO <= NUMERO(3 downto 0);
		else
			NIBBLE_EXIBIDO <= NUMERO(7 downto 4);
		end if;
		NUM_DISPLAY <= hex2ssd(NIBBLE_EXIBIDO);
	end process;
	
	-- ligacao J1
	SAIDA_J1 <= NUM_DISPLAY(3 downto 0);
	-- ligacao J2
	SAIDA_J2 <= C & NUM_DISPLAY(6 downto 4);
end rtl;

