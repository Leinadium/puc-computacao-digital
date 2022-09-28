library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity medidor is
	port(
		CLK_50MHZ: in std_logic;
		ENTRADA: in std_logic;
		SAIDA: out std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end medidor;

architecture rtl of medidor is
	signal CONTADOR_CLK: integer range 0 to 3125000 := 0;
	signal CONTADOR_FINAL: integer range 0 to 255 := 0;
	-- signal BORDA: std_logic := '0';
begin
	process(CLK_50MHZ, ENTRADA) is
	begin
		if rising_edge(CLK_50MHZ) then
			VO <= '0';
			if ENTRADA = '1' then
				SAIDA <= std_logic_vector(to_unsigned(CONTADOR_FINAL, 8));
				CONTADOR_CLK <= 0;
				CONTADOR_FINAL <= 0;
				VO <= '1';
			end if;			
			-- se se passaram 1/16 ms
			if CONTADOR_CLK >= 3125000 then
				CONTADOR_CLK <= 0;
				-- soma no contador final
				-- nao deixa passar de 255
				if CONTADOR_FINAL < 255 then
					CONTADOR_FINAL <= CONTADOR_FINAL + 1;
				end if;
			else
				CONTADOR_CLK <= CONTADOR_CLK + 1;
			end if;

		end if;
	end process;
	
end rtl;

