library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ALL;

entity medidor_frequencia is
	port(
		CLK_50MHZ, BOTAO: in std_logic;
		J1, J2: out std_logic_vector(3 downto 0)
	);
end medidor_frequencia;

architecture structural of medidor_frequencia is
	component exibicao is
		port (
			CLK_50MHZ: in std_logic;
			NUMERO: in std_logic_vector(7 downto 0);
			ENABLE: in std_logic;
			SAIDA_J1, SAIDA_J2: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component detector is
		port (
			CLK, A: in std_logic;
			EDGE, POSEDGE, NEGEDGE: out std_logic
		);
	end component;
	
	component medidor is
		port(
			CLK_50MHZ: in std_logic;
			ENTRADA: in std_logic;
			SAIDA: out std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	-- component conversor is
	-- 	port (
	-- 		CLK, VI: in std_logic;
	-- 		ENTRADA: in std_logic_vector(7 downto 0);
	-- 		SAIDA: out std_logic_vector(7 downto 0);
	-- 		VO: out std_logic
	-- 	);
	-- end component;
	
	component conversor_copia is
		generic (
			M: integer := 9;
			N: integer := 8
		);
		port (
			CLK, VI: in std_logic;
			A: in std_logic_vector(M-1 downto 0);
			B: in std_logic_vector(N-1 downto 0);
			VO: out std_logic;
			Z: out std_logic_vector(M-1 downto 0)
		);
	end component;

	signal PULSO: std_logic := '0';
	signal NUMERO_PERIODO: std_logic_vector(7 downto 0);
	signal NUMERO_EXIBICAO: std_logic_vector(7 downto 0);
	signal NUMERO_EXIBICAO_BUF: std_logic_vector(8 downto 0);
	signal VO_DIVISOR: std_logic := '0';
	
	signal ENABLE_DIVISAO: std_logic := '0';
	signal ENABLE_EXIBICAO: std_logic := '0';

	constant DIVIDENDO: std_logic_vector(8 downto 0) := "100000000";

begin
	
	inst_detector: detector port map(
		CLK => CLK_50MHZ,
		A => BOTAO,
		POSEDGE => PULSO
	);
	
	inst_medidor: medidor port map (
		CLK_50MHZ => CLK_50MHZ,
		ENTRADA => PULSO,
		SAIDA => NUMERO_PERIODO,
		VO => ENABLE_DIVISAO
	);
	
	inst_exibicao: exibicao port map(
		CLK_50MHZ => CLK_50MHZ,
		NUMERO => NUMERO_EXIBICAO,
		-- NUMERO => NUMERO_PERIODO,
		ENABLE => not BOTAO,
		SAIDA_J1 => J1,
		SAIDA_J2 => J2
	);
	
	-- inst_conversor: conversor port map (
	-- 	CLK => CLK_50MHZ,
	-- 	VI => ENABLE_DIVISAO,
	-- 	ENTRADA => NUMERO_PERIODO,
	-- 	SAIDA => NUMERO_EXIBICAO
	-- 	--VO => ENABLE_EXIBICAO
	-- );
	
	inst_conversor_copia: conversor_copia
		generic map (M => 9, N => 8)
		port map (
			CLK => CLK_50MHZ,
			VI => ENABLE_DIVISAO,
			A => DIVIDENDO,
			B => NUMERO_PERIODO,
			Z => NUMERO_EXIBICAO_BUF,
			VO => ENABLE_EXIBICAO
		);
	
	NUMERO_EXIBICAO <= NUMERO_EXIBICAO_BUF(7 downto 0);
		

end structural;

