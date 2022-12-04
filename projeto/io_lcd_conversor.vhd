library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacote_processador.ALL;

entity io_lcd_conversor is
	port(
		ASCII: in std_logic_vector(7 downto 0);
		TIPO_IN: in std_logic;
		LCD_CODE: out std_logic_vector(7 downto 0)
	);
end io_lcd_conversor;

architecture rtl of io_lcd_conversor is
	type MemoryT is array (0 to 255) of std_logic_vector (7 downto 0);
	signal MEM : MemoryT := (
		-- https://docs.xilinx.com/v/u/en-US/ug230, pagina 47
		-- https://www.asciitable.com/
		16#30# => x"30", -- 0 -> 0
		16#31# => x"31", -- 1 -> 1
		16#32# => x"32", -- 2 -> 2
		16#33# => x"33", -- 3 -> 3
		16#34# => x"34", -- 4 -> 4 
		16#35# => x"35", -- 5 -> 5
		16#36# => x"36", -- 6 -> 6
		16#37# => x"37", -- 7 -> 7
		16#38# => x"38", -- 8 -> 8
		16#39# => x"39", -- 9 -> 9
		16#2B# => x"2B", -- + -> +
		16#2D# => x"2D", -- - -> -
		16#0A# => x"3D", -- ENTER -> = 
		others => x"2D"  -- [-] para teste
	);
begin
	LCD_CODE <= MEM(to_integer(unsigned(ASCII))) when TIPO_IN = T_CARACTER 
	            else ASCII;
end rtl;

