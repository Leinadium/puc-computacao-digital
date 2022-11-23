library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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
		-- i/o
		PS2_DADO: in ByteT;
		PS2_VO: in std_logic;
		NUMERO_7SEG: out ByteT;
		LCD_DADO: out ByteT;
		LCD_TIPO: out std_logic;
		LCD_ENABLE: out std_logic
	);
end unidade_load_store;

architecture rtl of unidade_load_store is

	signal reg_ps2, next_ps2: ByteT := (others => '0');
	signal reg_7seg, next_7seg: ByteT := (others => '0');

	type ramT is array(0 to 255) of ByteT;
	-- inserir abaixo a declaracao da memoria:
signal ram: ramT := (
      0 => "11110000", -- simple2.asm: 2:       jmp @main
      1 => "00100000", --
     32 => "00000000", -- simple2.asm: 5: main: ldi  r0, 0x01
     33 => "00000001", --
     34 => "00000100", -- simple2.asm: 6:       ldi  r1, 0x00
     36 => "00001100", -- simple2.asm: 7:       ldi  r3, 0x32
     37 => "00110010", --
     38 => "00111000", -- simple2.asm:10: loop: mov  r2, r0
     39 => "01010001", -- simple2.asm:11:       add  r0, r1
     40 => "00110110", -- simple2.asm:12:       mov  r1, r2
     41 => "00100011", -- simple2.asm:13:       st   r0, [r3]
     42 => "11110000", -- simple2.asm:14:       jmp  @loop
     43 => "00100110", --
     others => "00000000");
	-- fim da insercao ----------------------------------------

begin
	-- processo de escrever ou ler da memoria
	process (CLOCK, ENABLE, ENDERECO, DADO_ENTRADA, reg_ps2, reg_7seg) is
	begin		
		if rising_edge(CLOCK) then
			-- valores default
			DADO_SAIDA <= (others => '0');
			LCD_DADO <= (others => '0');
			LCD_TIPO <= '0';
			LCD_ENABLE <= '0';
			next_7seg <= reg_7seg;
			next_ps2 <= reg_ps2;
			
			-- recebimento do teclado
			if PS2_VO = '1' then
				next_ps2 <= PS2_DADO;
			end if;
			
			-- modo escrita
			if READ_WRITE = MODO_WRITE and ENABLE = '1' then
				case ENDERECO is
					-- verificando se esta escrevendo no 7seg
					when END_DISPLAY =>
						next_7seg <= DADO_ENTRADA;
					
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
	
	-- logica para atualizar o display de 7 seg
	NUMERO_7SEG <= reg_7seg;
end architecture;
