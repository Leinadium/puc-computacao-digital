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
	constant MAX_REG: integer := 255;
	
	constant MODO_READ: std_logic := '0';
	constant MODO_WRITE: std_logic := '1';
	
	constant MULTI_A: std_logic := '0';
	constant MULTI_B: std_logic := '1';

	constant	T_COMANDO: std_logic := '0';
	constant T_CARACTER: std_logic := '1';

	-- valores especiais de memoria
	constant END_RESET: ByteT    := "00000000";
	constant END_PS2: ByteT      := "00010100";
	constant END_DISPLAY: ByteT  := "00011000";
	constant END_CARACTER: ByteT := "00011001";
	constant END_COMANDO: ByteT  := "00011010";
	constant END_PILHA: ByteT    := "11111111";

	-- instrucoes
	-- acesso de memoria
	type CodigoInstrucao is (
		CI_LDI, CI_PUSH, CI_POP, CI_LD, CI_ST,
		CI_MOV, CI_INC, CI_DEC, CI_INCC, CI_DECB,
		CI_ADD, CI_SUB, CI_CP, CI_NEG, CI_NOT, 
		CI_AND, CI_OR, CI_XOR, CI_TST, CI_LSL, 
		CI_LSR, CI_ROL, CI_ROR, CI_IJMP, CI_JMP, 
		CI_BRZ, CI_BRNZ, CI_BRCS, CI_BRCC,
		CI_UNDEFINED
	);
	constant I_LDI:  NibbleT := "0000"; -- [Rd][00]
	constant I_PUSH: NibbleT := "0000"; -- [Rd][01]
	constant I_POP:  NibbleT := "0000"; -- [Rd][10]
	constant I_LD:   NibbleT := "0001"; -- [Rd][Rr]
	constant I_ST:   NibbleT := "0010"; -- [Rd][Rr]
	-- aritmetica
	constant I_MOV:  NibbleT := "0011"; -- [Rd][Rr]
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
	constant I_BRCS: NibbleT := "1111"; -- [00][11]
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
		-- neg:  [Rd, 00, O_NEG] 
		O_ADD, O_SUB, O_NEG,
		-- not:  [Rd, 00, O_NOT]
		-- and:  [Rd, Rr, O_AND]
		-- or:   [Rd, Rr, O_OR ]
		-- xor:  [Rd, Rr, O_XOR]
		-- tst:  [Rd, Rr, O_AND] (sem pulso no execute)
		-- lsl:  [Rd, 00, O_SHL]
		-- lsr:  [Rd, 00, O_SHR]
		-- rol:  [Rd, c , O_SHL]
		-- ror:  [Rd, c , O_SHR]
		O_NOT, O_AND, O_OR, O_XOR, O_SHL, O_SHR,
		O_XXX	-- operacao invalida
	);
	type InstrucaoT is record
		codigo: CodigoInstrucao;
		primeiro, segundo: IdentT; 
	end record;
	
	function decodifica_instrucao(inst: ByteT) return InstrucaoT;
   
	function byte_para_inteiro(b: ByteT) return integer;
	
	function inteiro_para_byte(int: integer) return ByteT;
	
	function ident_para_inteiro(i: IdentT) return integer;

end package;

package body pacote_processador is
	function decodifica_instrucao(inst: ByteT) return InstrucaoT is
		variable r: InstrucaoT := (CI_UNDEFINED, "00", "00");
		variable x: NibbleT := inst(7 downto 4);
		variable y: IdentT := inst(3 downto 2);
		variable z: IdentT := inst(1 downto 0);
	begin
		case x is
			when "0000" => 
				case z is
					when "00" => r := (CI_LDI, y, "00");
					when "01" => r := (CI_PUSH, y, "00");
					when "10" => r := (CI_POP, y, "00");
					when others => r:= (CI_UNDEFINED, "00", "00");
				end case;
			when "0001" => r := (CI_LD, y, z);
			when "0010" => r := (CI_ST, y, z);
			when "0011" => r := (CI_MOV, y, z);
			when "0100" => 
				case z is
					when "00" => r := (CI_INC, y, "00");
					when "01" => r := (CI_DEC, y, "00");
					when "10" => r := (CI_INCC, y, "00");
					when "11" => r := (CI_DECB, y, "00");
					when others => r:= (CI_UNDEFINED, "00", "00");
				end case;
			when "0101" => r := (CI_ADD, y, z);
			when "0110" => r := (CI_SUB, y, z);
			when "0111" => r := (CI_CP, y, z);
			when "1000" =>
				case z is
					when "00" => r := (CI_NEG, y, "00");
					when "01" => r := (CI_NOT, y, "00");
					when others => r:= (CI_UNDEFINED, "00", "00");
				end case;
			when "1001" => r := (CI_AND, y, z);
			when "1010" => r := (CI_OR, y, z);
			when "1011" => r := (CI_XOR, y, z);
			when "1100" => r := (CI_TST, y, z);
			when "1101" =>
				case z is
					when "00" => r := (CI_LSL, y, "00");
					when "01" => r := (CI_LSR, y, "01");
					when "10" => r := (CI_ROL, y, "00");
					when "11" => r := (CI_ROR, y, "01");
					when others => r:= (CI_UNDEFINED, "00", "00");
				end case;
			when "1110" => r := (CI_IJMP, y, "00");
			when "1111" =>
				case z is
					when "00" => 
						case y is 
							when "00" => r := (CI_JMP, "00", "00");
							when "01" => r := (CI_BRCC, "00", "00");
							when others => r:= (CI_UNDEFINED, "00", "00");
						end case;
					when "01" => r := (CI_BRZ, "00", "00");
					when "10" => r := (CI_BRNZ, "00", "00");
					when "11" => r := (CI_BRCS, "00", "00");
					when others => r:= (CI_UNDEFINED, "00", "00");
				end case;
			when others => r:= (CI_UNDEFINED, "00", "00");
		end case;
		return r;
	end function;
	
	function byte_para_inteiro(b: ByteT) return integer is
	begin
		return to_integer(unsigned(b));
	end function;
	
	function inteiro_para_byte(int: integer) return ByteT is
	begin
		return ByteT(to_unsigned(int, TAMANHO_REG));
	end function;
	
	
	function ident_para_inteiro(i: IdentT) return integer is
	begin
		return to_integer(unsigned(i));
	end function;
end package body;