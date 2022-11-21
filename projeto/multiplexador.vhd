library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexador is
	port(
		A, B: in ByteT;
		S: in std_logic;
		Z: out ByteT 
	);
end multiplexador;

architecture rtl of multiplexador is
begin
	with S select
		Z <= A when MULTI_A,
		     B when MULTI_B;

end rtl;

