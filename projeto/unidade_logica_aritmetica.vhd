library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacote_processador.ALL;

entity unidade_logica_aritmetica is
	generic (N: integer := 8);
	port(
		A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(N-1 downto 0);
		OPERACAO: in Operacao;
		
		Z: out std_logic_vector(N-1 downto 0);
		F_CARRY: out std_logic;
		F_ZERO: out std_logic
	);
end unidade_logica_aritmetica;

architecture rtl of unidade_logica_aritmetica is
	constant zero: std_logic_vector(N-1 downto 0) := (others => '0');
	-- registradores de unsigned
	signal regA, regB: unsigned(N-1 downto 0);
	-- sinais contendo um bit a mais para as operacoes
	signal tempA, tempB, tempZ: unsigned(N downto 0);
	-- sinal copia da saida
	signal saidaZ: std_logic_vector(N-1 downto 0);
begin
	-- converte para unsigneds
	regA <= unsigned(A);
	regB <= unsigned(B);
	-- coloca mais um bit na frente para as operacoes
	tempA <= resize(regA, N + 1);
	tempB <= resize(regB, N + 1);
	
	with OPERACAO select
		tempZ <=
			tempA + tempB                          when O_ADD,
			tempA - tempB                          when O_SUB,
			0 - tempA                              when O_NEG,
			'0' & not tempA(N-1 downto 0)          when O_NOT,
			tempA and tempB                        when O_AND,
			tempA or tempB                         when O_OR,
			tempA xor tempB                        when O_XOR,
			tempA(N-1 downto 0) & tempB(0)         when O_SHL,
			'0' & tempB(0) & tempA(N-1 downto 1)   when O_SHR,
			(others => '0')                        when O_XXX
			;
			
	-- saidaZ eh usado para conseguir depois
	-- reutilizar o valor para o F_ZERO,
	-- pois Z eh somente escrita, nao leitura	
	saidaZ <= std_logic_vector(tempZ(N-1 downto 0));
	
	-- saidas
	Z	<= saidaZ;
	F_CARRY <= tempZ(N);
	F_ZERO <= '1' when saidaZ = zero else '0';
end rtl;

