library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity divisor is
	port (
		CLOCK_IN: in std_logic;
		CLOCK_OUT: out std_logic
	);
	
	constant MAX: integer := 10000000;
	signal reg: std_logic := '0';
end divisor;

architecture rtl of divisor is
begin
	process (CLOCK_IN) is
		variable q: integer range 0 to MAX := 0;
	begin
		if rising_edge(CLOCK_IN) then
			q := q + 1;
			if q >= MAX - 5 then
				reg <= not reg;
				q := 0;
			end if;
		end if;
	end process;
	CLOCK_OUT <= reg;
end rtl;

