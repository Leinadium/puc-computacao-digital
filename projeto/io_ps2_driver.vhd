library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity io_ps2_driver is
	port (
		CLOCK: in std_logic;
		PS2_CLK: in std_logic;
		PS2_DATA: in std_logic;
		CHAR: out ByteT;
		VO: out std_logic
	);
end io_ps2_driver;

architecture structural of io_ps2_driver is
	component io_ps2_receptor is
		port(
			CLOCK: in std_logic;
			PS2_CLK: in std_logic;
			PS2_DATA: in std_logic;
			CODE: out std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	component io_ps2_conversor is
		port (
			SCAN: in std_logic_vector (7 downto 0);
			CHAR: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component io_ps2_filtro is
		port(
			CLOCK: in std_logic;
			VI: in std_logic;
			DIN: in std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	signal receptor_code: ByteT := (others => '0');
	signal receptor_vo: std_logic := '0';
	
begin
	inst_io_ps2_receptor: io_ps2_receptor port map (
		CLOCK => CLOCK,
		PS2_CLK => PS2_CLK,
		PS2_DATA => PS2_DATA,
		CODE => receptor_code,
		VO => receptor_vo
	);
	
	inst_io_ps2_conversor: io_ps2_conversor port map (
		SCAN => receptor_code,
		CHAR => CHAR
	);
	
	inst_io_ps2_filtro: io_ps2_filtro port map (
		CLOCK => CLOCK,
		VI => receptor_vo,
		DIN => receptor_code,
		VO => VO
	);

end structural;

