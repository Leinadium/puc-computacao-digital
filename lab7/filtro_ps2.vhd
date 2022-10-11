
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity filtro_ps2 is
	port(
		CLK_50MHZ: in std_logic;
		VI: in std_logic;
		DIN: in std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end filtro_ps2;
architecture rtl of filtro_ps2 is
	-- signal contador: integer range 0 to 2 := 0;
	signal tecla_registro: std_logic_vector(7 downto 0) := (others => '0');
	signal tecla_quantidade: integer range 0 to 8 := 0;
begin
	process (CLK_50MHZ, VI) is
	begin
		if rising_edge(CLK_50MHZ) then
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

