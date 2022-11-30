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
	signal reg_7seg, next_7seg: ByteT := (others => '0');

	type ramT is array(0 to MEM_SIZE-1) of ByteT;
	-- inserir abaixo a declaracao da memoria:
	-- simple2
  -- ps2_ssd
  signal ram: ramT := (
      0 => "11110000", -- ps2_ssd.asm: 6:       jmp @main
      1 => "00100000", --
     32 => "00001100", -- ps2_ssd.asm:12: main: ldi  r3, @kdr
     33 => "00010100", --
     34 => "00001000", -- ps2_ssd.asm:13:       ldi  r2, @ssd
     35 => "00011000", --
     36 => "00010011", -- ps2_ssd.asm:16: wkbd: ld   r0, [r3]
     37 => "00110000", -- ps2_ssd.asm:17:       mov  r0, r0
     38 => "11110001", -- ps2_ssd.asm:18:       brz  @wkbd
     39 => "00100100", --
     40 => "00100010", -- ps2_ssd.asm:19:       st   r0, [r2]
     41 => "11110000", -- ps2_ssd.asm:20:       jmp  @wkbd
     42 => "00100100", --
     others => "00000000");
	-- fim da insercao ----------------------------------------

begin
	-- processo de escrever ou ler da memoria
	process (CLOCK, ENABLE, ENDERECO, DADO_ENTRADA) is
	begin		
		if rising_edge(CLOCK) then
			-- valores default
			DADO_SAIDA <= (others => '0');
			LCD_DADO <= (others => '0');
			LCD_TIPO <= '0';
			LCD_ENABLE <= '0';
			
			-- recebimento do teclado
			if PS2_VO = '1' then
				ram(byte_para_inteiro(END_PS2)) <= PS2_DADO;
			end if;
			
			-- modo escrita
			if READ_WRITE = MODO_WRITE and ENABLE = '1' then
				case ENDERECO is
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
						DADO_SAIDA <= ram(byte_para_inteiro(END_PS2));
						ram(byte_para_inteiro(END_PS2)) <= (others => '0');	-- limpa o teclado
					-- qualquer outra coisa...
					when others =>
						DADO_SAIDA <= ram(byte_para_inteiro(ENDERECO));
				end case;
			end if;
		end if;
	end process;
	
	-- logica para atualizar o display de 7 seg
	NUMERO_7SEG <= ram(byte_para_inteiro(END_DISPLAY));
end architecture;
