library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity maquina_estados is
	port(
		CLK			: in  std_logic;
		CLK_ENTRADA	: in  std_logic;
		ENTRADA		: in  std_logic;
		SAIDA			: out std_logic_vector(7 downto 0)
	);
end maquina_estados;

architecture rtl of maquina_estados is
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
	-- esse processo é irrelevante pois não utilizo a borda do clock
	-- pode ser trocado por código concorrente:
	-- subida = '1' when CLK_ENTRADA = '1' else '0'
	-- descida = '1' when CLK_ENTRADA = '0' else '1'
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
	process(CLK) is
	begin
		if rising_edge(CLK) then
			case estado_atual is
				-- estado Parado
				when Parado =>
					q <= 0;
					if descida = '1' and ENTRADA = '0' then
						estado_atual <= Inicio;
					end if;
					
				-- estado Inicio
				when Inicio =>
					saida_buf <= (others => '0');
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
					end if;
					
			end case;
		end if;
	end process;
	
end rtl;

