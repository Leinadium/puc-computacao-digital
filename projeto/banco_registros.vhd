library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity banco_registros is
	port(
		CLOCK: in std_logic;
		RD: in IdentT;
		RR: in IdentT;
		Z: in ByteT;
		ENABLE: in std_logic;
		A: out ByteT;
		B: out ByteT
	);
end banco_registros;

architecture rtl of banco_registros is
	-- registros
	type registrosT is array(0 to QUANTIDADE_REG) of ByteT;
	signal registros: registrosT := (others => (others => '0'));
	
	signal indice_a, indice_b: integer := 0;
begin

	indice_a <= ident_para_inteiro(RD);
	indice_b <= indent_para_inteiro(RR);

	A <= registros(indice_a);
	B <= registros(indice_b);

	process (CLOCK, ENABLE) is
	begin
		if rising_edge(CLOCK) then
			if ENABLE = '1' then
				registros(indice_a) <= Z;	-- salvando no registro
			end if;
		end if;
	end process;
end rtl;
