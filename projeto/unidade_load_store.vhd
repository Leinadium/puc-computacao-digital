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
	type ramT is array(0 to MEM_SIZE-1) of ByteT;
	 -- calculadora
  signal ram: ramT := (
      0 => "11110000", -- calculadora.asm:  4:                                jmp @main
      1 => "01001001", --
     32 => "00000001", -- calculadora.asm: 17:                                push r0
     33 => "00001100", -- calculadora.asm: 19:                                ldi  r3, @mem_lcd_caracter
     34 => "00011001", --
     35 => "00010011", -- calculadora.asm: 21:                                ld   r0, [r3]
     36 => "00110000", -- calculadora.asm: 22:                                mov  r0, r0
     37 => "11110010", -- calculadora.asm: 23:                                brnz @escreve_lcd_loop
     38 => "00100001", --
     39 => "00000010", -- calculadora.asm: 25:                                pop  r0
     40 => "00100011", -- calculadora.asm: 26:                                st   r0, [r3]
     41 => "00001110", -- calculadora.asm: 27:                                pop  r3
     42 => "11101100", -- calculadora.asm: 28:                                ijmp r3
     43 => "00000001", -- calculadora.asm: 31:                                push r0
     44 => "00001100", -- calculadora.asm: 33:                                ldi  r3, @mem_lcd_comando
     45 => "00011010", --
     46 => "00010011", -- calculadora.asm: 35:                                ld   r0, [r3]
     47 => "00110000", -- calculadora.asm: 36:                                mov  r0, r0
     48 => "11110010", -- calculadora.asm: 37:                                brnz @escreve_lcd_comando_loop
     49 => "00101100", --
     50 => "00000010", -- calculadora.asm: 39:                                pop  r0
     51 => "00100011", -- calculadora.asm: 40:                                st   r0, [r3]
     52 => "00001110", -- calculadora.asm: 41:                                pop  r3
     53 => "11101100", -- calculadora.asm: 42:                                ijmp r3
     54 => "00001100", -- calculadora.asm: 45:                                ldi  r3, @mem_teclado
     55 => "00010100", --
     56 => "00010011", -- calculadora.asm: 47:                                ld   r0, [r3]
     57 => "00110000", -- calculadora.asm: 48:                                mov  r0, r0
     58 => "11110001", -- calculadora.asm: 49:                                brz  @get_tecla_loop
     59 => "00111000", --
     60 => "00001100", -- calculadora.asm: 51:                                ldi  r3, @mem_seg
     61 => "00011000", --
     62 => "00100011", -- calculadora.asm: 52:                                st   r0, [r3]
     63 => "11110000", -- calculadora.asm: 57:                                jmp  @escreve_lcd
     64 => "00100000", --
     65 => "00001100", -- calculadora.asm: 61:                                ldi  r3, @mem_teclado
     66 => "00010100", --
     67 => "00010011", -- calculadora.asm: 63:                                ld   r0, [r3]
     68 => "00110000", -- calculadora.asm: 64:                                mov  r0, r0
     69 => "11110001", -- calculadora.asm: 65:                                brz  @get_tecla_sem_lcd_loop
     70 => "01000011", --
     71 => "00001110", -- calculadora.asm: 66:                                pop  r3
     72 => "11101100", -- calculadora.asm: 67:                                ijmp r3
     73 => "00000000", -- calculadora.asm: 74:                                ldi  r0, 0x01
     74 => "00000001", --
     75 => "00001100", -- calculadora.asm: 75:                                ldi  r3, @primeira_tecla
     76 => "01010000", --
     77 => "00001101", -- calculadora.asm: 76:                                push r3
     78 => "11110000", -- calculadora.asm: 77:                                jmp @escreve_lcd_comando
     79 => "00101011", --
     80 => "00001100", -- calculadora.asm: 83:                                ldi  r3, @segunda_tecla
     81 => "01010101", --
     82 => "00001101", -- calculadora.asm: 84:                                push r3
     83 => "11110000", -- calculadora.asm: 85:                                jmp  @get_tecla
     84 => "00110110", --
     85 => "00111000", -- calculadora.asm: 87:                                mov  r2, r0
     86 => "00001100", -- calculadora.asm: 89:                                ldi  r3, @terceira_tecla
     87 => "01011011", --
     88 => "00001101", -- calculadora.asm: 90:                                push r3
     89 => "11110000", -- calculadora.asm: 91:                                jmp  @get_tecla
     90 => "00110110", --
     91 => "00110100", -- calculadora.asm: 93:                                mov  r1, r0
     92 => "00001100", -- calculadora.asm: 95:                                ldi  r3, @imprimir_igual
     93 => "01100001", --
     94 => "00001101", -- calculadora.asm: 96:                                push r3
     95 => "11110000", -- calculadora.asm: 97:                                jmp  @get_tecla
     96 => "00110110", --
     97 => "00000001", -- calculadora.asm:100:                                push r0
     98 => "00000000", -- calculadora.asm:101:                                ldi  r0, @ascii_igual
     99 => "00111101", --
    100 => "00001100", -- calculadora.asm:102:                                ldi  r3, @executar_operacao
    101 => "01101001", --
    102 => "00001101", -- calculadora.asm:103:                                push r3
    103 => "11110000", -- calculadora.asm:104:                                jmp  @escreve_lcd
    104 => "00100000", --
    105 => "00000010", -- calculadora.asm:109:                                pop  r0
    106 => "00001100", -- calculadora.asm:115:                                ldi  r3, @ascii_0
    107 => "00110000", --
    108 => "01100011", -- calculadora.asm:116:                                sub  r0, r3
    109 => "01101011", -- calculadora.asm:117:                                sub  r2, r3
    110 => "00001100", -- calculadora.asm:119:                                ldi  r3, @ascii_mais
    111 => "00101011", --
    112 => "01110111", -- calculadora.asm:120:                                cp   r1, r3
    113 => "11110001", -- calculadora.asm:121:                                brz  @operacao_soma
    114 => "01111010", --
    115 => "00001100", -- calculadora.asm:123:                                ldi  r3, @ascii_menos
    116 => "00101101", --
    117 => "01110111", -- calculadora.asm:124:                                cp   r1, r3
    118 => "11110001", -- calculadora.asm:125:                                brz  @operacao_subtracao
    119 => "01111110", --
    120 => "11110000", -- calculadora.asm:128:                                jmp @invalido
    121 => "10011001", --
    122 => "01011000", -- calculadora.asm:130:                                add r2, r0
    123 => "00110010", -- calculadora.asm:131:                                mov r0, r2
    124 => "11110000", -- calculadora.asm:132:                                jmp @resultado
    125 => "10000000", --
    126 => "01101000", -- calculadora.asm:134:                                sub r2, r0
    127 => "00110010", -- calculadora.asm:135:                                mov r0, r2
    128 => "00001100", -- calculadora.asm:142:                                ldi r3, 0x0a
    129 => "00001010", --
    130 => "01110011", -- calculadora.asm:143:                                cp  r0, r3
    131 => "11110011", -- calculadora.asm:144:                                brcs @resultado_ultimo_digito
    132 => "10010001", --
    133 => "00000001", -- calculadora.asm:147:                                push r0
    134 => "00000000", -- calculadora.asm:148:                                ldi  r0, @ascii_1
    135 => "00110001", --
    136 => "00001100", -- calculadora.asm:149:                                ldi  r3, @pos_resultado_primeiro_digito   
    137 => "10001101", --
    138 => "00001101", -- calculadora.asm:150:                                push r3
    139 => "11110000", -- calculadora.asm:151:                                jmp  @escreve_lcd
    140 => "00100000", --
    141 => "00000010", -- calculadora.asm:154:                                pop  r0
    142 => "00001100", -- calculadora.asm:155:                                ldi  r3, 0x0a
    143 => "00001010", --
    144 => "01100011", -- calculadora.asm:156:                                sub  r0, r3
    145 => "00001100", -- calculadora.asm:160:                                ldi  r3, @ascii_0
    146 => "00110000", --
    147 => "01010011", -- calculadora.asm:161:                                add r0, r3
    148 => "00001100", -- calculadora.asm:163:                                ldi  r3, @final
    149 => "10100000", --
    150 => "00001101", -- calculadora.asm:164:                                push r3
    151 => "11110000", -- calculadora.asm:165:                                jmp  @escreve_lcd
    152 => "00100000", --
    153 => "00000000", -- calculadora.asm:171:                                ldi  r0, @ascii_erro
    154 => "00111111", --
    155 => "00001100", -- calculadora.asm:172:                                ldi  r3, @final
    156 => "10100000", --
    157 => "00001101", -- calculadora.asm:173:                                push r3
    158 => "11110000", -- calculadora.asm:174:                                jmp  @escreve_lcd
    159 => "00100000", --
    160 => "00001100", -- calculadora.asm:180:                                ldi  r3, @final_tecla
    161 => "10100101", --
    162 => "00001101", -- calculadora.asm:181:                                push r3
    163 => "11110000", -- calculadora.asm:182:                                jmp  @get_tecla_sem_lcd
    164 => "01000001", --
    165 => "00001100", -- calculadora.asm:184:                                ldi  r3, @ascii_back
    166 => "00001000", --
    167 => "01110011", -- calculadora.asm:185:                                cp   r0, r3
    168 => "11110001", -- calculadora.asm:186:                                brz  @main
    169 => "01001001", --
    170 => "11110000", -- calculadora.asm:187:                                jmp  @final
    171 => "10100000", --
     others => "00000000");

	-- fim da insercao ----------------------------------------

begin
	-- processo de escrever ou ler da memoria
	process (CLOCK, ENABLE, ENDERECO, DADO_ENTRADA, PS2_VO, PS2_DADO, LCD_READY) is
	begin		
		if rising_edge(CLOCK) then
			-- valores default
			DADO_SAIDA <= (others => '0');
			-- LCD_DADO <= (others => '0');
			-- LCD_TIPO <= '0';
			LCD_ENABLE <= '0';
			
			-- recebimento do teclado
			if PS2_VO = '1' then
				ram(byte_para_inteiro(END_PS2)) <= PS2_DADO;
			end if;
			
			-- recebendo ready do lcd --> reinicia tudo
			if LCD_READY = '1' then
				LCD_DADO <= (others => '0');
				LCD_TIPO <= '0';
				ram(byte_para_inteiro(END_CARACTER)) <= (others => '0');
				ram(byte_para_inteiro(END_COMANDO)) <= (others => '0');
			end if;
			
			-- modo escrita
			if READ_WRITE = MODO_WRITE then
				-- deixa as saidas ja configuradas, mesmo o enable sendo 0
				if ENDERECO = END_CARACTER then
					LCD_DADO <= DADO_ENTRADA;
					LCD_TIPO <= T_CARACTER;
				elsif ENDERECO = END_COMANDO then
					LCD_DADO <= DADO_ENTRADA;
					LCD_TIPO <= T_COMANDO;
				end if;
				
				-- escritas
				if ENABLE = '1' then  
					ram(byte_para_inteiro(ENDERECO)) <= DADO_ENTRADA;
					
					if ENDERECO = END_CARACTER then
						LCD_ENABLE <= '1';
					elsif ENDERECO = END_COMANDO then
						LCD_ENABLE <= '1';
					end if;
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
	
	-- DADO_SAIDA <= ram(byte_para_inteiro(ENDERECO));
	
	-- logica para atualizar o display de 7 seg
	NUMERO_7SEG <= ram(byte_para_inteiro(END_DISPLAY));
end architecture;
