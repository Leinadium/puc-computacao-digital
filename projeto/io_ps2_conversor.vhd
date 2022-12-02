library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity io_ps2_conversor is
	port (
		PS2_CODE: in std_logic_vector (7 downto 0);
		ASCII: out std_logic_vector (7 downto 0)
	);
end entity ;
architecture rtl of io_ps2_conversor is
	type MemoryT is array (0 to 255) of std_logic_vector (7 downto 0);
	signal MEM : MemoryT := (
		-- https://docs.xilinx.com/v/u/en-US/ug230, pagina 65
		-- https://www.asciitable.com/
		16#45# => x"30", -- 0
		16#16# => x"31", -- 1
		16#1E# => x"32", -- 2
		16#26# => x"33", -- 3
		16#25# => x"34", -- 4
		16#2E# => x"35", -- 5
		16#36# => x"36", -- 6
		16#3D# => x"37", -- 7
		16#3E# => x"38", -- 8
		16#46# => x"39", -- 9
		16#55# => x"2B", -- +
		16#4E# => x"2D", -- -
		16#22# => x"78", -- x (letra)
		16#4A# => x"2F", -- /
		16#5A# => x"0A", -- ENTER
		16#66# => x"08", -- BACKSPACE 
		others => x"6C"  -- [-] para teste
	);
begin
	ASCII <= MEM (to_integer(unsigned(PS2_CODE)));
end architecture ;