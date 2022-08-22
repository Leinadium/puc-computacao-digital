entity lfsr is
    Port ( E : in  STD_LOGIC_VECTOR(15 downto 0);
           S : out STD_LOGIC_VECTOR(15 downto 0));
end lfsr;

architecture rtl of lfsr is
	signal X0, X2, X3, X5, R1, R2, R3: std_logic;
begin
	-- selecionando os valores do array
	X0 <= E(0);
	X2 <= E(2);
	X3 <= E(3);
	X5 <= E(5);
	-- pegando o novo valor
	R1 <= X0 xor X2;
	R2 <= X3 xor X5;
	R3 <= R1 xor R2;
	-- colocando na saida
	S <= R3 & E(15 downto 1);
end rtl;
