library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.estruturas.all;

entity contador is
	port(
		CLK, EN : in std_logic;
		CNT     : out ByteT
	);
end contador;

architecture rtl of contador is
	signal TEMP : ByteT := (others => '0');
begin
	process (CLK) is
		variable Q: integer range 0 to 255 := 0;
	begin
		if rising_edge(CLK) then
			if EN = '1' then
				Q := Q + 1;
			end if;
		end if;
		TEMP <= std_logic_vector(to_unsigned(Q, 8));
	end process;
	CNT <= TEMP;
	
end rtl;

