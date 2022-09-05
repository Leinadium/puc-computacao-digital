library ieee;
use ieee.std_logic_1164.all;

entity teste is
end entity;

architecture behavior of teste is
	-- Sinais
	signal CLK_50MHZ, BTN_NORTH: std_logic := '0';
	signal J1, J2 : std_logic_vector(3 downto 0);
	
	-- clock
	constant CLK_50MHZ_PERIOD : time := 20 ns;
begin
	uut: entity work.contador_pulsos port map (CLK_50MHZ, BTN_NORTH, J1, J2);
	
	-- Clock
	process
	begin
		CLK_50MHZ <= '0';
		wait for CLK_50MHZ_PERIOD/2;
		CLK_50MHZ <= '1';
		wait for CLK_50MHZ_PERIOD/2;
	end process;
	
	-- Stimulus
	process
	begin
		loop
			-- apertar por 10us
			wait for 10 us;
			BTN_NORTH <= '1';
			wait for 10 us;
			BTN_NORTH <= '0';
			
			-- aguardar 5 ms
			wait for 5 ms;
		end loop;
	end process;
end;