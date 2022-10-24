library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
	port (
		OP: in std_logic_vector(1 downto 0);
		A: in std_logic_vector(7 downto 0);
		B: in std_logic_vector(7 downto 0);
		
		Z: out std_logic_vector(7 downto 0)
	);
end alu;

architecture rtl of alu is
	signal rd, rr, result: unsigned(7 downto 0);
begin
	
	rd <= unsigned(A);
	rr <= unsigned(B);

	with OP select
		result <= 
			"00000000" when "00",
			"00000001" when "01",
			rd + rr when "10",
			"00000000" when others;

	Z <= std_logic_vector(result);

end rtl;

