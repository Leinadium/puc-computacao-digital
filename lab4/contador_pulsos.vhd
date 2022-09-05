
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.estruturas.all;


entity contador_pulsos is
	port(
		CLK_50MHZ, BTN_NORTH: in  std_logic;
		J1, J2				  : out std_logic_vector(3 downto 0)
	);
end contador_pulsos;
architecture structural of contador_pulsos is
	component contador is
		port(
			CLK, EN : in std_logic;
			CNT     : out ByteT
			);
	end component;
	
	component detector is
		port (
		CLK, A                : in  std_logic;
		EDGE, POSEDGE, NEGEDGE: out std_logic
	);
	end component;
	
	component exibicao is
		port(
			CLK_50MHZ          : in  std_logic;
			NUMERO 				 : in ByteT;
			SAIDA_J1, SAIDA_J2 : out NibbleT
		);
	end component;
	
	signal QUANTIDADE_BYTE  : ByteT     := (others => '0');
	signal SINAL            : std_logic := '0';
	signal UNUSED1, UNUSED2 : std_logic := '0';
begin
	inst_detector : detector port map (
		CLK      => CLK_50MHZ,
		A        => BTN_NORTH,
		POSEDGE  => SINAL,
		EDGE     => UNUSED1,
		NEGEDGE  => UNUSED2
	);

	inst_contador : contador port map (
		CLK => CLK_50MHZ,
		EN  => SINAL,
		CNT => QUANTIDADE_BYTE
	);
	
	inst_exibicao : exibicao port map (
		CLK_50MHZ => CLK_50MHZ,
		NUMERO    => QUANTIDADE_BYTE,
		SAIDA_J1  => J1,
		SAIDA_J2  => J2
	);

end structural;

