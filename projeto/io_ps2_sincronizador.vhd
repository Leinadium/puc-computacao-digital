library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity io_ps2_sincronizador is
	port(
		CLOCK, A: in std_logic;
		B: out std_logic
	);
end io_ps2_sincronizador;

architecture rtl of io_ps2_sincronizador is
	signal m: std_logic_vector(1 downto 0);
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of m: signal is "TRUE";
begin
	process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			m <= m(0) & A;
		end if;
	end process;
	B <= m(1);
end rtl;

