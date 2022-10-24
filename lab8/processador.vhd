library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity processador is
	port (
		CLK: in std_logic;
		DATA: out std_logic_vector(5 downto 0);
		RD, RR: out std_logic_vector(7 downto 0)
	);
end processador;

architecture structural of processador is
	component control_unit is
		port (
			CLK: in std_logic;
			DATA: in std_logic_vector(5 downto 0);
			ADDR: out std_logic_vector(3 downto 0);
			OP: out std_logic_vector(1 downto 0);
			EN: out std_logic;
			SEL: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component memoria_instrucoes is
		port (
			ADDR: in std_logic_vector(3 downto 0);
			DATA: out std_logic_vector(5 downto 0)
		);
	end component;
	
	component banco_registros is
		port (
			CLK: in std_logic;
			EN: in std_logic;
			SEL: in std_logic_vector(3 downto 0);
			Z: in std_logic_vector(7 downto 0);
			A: out std_logic_vector(7 downto 0);
			B: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component alu is
		port (
			OP: in std_logic_vector(1 downto 0);
			A: in std_logic_vector(7 downto 0);
			B: in std_logic_vector(7 downto 0);
			Z: out std_logic_vector(7 downto 0)
		);
	end component;
	
	-- sinais
	signal instrucao: std_logic_vector(5 downto 0) := (others => '0');
	signal endereco, selecao: std_logic_vector(3 downto 0) := (others => '0');
	signal operacao: std_logic_vector(1 downto 0) := "00";
	signal enable: std_logic;
	signal r1, r2, re: std_logic_vector(7 downto 0) := (others => '0');
	
begin
	inst_control_unit: control_unit port map (
		CLK => CLK,
		DATA => instrucao,
		ADDR => endereco,
		OP => operacao,
		EN => enable,
		SEL => selecao
	);
	
	inst_imem: memoria_instrucoes port map (
		ADDR => endereco,
		DATA => instrucao
	);
	
	inst_banco_registros: banco_registros port map (
		CLK => CLK,
		EN => enable,
		SEL => selecao,
		Z => re,
		A => r1,
		B => r2
	);
	
	inst_alu: alu port map (
		OP => operacao,
		A => r1,
		B => r2,
		Z => re
	);
	
	DATA <= instrucao;
	RD <= r1;
	RR <= r2;

end structural;

