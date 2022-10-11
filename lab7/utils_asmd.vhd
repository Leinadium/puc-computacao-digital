library IEEE;
use IEEE.STD_LOGIC_1164.all;

package utils_asmd is
	type InitSequenceElementT is record
		DATA: std_logic_vector(3 downto 0);
		E: std_logic;
		CNT: integer range 0 to 750000;
	end record;
	
	type InitSequenceT is array(0 to 8) of InitSequenceElementT;
	
	constant ISEQ: InitSequenceT := (
		("0000", '0', 750000),
		("0011", '1', 12),
		("0000", '0', 205000),
		("0011", '1', 12),
		("0000", '0', 5000),
		("0011", '1', 12),
		("0000", '0', 2000),
		("0011", '1', 12),
		("0000", '0', 2000)
	);
	
	type ConfSequenceT is array(0 to 3) of std_logic_vector(7 downto 0);
	
	constant CSEQ: ConfSequenceT := (x"28", x"06", x"0C", x"01");

end utils_asmd;

package body utils_asmd is
end utils_asmd;
