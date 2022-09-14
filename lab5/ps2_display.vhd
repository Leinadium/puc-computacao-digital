library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps2_display is
	port(
		CLK_50MHZ, PS2_CLK, PS2_DATA: in  std_logic;
		J1, J2							 : out std_logic_vector(3 downto 0)
	);
end entity;

architecture structural of ps2_display is
	component exibicao is
		port (
			CLK_50MHZ: in std_logic;
			NUMERO: in std_logic_vector(7 downto 0);
			SAIDA_J1, SAIDA_J2: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component maquina_estados is
		port(
			CLK: in std_logic;
			CLK_ENTRADA: in std_logic;
			ENTRADA: in std_logic;
			SAIDA: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component sincronizador is
		port(
			CLK, A:  in std_logic;
			B:			out std_logic
		);
	end component;
	
	signal BYTE: std_logic_vector(7 downto 0) := (others => '0');
	signal CLOCK_SYNC: std_logic := '0';
begin
	inst_sincronizador: sincronizador port map(
		CLK => CLK_50MHZ,
		A => PS2_CLK,
		B => CLOCK_SYNC
	);
	
	inst_maquina_estados: maquina_estados port map (
		CLK => CLK_50MHZ,
		CLK_ENTRADA => CLOCK_SYNC,
		ENTRADA => PS2_DATA,
		SAIDA => BYTE
	);
	
	inst_exibicao: exibicao port map(
		CLK_50MHZ => CLK_50MHZ,
		NUMERO => BYTE,
		SAIDA_J1 => J1,
		SAIDA_J2 => J2
	);

end structural;

