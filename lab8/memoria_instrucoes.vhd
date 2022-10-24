library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoria_instrucoes is
	port(
		ADDR: in  std_logic_vector(3 downto 0);
		DATA: out std_logic_vector(5 downto 0)
	);
end memoria_instrucoes;

architecture rtl of memoria_instrucoes is
	type MemoryT is array(0 to 15) of std_logic_vector(5 downto 0);
	
	signal MEM: MemoryT := (
		0 => "010000", -- set r0
		1 => "000100",	-- clr r1
		2 => "001000",	-- clr r2
		3 => "101000",	-- add r2, r0
		4 => "100001",	-- add r0, r1
		5 => "000100",	-- clr r1
		6 => "100110",	-- add r1, r2
		7 => "110010",	-- jmp 0x2
		others => (others => 'U')
	);
begin
	DATA <= MEM(to_integer(unsigned(ADDR)));
end rtl;

