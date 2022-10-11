library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity receptor_ps2 is
	port(
		CLK_50MHZ: in std_logic;
		PS2_CLK: in std_logic;
		PS2_DATA: in std_logic;
		CODE: out std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end receptor_ps2;

architecture structural of receptor_ps2 is
	component maquina_estados_ps2 is
		port (
			CLK: in std_logic;
			CLK_ENTRADA: in std_logic;
			ENTRADA: in std_logic;
			SAIDA: out std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	component sincronizador is
		port (
			CLK, A: in std_logic;
			B: out std_logic
		);
	end component;
	
	signal CLK_SYNC: std_logic := '0';
begin
	inst_sincronizador: sincronizador port map(
		CLK => CLK_50MHZ,
		A => PS2_CLK,
		B => CLK_SYNC
	);
	
	inst_maquina_estados: maquina_estados_ps2 port map(
		CLK => CLK_50MHZ,
		CLK_ENTRADA => CLK_SYNC,
		ENTRADA => PS2_DATA,
		SAIDA => CODE,
		VO => VO
	);
end structural;

