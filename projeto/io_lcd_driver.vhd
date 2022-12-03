library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity io_lcd_driver is
	port (
		CLOCK: in std_logic;
		VI: in std_logic;
		BYTE_IN: in std_logic_vector (7 downto 0);
		TIPO_IN: in std_logic;
		
		SF_D: out std_logic_vector(3 downto 0);			
		LCD_E: out std_logic;
		LCD_RS: out std_logic;
		LCD_RW: out std_logic;
		READY: out std_logic
	);
end io_lcd_driver;

architecture structural of io_lcd_driver is
	component io_lcd_conversor is
		port(
			ASCII: in std_logic_vector(7 downto 0);
			TIPO_IN: in std_logic;
			LCD_CODE: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component io_lcd_escrever is
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
	end component;
	
	signal sinal_conversao: std_logic_vector(7 downto 0);
begin

	inst_io_lcd_conversor: io_lcd_conversor port map(
		ASCII => BYTE_IN,
		TIPO_IN => TIPO_IN,
		LCD_CODE => sinal_conversao
	);
	
	inst_io_lcd_escrever: io_lcd_escrever port map(
		CLOCK => CLOCK,
		VI => VI,
		BYTE_IN => sinal_conversao,
		TIPO_IN => TIPO_IN,
		SF_D => SF_D,
		LCD_E => LCD_E,
		LCD_RS => LCD_RS,
		LCD_RW => LCD_RW,
		READY => READY
	);
end structural;

