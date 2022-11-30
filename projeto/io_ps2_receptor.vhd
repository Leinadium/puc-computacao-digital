library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity io_ps2_receptor is
	port(
		CLOCK: in std_logic;
		PS2_CLK: in std_logic;
		PS2_DATA: in std_logic;
		CODE: out std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end io_ps2_receptor;

architecture structural of io_ps2_receptor is
	component io_ps2_maquina_estados is
		port (
			CLOCK: in std_logic;
			CLK_ENTRADA: in std_logic;
			ENTRADA: in std_logic;
			SAIDA: out std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	component io_ps2_sincronizador is
		port (
			CLOCK, A: in std_logic;
			B: out std_logic
		);
	end component;
	
	signal CLK_SYNC: std_logic := '0';
begin
	inst_io_ps2_sincronizador: io_ps2_sincronizador port map(
		CLOCK => CLOCK,
		A => PS2_CLK,
		B => CLK_SYNC
	);
	
	inst_io_ps2_maquina_estados: io_ps2_maquina_estados port map(
		CLOCK => CLOCK,
		CLK_ENTRADA => CLK_SYNC,
		ENTRADA => PS2_DATA,
		SAIDA => CODE,
		VO => VO
	);
end structural;

