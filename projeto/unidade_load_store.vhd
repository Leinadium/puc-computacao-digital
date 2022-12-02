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
		LCD_ENABLE: out std_logic;
		LCD_READY: in std_logic
	);
end unidade_load_store;

architecture rtl of unidade_load_store is
	signal reg_7seg, next_7seg: ByteT := (others => '0');

	type ramT is array(0 to MEM_SIZE-1) of ByteT;
	-- ps2_ssd_lcd
	signal ram: ramT := (
      0 => "11110000", -- ps2_ssd_lcd.asm: 7:       jmp @main
      1 => "00100000", --
     32 => "00001100", -- ps2_ssd_lcd.asm:13: main: ldi  r3, @kdr
     33 => "00010100", --
     34 => "00001000", -- ps2_ssd_lcd.asm:14:       ldi  r2, @ssd
     35 => "00011000", --
     36 => "00000100", -- ps2_ssd_lcd.asm:15:       ldi  r1, @lcd
     37 => "00011001", --
     38 => "00010011", -- ps2_ssd_lcd.asm:18: wkbd: ld   r0, [r3]
     39 => "00110000", -- ps2_ssd_lcd.asm:19:       mov  r0, r0
     40 => "11110001", -- ps2_ssd_lcd.asm:20:       brz  @wkbd
     41 => "00100110", --
     42 => "00100010", -- ps2_ssd_lcd.asm:21:       st   r0, [r2]
     43 => "00100001", -- ps2_ssd_lcd.asm:22:       st   r0, [r1]
     44 => "11110000", -- ps2_ssd_lcd.asm:23:       jmp  @wkbd
     45 => "00100110", --
     others => "00000000");
	-- fim da insercao ----------------------------------------

begin
	-- processo de escrever ou ler da memoria
	process (CLOCK, ENABLE, ENDERECO, DADO_ENTRADA, PS2_VO, PS2_DADO, LCD_READY) is
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
			
			-- recebendo ready do lcd
			if LCD_READY = '0' then
				ram(byte_para_inteiro(END_CARACTER)) <= (others => '0');
				ram(byte_para_inteiro(END_COMANDO)) <= (others => '0');
			end if;
			
			-- modo escrita
			if READ_WRITE = MODO_WRITE and ENABLE = '1' then
				-- sempre escreve na memoria
				ram(byte_para_inteiro(ENDERECO)) <= DADO_ENTRADA;
				
				if ENDERECO = END_CARACTER then
					LCD_ENABLE <= '1';
					LCD_DADO <= DADO_ENTRADA;
					LCD_TIPO <= T_CARACTER;
				elsif ENDERECO = END_COMANDO then
					LCD_ENABLE <= '1';
					LCD_DADO <= DADO_ENTRADA;
					LCD_TIPO <= T_COMANDO;
				end if;
		
			elsif READ_WRITE = MODO_READ and ENABLE = '1' then -- modo leitura
				
				DADO_SAIDA <= ram(byte_para_inteiro(ENDERECO));
				
				if ENDERECO = END_PS2 then
					-- verificando se esta lendo do teclado
					ram(byte_para_inteiro(END_PS2)) <= (others => '0');	-- limpa o teclado
				end if;
			end if;
			
		end if;
	end process;
	
	-- logica para atualizar o display de 7 seg
	NUMERO_7SEG <= ram(byte_para_inteiro(END_DISPLAY));
end architecture;
