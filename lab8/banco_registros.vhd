library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity banco_registros is
	port(
		CLK: in std_logic;
		EN: in std_logic;
		SEL: in std_logic_vector(3 downto 0); -- [Rd,Rr]
		Z: in std_logic_vector(7 downto 0);
		
		A: out std_logic_vector(7 downto 0);
		B: out std_logic_vector(7 downto 0)
	);
end banco_registros;

architecture rtl of banco_registros is
	type ArrayRegistrosT is array (0 to 3) of std_logic_vector(7 downto 0);
	signal registros: ArrayRegistrosT := ( others => (others => '0') );
	signal Rd, Rr: integer range 0 to 3 := 0;
begin
	process (CLK, EN) is
	begin
		if rising_edge(CLK) and EN = '1' then
			registros(Rd) <= Z;
		end if;
	end process;
	Rd <= to_integer(unsigned(SEL(3 downto 2)));
	Rr <= to_integer(unsigned(SEL(1 downto 0)));
	A <= registros(Rd);
	B <= registros(Rr);
end rtl;

