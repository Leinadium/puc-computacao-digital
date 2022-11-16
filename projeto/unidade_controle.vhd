library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity unidade_controle is
	port(
		CLOCK: in std_logic;
		
		MEMORIA_IN: in ByteT;
		MEMORIA_ENDERECO: out ByteT;
		MEMORIA_OUT: out ByteT;
		MEMORIA_ENABLE: out std_logic;
		
		ALU_OPERACAO: out Operacao;
		ALU_RESULT: in ByteT;
		F_ZERO_IN: in std_logic;
		F_CARRY_IN: in std_logic;
		
		REGISTRO_RD: out IdentT;
		REGISTRO_RR: out Ident;
		REGISTRO_ENABLE: out std_logic
	);
end unidade_controle;

architecture rtl of unidade_controle is
begin
end rtl;
