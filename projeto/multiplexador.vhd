library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity multiplexador is
	port(
		A, B: in ByteT;
		S: in std_logic;
		Z: out ByteT 
	);
end multiplexador;

architecture rtl of multiplexador is
begin
	Z <= B when S = MULTI_B else A;
end rtl;

