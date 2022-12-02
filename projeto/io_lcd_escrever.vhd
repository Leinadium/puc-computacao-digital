library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.utils_asmd.ALL;

entity io_lcd_escrever is
	port(
		CLOCK: in std_logic;
		VI: in std_logic;
		BYTE_IN: in std_logic_vector (7 downto 0);
		TIPO_IN: in std_logic;
		
		SF_D: out std_logic_vector(3 downto 0); -- nibble saida			
		LCD_E: out std_logic; -- enable do lcd
		LCD_RS: out std_logic; -- troca entre comando e digito
		LCD_RW: out std_logic;	-- rw (vai ser sempre 0)
		READY: out std_logic -- pulso de READY
	);
end io_lcd_escrever;

architecture rtl of io_lcd_escrever is
	-- estados
	type StateT is (
		Inicializacao, -- estado da inicializacao
		DigParado,	-- estado Dig1 (esperando algo) 
		DigSetup,	-- estado Dig2 (criando setup)
		DigEnable, 	-- estado Dig3 (leitura)
		DigHold, 	-- estado Dig4 (criando hold)
		DigLoop		-- estado Dig5 (loop de cooldown)
	);
	signal estado, next_estado: StateT := Inicializacao;
	
	-- registradores
	-- para inicializacao
	signal reg_c, next_c: integer range 0 to 750000 := 0;
	signal reg_i, next_i: integer range 0 to 8 := 0;
	-- para configuracao
	signal reg_ini, next_ini: std_logic := '0';
	signal reg_novodig, next_novodig: std_logic := '0';
	-- para loop geral
	signal reg_entrada, next_entrada: std_logic_vector(7 downto 0) := (others => '0');
	signal reg_q, next_q: integer range 0 to 2000 := 0;
	signal reg_bitnum, next_bitnum: std_logic := '0';
	-- para saidas
	signal reg_SF_D, next_SF_D: std_logic_vector(3 downto 0) := "0000";
	signal reg_LCD_E, next_LCD_E: std_logic := '0';
	signal reg_LCD_RS, next_LCD_RS: std_logic := '0';
	
	-- ALTERACAO: pulso de READY --
	signal reg_ready, next_ready: std_logic := '0';
	-- FIM DA ALTERACAO
	
	-- para setar o VI manualmente ao fazer a configuracao
	signal vi_virtual: std_logic := '0';
	
begin
	-- registradores
	process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			estado <= next_estado;
			reg_c <= next_c;
			reg_i <= next_i;
			reg_ini <= next_ini;
			reg_novodig <= next_novodig;
			reg_entrada <= next_entrada;
			reg_q <= next_q;
			reg_bitnum <= next_bitnum;
			reg_SF_D <= next_SF_D;
			reg_LCD_E <= next_LCD_E;
			reg_LCD_RS <= next_LCD_RS;
			-- ALTERACAO: pulso de READY --
			reg_ready <= next_ready;
			-- FIM DA ALTERACAO --
			
		end if;
	end process;
	
	
	-- maquina de estados pura
	process (
		estado, reg_i, vi_virtual, 
		reg_q, reg_bitnum, reg_c
	) is
	begin
		next_estado <= estado;
		-- outras saidas default
		
		case estado is
			when Inicializacao =>
				if reg_c > ISEQ(reg_i).CNT and reg_i >= 8 then
					next_estado <= DigParado;
				end if;
			
			when DigParado =>
				if vi_virtual = '1' then
					next_estado <= DigSetup;
				end if;
			
			when DigSetup =>
				if reg_q >= 2 then
					next_estado <= DigEnable;
				end if;
			
			when DigEnable =>
				if reg_q >= 12 then
					next_estado <= DigHold;
				end if;
			
			when DigHold =>
				if reg_q >= 50 then
					if reg_bitnum = '1' then
						next_estado <= DigLoop;
					else
						next_estado <= DigSetup;
					end if;
				end if;
			
			when DigLoop =>
				if reg_q >= 2000 then
					next_estado <= DigParado;
				end if;
		end case;
	end process;
	
	-- caminho de dados
	process (
		reg_i, reg_c, vi_virtual, reg_ini,
		reg_novodig, reg_q, reg_bitnum,
		reg_entrada, reg_SF_D, reg_LCD_E,
		reg_LCD_RS, estado, BYTE_IN, TIPO_IN
		) is
	begin
		next_c <= reg_c;
		next_i <= reg_i;
		next_ini <= reg_ini;
		next_novodig <= reg_novodig;
		next_entrada <= reg_entrada;
		next_q <= reg_q;
		next_bitnum <= reg_bitnum;
		next_SF_D <= reg_SF_D;
		next_LCD_E <= reg_LCD_E;
		next_LCD_RS <= reg_LCD_RS;
		-- ALTERACAO: pulso de READY --
		next_ready <= reg_ready;
		-- FIM DA ALTERACAO --
				
		case estado is
			when Inicializacao =>
				next_SF_D <= ISEQ(reg_i).DATA;
				next_LCD_E <= ISEQ(reg_i).E;
				-- primeira decisao
				if reg_c > ISEQ(reg_i).CNT then
					next_c <= 0;
					-- segunda decisao
					if reg_i >= 8 then
						next_i <= 0;
						next_ini <= '1';
						next_novodig <= '1';
						next_LCD_RS <= '0';
						next_entrada <= CSEQ(0);	-- entrada = config_vec[i]
					else
						next_i <= reg_i + 1;
						next_SF_D <= ISEQ(reg_i + 1).DATA;
						next_LCD_E <= ISEQ(reg_i + 1).E;
					end if;
				else
					next_c <= reg_c + 1;
				end if;
				
			when DigParado =>
				if vi_virtual = '1' then
					-- ALTERACAO: pulso de READY --
					next_ready <= '0';
					-- FIM DA ALTERACAO --
				
					if reg_novodig = '1' then
						next_SF_D <= reg_entrada(7 downto 4);	-- SD_F = entrada[parte1]
					else
						next_SF_D <= BYTE_IN(7 downto 4);
						next_LCD_RS <= TIPO_IN;
					end if;
					next_q <= 0;
					-- next_novodig <= '0';
				end if;
			
			when DigSetup =>
				if reg_q >= 2 then
					next_q <= 0;
					next_LCD_E <= '1';
				else
					next_q <= reg_q + 1;
				end if;
			
			when DigEnable =>
				if reg_q >= 12 then
					next_q <= 0;
					next_LCD_E <= '0';
				else
					next_q <= reg_q + 1;
				end if;
			
			when DigHold =>
				if reg_q >= 50 then
					next_q <= 0;
					if reg_bitnum = '0' then
						next_bitnum <= '1';
						if reg_novodig = '1' then
							next_SF_D <= reg_entrada(3 downto 0);-- TODO: SD_F = entrada[parte2]
						else
							next_SF_D <= BYTE_IN(3 downto 0);
						end if;
					else
						next_bitnum <= '0';
					end if;
				else
					next_q <= reg_q + 1;
				end if;
			
			when DigLoop =>
				-- ALTERACAO: pulso de READY --
				next_ready <= '1';
				-- FIM DA ALTERACAO
				if reg_q >= 2000 then
					if reg_ini = '1' then				
						next_q <= 0;
						if reg_i = 3 then
							next_ini <= '0';
							next_novodig <= '0';
							next_LCD_RS <= '1';
						else
							next_i <= reg_i + 1;
							next_entrada <= CSEQ(reg_i + 1);
							next_novodig <= '1';
						end if;
					end if;
				else
					next_q <= reg_q + 1;
				end if;
		end case;
		
		
	end process;
	
	-- codigo combinacional basico
	LCD_RW <= '0';		-- LCD_RW sempre 0
	vi_virtual <= VI or reg_novodig;	-- Para usar o VI ou o NOVODIG
	LCD_RS <= reg_LCD_RS;
	LCD_E <= reg_LCD_E;
	SF_D <= reg_SF_D;
	READY <= reg_ready;
	
end rtl;

