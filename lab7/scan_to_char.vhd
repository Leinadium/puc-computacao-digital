library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scan_to_char is
	port (
		SCAN: in std_logic_vector (7 downto 0);
		CHAR: out std_logic_vector (7 downto 0)
	);
end entity ;
architecture rtl of scan_to_char is
	type MemoryT is array (0 to 255) of std_logic_vector (7 downto 0);
	signal MEM : MemoryT := (
		16#1C# => x"61", --a
		16#32# => x"62", --b
		16#21# => x"63", --c
		16#23# => x"64", --d
		16#24# => x"65", --e
		16#2B# => x"66", --f
		16#34# => x"67", --g
		16#33# => x"68", --h
		16#43# => x"69", --i
		16#3B# => x"6A", --j
		16#42# => x"6B", --k
		16#4B# => x"6C", --l
		16#3A# => x"6D", --m
		16#31# => x"6E", --n
		16#44# => x"6F", --o
		16#4D# => x"70", --p
		16#15# => x"71", --q
		16#2D# => x"72", --r
		16#1B# => x"73", --s
		16#2C# => x"74", --t
		16#3C# => x"75", --u
		16#2A# => x"76", --v
		16#1D# => x"77", --w
		16#22# => x"78", --x
		16#35# => x"79", --y
		16#1A# => x"7A", --z
		-- others => ( others => 'U' )
		others => x"61" -- para teste
	);
begin
	CHAR <= MEM (to_integer(unsigned(SCAN)));
end architecture ;