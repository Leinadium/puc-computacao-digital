--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package estruturas is
	-- definindo Nibble
	subtype NibbleT is std_logic_vector(3 downto 0);
	-- definindo Byte
	subtype ByteT is std_logic_vector(7 downto 0);
	
	function hex2ssd(HEX: NibbleT) return std_logic_vector;
	
	-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);

end estruturas;

package body estruturas is
	function hex2ssd(HEX: NibbleT) return std_logic_vector is
		variable R: std_logic_vector(6 downto 0) := (others => '0');
	begin
		case HEX is
			when "0000" => R := "0111111";
			when "0001" => R := "0000110";
			when "0010" => R := "1011011";
			when "0011" => R := "1001111";
			when "0100" => R := "1100110";
			when "0101" => R := "1101101";
			when "0110" => R := "1111101";
			when "0111" => R := "0000111";
			when "1000" => R := "1111111";
			when "1001" => R := "1100111";
			when "1010" => R := "1110111";
			when "1011" => R := "1111100";
			when "1100" => R := "0111001";
			when "1101" => R := "1011110";
			when "1110" => R := "1111001";
			when others => R := "1110001";
		end case;
		return R;
	end function;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end estruturas;
