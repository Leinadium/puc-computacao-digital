library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity io_ps2_maquina_estados is
	port(
		CLOCK: in  std_logic;
		CLK_ENTRADA: in  std_logic;
		ENTRADA: in  std_logic;
		SAIDA: out std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end io_ps2_maquina_estados;

architecture rtl of io_ps2_maquina_estados is
	-- maquina de estados
	type EstadoT is (
		Parado,	-- estado inicial 
		Inicio, 	-- inicio da transmissao
		EsperaBit, ProximoBit, -- estados para ler os dados
		EsperaFim, ProximoFim  -- estados para ler os ultimos bits
	);
	
	-- sinais
	signal estado_atual: EstadoT := Parado;
	signal q: integer := 0;
	signal subida: std_logic := '0';
	signal descida: std_logic := '0';
	signal saida_buf: std_logic_vector(7 downto 0) := (others => '0');

begin	
	-- processo para atualizar subida e descida
	process(CLK_ENTRADA) is
	begin
		if CLK_ENTRADA = '1' then
			subida <= '1';
			descida <= '0';
		else
			descida <= '1';
			subida <= '0';
		end if;
	end process;
	
	-- maquina de estados
	process(CLOCK, estado_atual) is
	begin
		if rising_edge(CLOCK) then
			VO <= '0';
			-- estado_prox <= estado_atual;
			SAIDA <= saida_buf;
			
			case estado_atual is
				-- estado Parado
				when Parado =>
					q <= 0;
					-- if ENTRADA = '0' then
					if descida = '1' and ENTRADA = '0' then
						estado_atual <= Inicio;
					end if;
					
				-- estado Inicio
				when Inicio =>
					saida_buf <= (others => '0');		-- reinicia
					if subida = '1' then
						estado_atual <= EsperaBit;
					end if;
				
				-- estado EsperaBit
				when EsperaBit =>
					if descida = '1' then
						estado_atual <= ProximoBit;
						saida_buf(q) <= entrada;	 -- leitura do dado
					end if;
				
				-- estado ProximoBot
				when ProximoBit =>
					if subida = '1' then
						if q = 7 then
							estado_atual <= EsperaFim;
							q <= 0;
						else
							estado_atual <= EsperaBit;
							q <= q + 1;
						end if;
					end if;
				
				-- estado EsperaFim
				when EsperaFim =>
					if descida = '1' then
						q <= q + 1;
						estado_atual <= ProximoFim;
						-- nao ha leitura dos dados aqui, desnecessario
					end if;
				
				-- estado ProximoFim
				when ProximoFim =>
					if subida = '1' and q < 2 then
						estado_atual <= EsperaFim;
					
					elsif q = 2 then
						estado_atual <= Parado;
						SAIDA <= saida_buf;	-- escreve na saida
						VO <= '1';
					end if;
			end case;
		end if;
	end process;
end rtl;

