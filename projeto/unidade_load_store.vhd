library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity unidade_load_store is
	port (
		-- entrada/saida da control unit
		CLOCK: in std_logic; 
		ENDERECO: in ByteT;
		DADO_ENTRADA: in ByteT;
		READ_WRITE: in std_logic;
		ENABLE: in std_logic;
		DADO_SAIDA: out ByteT;
		
		-- io
		PS2_DADO: in ByteT;
		PS2_VO: in std_logic;
		NUMERO_7SEG: out ByteT;
		LCD_DADO: out ByteT;
		LCD_TIPO: out TipoLCD;
		LCD_ENABLE: out std_logic
	);
end entity;

architecture rtl of unidade_load_store is

	signal reg_ps2, next_ps2: ByteT := (others => '0');
	signal reg_7seg, next_7seg: ByteT := (others => '0');

	type ramT is array(0 to 255) of ByteT;
	-- inserir abaixo a declaracao da memoria:
	signal ram: ramT := (others => (others => '0'));
	-- fim da insercao

begin
	-- processo de escrever ou ler da memoria
	process (CLOCK, ENABLE, ENDERECO) is
	begin
		-- valores default
		DADO_SAIDA <= (others => '0');
		LCD_DADO <= (others => '0');
		LCD_TIPO <= COMANDO;
		LCD_ENABLE <= '0';
		
		if rising_edge(CLOCK) then
			-- modo escrita
			if ENABLE = '1' then
				case ENDERECO is
					-- verificando se esta escrevendo no 7seg
					when END_DISPLAY =>
						reg_7seg <= DADO_ENTRADA;
					
					-- verificando se esta escrevendo no lcd
					when END_CARACTER =>
						LCD_ENABLE <= '1';
						LCD_DADO <= DADO_ENTRADA;
						LCD_TIPO <= T_CARACTER;
					when END_COMANDO =>
						LCD_ENABLE <= '1';
						LCD_DADO <= DADO_ENTRADA;
						LCD_TIPO <= T_COMANDO;
					
					-- senao, escreve na memoria normal mesmo
					when others =>
						ram(byte_para_inteiro(ENDERECO)) <= DADO_ENTRADA;
				end case;
			else  -- modo leitura
				case ENDERECO is
					-- verificando se esta lendo do teclado
					when END_PS2 =>
						DADO_SAIDA <= reg_ps2;
						next_ps2 <= (others => '0');	-- limpa o teclado
					-- verificando lendo do display (talvez nunca aconteca)
					when END_DISPLAY =>
						DADO_SAIDA <= reg_7seg;
					-- qualquer outra coisa...
					when others =>
						DADO_SAIDA <= ram(byte_para_inteiro(ENDERECO));
				end case;
			end if;
		end if;
	end process;
	
	-- processo de atualizacao dos registros
	process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			reg_ps2 <= next_ps2;
			reg_7seg <= next_7seg;
		end if;
	end process;
	
	-- processo para ler o teclado
	process (CLOCK, PS2_DADO, PS2_VO) is
	begin
		if rising_edge(CLOCK) then
			if PS2_VO = '1' then
				next_ps2 <= PS2_DADO;
			end if;
		end if;
	end process;
end architecture;
