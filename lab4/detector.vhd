library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- importando meu pacote
use work.estruturas.all;

entity detector is
	port (
		CLK, A                : in  std_logic;
		EDGE, POSEDGE, NEGEDGE: out std_logic
	);
end detector;

architecture rtl of detector is
	signal Q: std_logic := '0';
begin
	EDGE    <= Q xor A;	
	POSEDGE <= A and (not Q);
	NEGEDGE <= (not A) and Q;
	
	process(CLK) is
	begin
		if rising_edge(CLK) then
			Q <= A;
		end if;
	end process;
end rtl;

