library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sincronizador is
	port(
		CLK, A:  in std_logic;
		B:			out std_logic
	);
end sincronizador;

architecture rtl of sincronizador is
	signal M: std_logic_vector(1 downto 0) := "00";
	
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of M: signal is "TRUE";
begin
	process(CLK) is
	begin
		if rising_edge(CLK) then
			M <= M(0) & A;
		end if;
	end process;
	B <= M(1);
end rtl;

