
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity io_ps2_filtro is
	port(
		CLOCK: in std_logic;
		VI: in std_logic;
		DIN: in std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end io_ps2_filtro;
architecture rtl of io_ps2_filtro is
	-- signal tecla_registro: std_logic_vector(7 downto 0) := (others => '0');
	signal tecla_quantidade: integer range 0 to 8 := 0;
begin
	process (CLOCK, VI) is
	begin
		if rising_edge(CLOCK) then
			VO <= '0';		-- VO default
			
			-- a implementacao a seguir so deixa uma tecla
			-- ser pressionada ao mesmo tempo
			-- para mais teclas, acredito que precisaria de mais registros...
			
			-- exemplo, tecla AA pressionada e levantada
			-- AA F0 AA: sinal VI
			
			if VI = '1' then
				if DIN = "11110000" then	-- adiciona mais uma em teclas pressionadas
					tecla_quantidade <= tecla_quantidade + 1;
				else
					if tecla_quantidade > 0 then	-- se tinha alguma pressionada, tira da contagem
						tecla_quantidade <= tecla_quantidade - 1;
					else
						VO <= '1';	-- nao tinha nenhuma, entao essa pode mostrar 
					end if;
				end if;
			end if;
			
		end if;
	end process;
end rtl;

