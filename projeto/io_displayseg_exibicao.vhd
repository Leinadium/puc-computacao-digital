library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity io_displayseg_exibicao is
	port(
		CLOCK: in std_logic;
		NUMERO: in ByteT;
		SAIDA_J1, SAIDA_J2: out NibbleT
	);
end io_displayseg_exibicao;

architecture rtl of io_displayseg_exibicao is
	signal c: std_logic := '0';
	signal num_display: std_logic_vector(6 downto 0) := (others => '0');
	signal nibble_exibido : NibbleT := "0000";
begin
	process (CLOCK, NUMERO, c, nibble_exibido) is
		variable qtd : integer range 0 to 50000 := 0;
	begin
		if rising_edge(CLOCK) then
			qtd := qtd + 1;
			if qtd = 50000 then
				c <= not c;
				qtd := 0;
			end if;
		end if;
		if c = '0' then
			nibble_exibido <= NUMERO(3 downto 0);
		else
			nibble_exibido <= NUMERO(7 downto 4);
		end if;
		num_display <= hex2ssd(nibble_exibido);
	end process;
	
	-- ligacao J1
	SAIDA_J1 <= num_display(3 downto 0);
	-- ligacao J2
	SAIDA_J2 <= c & num_display(6 downto 4);

end rtl;

