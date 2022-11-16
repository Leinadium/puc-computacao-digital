library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package pacote_processador is
	subtype IdentT  is std_logic_vector(1 downto 0);
	subtype NibbleT is std_logic_vector(3 downto 0);
	subtype ByteT   is std_logic_vector(7 downto 0);
	
	-- constantes
	constant TAMANHO_REG: integer := 8;
	constant QUANTIDADE_REG: integer := 4;
	
	constant MODO_READ: std_logic := '0';
	constant MODO_WRITE: std_logic := '1';

	type TipoLCD is (
		T_COMANDO, T_CARACTER
	);

	-- valores especiais de memoria
	constant END_RESET: ByteT    := "00000000";
	constant END_PS2: ByteT      := "00010100";
	constant END_DISPLAY: ByteT  := "00011000";
	constant END_CARACTER: ByteT := "00011001";
	constant END_COMANDO: ByteT  := "00011010";
	constant END_PILHA: ByteT    := "11111111";

	-- instrucoes
	-- acesso de memoria
	constant I_LDI:  NibbleT := "0000"; -- [Rd][00]
	constant I_PUSH: NibbleT := "0000"; -- [Rd][01]
	constant I_POP:  NibbleT := "0000"; -- [Rd][10]
	constant I_LD:   NibbleT := "0001"; -- [Rd][Rr]
	constant I_ST:   NibbleT := "0010"; -- [Rd][Rr]
	-- aritmetica
	constant I_MOV:  NibbleT := "0011"; -- [Rd][00]
	constant I_INC:  NibbleT := "0100"; -- [Rd][00]
	constant I_DEC:  NibbleT := "0100"; -- [Rd][01]
	constant I_INCC: NibbleT := "0100"; -- [Rd][10]
	constant I_DECB: NibbleT := "0100"; -- [Rd][11]
	constant I_ADD:  NibbleT := "0101"; -- [Rd][Rr]
	constant I_SUB:  NibbleT := "0110"; -- [Rd][Rr]
	constant I_CP:   NibbleT := "0111"; -- [Rd][Rr]
	constant I_NEG:  NibbleT := "1000"; -- [Rd][00]
	-- logica
	constant I_NOT:  NibbleT := "1000"; -- [Rd][01]
	constant I_AND:  NibbleT := "1001"; -- [Rd][Rr]
	constant I_OR:   NibbleT := "1010"; -- [Rd][Rr]
	constant I_XOR:  NibbleT := "1011"; -- [Rd][Rr]
	constant I_TST:  NibbleT := "1100"; -- [Rd][Rr]
	constant I_LSL:  NibbleT := "1101"; -- [Rd][00]
	constant I_LSR:  NibbleT := "1101"; -- [Rd][01]
	constant I_ROL:  NibbleT := "1101"; -- [Rd][10]
	constant I_ROR:  NibbleT := "1101"; -- [Rd][11]
	-- saltos
	constant I_IJMP: NibbleT := "1110"; -- [Rd][00]
	constant I_JMP:  NibbleT := "1111"; -- [00][00]
	constant I_BRZ:  NibbleT := "1111"; -- [00][01]
	constant I_BRNZ: NibbleT := "1111"; -- [00][10]
	constant I_BRCS: NibbleT := "1111"; -- [00][00]
	constant I_BRCC: NibbleT := "1111"; -- [01][00]
	
	type Operacao is (
		-- mov:  [Rd, 00, O_ADD]
		-- inc:  [Rd, 01, O_ADD]
		-- dec:  [Rd, 01, O_SUB]
		-- incc: [Rd, c , O_ADD]
		-- decb: [Rd, c*, O_SUB] (c* = c-1)
		-- add:  [Rd, Rr, O_ADD]
		-- sub:  [Rd, Rr, O_SUB]
		-- cp:   [Rd, Rr, O_SUB] (sem pulso no execute)
		-- neg:  [00, Rd, O_SUB] 
		O_ADD, O_SUB,
		-- not:  [Rd, 00, O_NOT]
		-- and:  [Rd, Rr, O_AND]
		-- or:   [Rd, Rr, O_OR ]
		-- xor:  [Rd, Rr, O_XOR]
		-- tst:  [Rd, Rr, O_AND] (sem pulso no execute)
		-- lsl:  [Rd, 00, O_SHL]
		-- lsr:  [Rd, 00, O_SHR]
		-- rol:  [Rd, c , O_SHL]
		-- ror:  [Rd, c , O_SHR]
		O_NOT, O_AND, O_OR, O_XOR, O_SHL, O_SHR
	);
	type InstrucaoT is record
		codigo: NibbleT;
		primeiro, segundo: IdentT; 
	end record;
	
	function decodifica_instrucao(inst: ByteT) return InstrucaoT;
   
	function byte_para_inteiro(b: ByteT) return integer;
	
	function ident_para_inteiro(i: IdentT) return integer;

end package;

package body pacote_processador is
	function decodifica_instrucao(inst: ByteT) return InstrucaoT is
		variable r: InstrucaoT;
	begin
		r.codigo 	:= inst(7 downto 4);
		r.primeiro 	:= inst(3 downto 2);
		r.segundo	:= inst(1 downto 0);
		return r;
	end function;
	
	function byte_para_inteiro(b: ByteT) return integer is
	begin
		return to_integer(unsigned(b));
	end function;
	
	function ident_para_inteiro(i: Ident) return integer is
	begin
		return to_integer(unsigned(b));
	end function;
end package body;