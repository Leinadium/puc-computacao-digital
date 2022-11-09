package pacote_processador is
	subtype IdentT  is std_logic_vector(1 downto 0);
	subtype NibbleT is std_logic_vector(3 downto 0);
	subtype ByteT   is std_logic_vector(7 downto 0);

	-- instrucoes
	-- acesso de memoria
	constant I_LDI:  ByteT := "0000"; -- [Rd][00]
	constant I_PUSH: ByteT := "0000"; -- [Rd][01]
	constant I_POP:  ByteT := "0000"; -- [Rd][10]
	constant I_LD:   ByteT := "0001"; -- [Rd][Rr]
	constant I_ST:   ByteT := "0010"; -- [Rd][Rr]
	-- aritmetica
	constant I_MOV:  ByteT := "0011"; -- [Rd][00]
	constant I_INC:  ByteT := "0100"; -- [Rd][00]
	constant I_DEC:  ByteT := "0100"; -- [Rd][01]
	constant I_INCC: ByteT := "0100"; -- [Rd][10]
	constant I_DECB: ByteT := "0100"; -- [Rd][11]
	constant I_ADD:  ByteT := "0101"; -- [Rd][Rr]
	constant I_SUB:  ByteT := "0110"; -- [Rd][Rr]
	constant I_CP:   ByteT := "0111"; -- [Rd][Rr]
	constant I_NEG:  ByteT := "1000"; -- [Rd][00]
	-- logica
	constant I_NOT:  ByteT := "1000"; -- [Rd][01]
	constant I_AND:  ByteT := "1001"; -- [Rd][Rr]
	constant I_OR:   ByteT := "1010"; -- [Rd][Rr]
	constant I_XOR:  ByteT := "1011"; -- [Rd][Rr]
	constant I_TST:  ByteT := "1100"; -- [Rd][Rr]
	constant I_LSL:  ByteT := "1101"; -- [Rd][00]
	constant I_LSR:  ByteT := "1101"; -- [Rd][01]
	constant I_ROL:  ByteT := "1101"; -- [Rd][10]
	constant I_ROR:  ByteT := "1101"; -- [Rd][11]
	-- saltos
	constant I_IJMP: ByteT := "1110"; -- [Rd][00]
	constant I_JMP:  ByteT := "1111"; -- [00][00]
	constant I_BRZ:  ByteT := "1111"; -- [00][01]
	constant I_BRNZ: ByteT := "1111"; -- [00][10]
	constant I_BRCS: ByteT := "1111"; -- [00][00]
	constant I_BRCC: ByteT := "1111"; -- [01][00]
	
	type Operacao is (
		O_ADD, O_SUB, -- Rd +/- = Rr
		O_INC, O_DEC, -- Rd +/- = 1
		O_LSL, O_LSR, -- rotacao sem carry
		O_ROL, O_ROR  -- rotacao com carry
	);
	type InstrucaoT is record
		codigo:   NibbleT;
		primeiro: NibbleT; 
		segundo:  NibbleT;
	end record;
	
	function decodifica_instrucao(inst: ByteT) return InstrucaoT;
   
	function byte_para_inteiro(b: ByteT) return integer;

end package;

package body pacote_processador is
	function decodifica_instrucao(inst: ByteT) return InstrucaoT is
		signal codigo: NibbleT := inst(7 downto 4);
		signal primeiro: IdentT := inst(3 downto 2);
		signal segundo: IdentT := inst(1 downto 0);
	begin
		return InstrucaoT(codigo, primeiro, segundo);
	end function;
	
	function byte_para_inteiro(b: ByteT) is
	begin
		return to_integer(unsigned(b));
	end function;
end package body;