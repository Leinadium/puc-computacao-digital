library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pacote_processador.ALL;

entity unidade_controle is
	port(
		CLOCK: in std_logic;
		-- unidade load/store
		MEMORIA_END: out ByteT;     -- endereco do dado
		MEMORIA_RW: out std_logic;  -- modo leitura ou escrita
		MEMORIA_E: out std_logic := '0';   -- enable
		MEMORIA_IN: in ByteT;       -- dado lido da memoria
		-- banco de registros
		REGISTRO_R0: out IdentT;    -- valor R0
		REGISTRO_R1: out IdentT;    -- valor R1
		REGISTRO_RZ: out IdentT;    -- valor Rz
		REGISTRO_E: out std_logic := '0';  -- enable
		-- alu
		ALU_OP: out Operacao;       -- operacao
		ALU_IMM: out ByteT;         -- operador imm
		ALU_IN: in ByteT;           -- resposta da alu
		ALU_FCARRY: in std_logic;   -- flag de carry
		ALU_FZERO: in std_logic;    -- flag de zero
		-- multiplexadores
		SELECT_END: out std_logic;  -- seletor do endereco para memoria
		SELECT_VAL: out std_logic;  -- seletor do valor para o banco de registros
		SELECT_OPE: out std_logic   -- seletor do segundo operador para ALU
	);
end unidade_controle;

architecture rtl of unidade_controle is
	-- sinais principais
	signal pc: unsigned(7 downto 0) := "00000000";
	signal sp: unsigned(7 downto 0) := "11111111";
	signal cir: ByteT := (others => '0');
	-- flags
	signal flag_carry: std_logic := '0';
	signal flag_zero: std_logic := '0';
	-- maquina de estado
	type EnumEstado is (Fetch1, Fetch2, Decode, Execute);
	signal estado: EnumEstado := Execute;
	
	-- multiplexadores
	signal seletor_endereco: std_logic := MULTI_A;
	signal seletor_valor: std_logic := MULTI_A;
	signal seletor_operador: std_logic := MULTI_A;
	-- identificadores dos registradores
	signal ident_rd: IdentT := "00";
	signal ident_rr: IdentT := "00";
	signal ident_rz: IdentT := "00";
	-- valores para alu
	signal operacao: Operacao := O_XXX;
	signal imm: ByteT := "00000000";
	
	signal flag_memoria: std_logic := '0';
	
begin
	-- configurando os multiplexadores
	SELECT_END <= seletor_endereco;
	SELECT_VAL <= seletor_valor;
	SELECT_OPE <= seletor_operador;
	REGISTRO_R0 <= ident_rd;
	REGISTRO_R1 <= ident_rr;
	REGISTRO_RZ <= ident_rz;
	ALU_OP <= operacao;
	ALU_IMM <= imm;

	-- ciclo da maquina de estados
	process (CLOCK) is
		variable instrucao: InstrucaoT := (CI_UNDEFINED, "00", "00");
	begin
		if rising_edge(CLOCK) then
			-- valores padrao
			
			-- operacao := O_XXX;
			-- enables (valores default = 0)
			
			-- inicio do case
			case estado is
				when Fetch1 =>
					MEMORIA_E <= '0';
					REGISTRO_E <= '0';
					if flag_memoria = '1' then
						pc <= unsigned(MEMORIA_IN);
						MEMORIA_END <= std_logic_vector(MEMORIA_IN);   -- endereco
						flag_memoria <= '0';
					else
						MEMORIA_END <= std_logic_vector(pc);   -- endereco
					end if;
				
					-- fetch 1: enviar pc para a memoria, pedindo a proxima instrucao
					-- MEMORIA_END <= std_logic_vector(pc);   -- endereco
					seletor_endereco <= MULTI_A;      -- usa o endereco acima
					MEMORIA_RW <= MODO_READ;          -- modo leitura
					MEMORIA_E <= '1';
					estado <= Fetch2;            -- proximo estado
				
				when Fetch2 =>
					-- fetch2: recebe a memoria e incrementa o program counter
					pc <= pc + 1;
					estado <= Decode;            -- proximo estado
					
				when Decode =>
					-- cir <= MEMORIA_IN;   -- entrada memoria
					-- decode: decodifica a instrucao e prepara o caminho de dados
					-- ou seja, prepara os registradores e configura a operacao
					instrucao := decodifica_instrucao(MEMORIA_IN);
					case instrucao.codigo is
						--------------------------------------
						-- ### MEMORIA ### --
						when CI_LDI =>  -- Rd = MEM[pc + 1],  pc += 2
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_E <= '1';
							MEMORIA_RW <= MODO_READ;
							seletor_endereco <= MULTI_A;     -- utiliza o valor fornecido
							seletor_valor <= MULTI_B;
							ident_rz <= instrucao.primeiro;
							pc <= pc + 1;
							
						when CI_LD =>  -- Rd = MEM[Rr]
							-- carrega o endereco com o valor do registrador
							ident_rd <= instrucao.primeiro;  -- registro a ser editado
							ident_rr <= instrucao.segundo;	-- endereco para memoria
							ident_rz <= instrucao.primeiro;
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_B;     -- utiliza o valor do registrador
							seletor_valor <= MULTI_B;
							
						when CI_ST =>  -- MEM[Rr] = Rd
							ident_rd <= instrucao.primeiro;  -- dado a ser escrito esta em Rd
							ident_rr <= instrucao.segundo;   -- endereco a ser usado vem de rr
							MEMORIA_RW <= MODO_WRITE;
							seletor_endereco <= MULTI_B;     -- utiliza o endereco do registrador
							
						when CI_PUSH =>  -- MEM[sp] <-- Rd, sp <-- sp - 1 
							MEMORIA_END <= std_logic_vector(sp);
							ident_rd <= instrucao.primeiro;  -- o que vai salvar na mem
							MEMORIA_RW <= MODO_WRITE;
							seletor_endereco <= MULTI_A;  -- usa o sp como end
							sp <= sp - 1;
							operacao <= O_XXX;
							
							
						when CI_POP =>  --  Rd <-- MEM[sp + 1], sp <-- sp + 1
							ident_rz <= instrucao.primeiro;  -- vai salvar no rd
							MEMORIA_END <= std_logic_vector(sp + 1);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A; -- usa o sp+1
							seletor_valor <= MULTI_B;  -- salva o valor da mem
							sp <= sp + 1;
							operacao <= O_XXX;
						---------------------------------------
						-- ### SALTOS ### --
						when CI_IJMP => -- pc = Rd
							-- pegando o valor de rd
							ident_rd <= instrucao.primeiro;
							imm <= "00000000";
							operacao <= O_ADD;
							seletor_operador <= MULTI_B;  -- usando imm
							
						when CI_JMP =>  -- pc = MEM[pc+1]
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A;     -- utilza o valor fornecido
							
						when CI_BRZ => 
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A;     -- utiliza o valor fornecido
						
						when CI_BRNZ => 
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A;     -- utiliza o valor fornecido
						
						when CI_BRCS => 
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A;     -- utiliza o valor fornecido
						
						when CI_BRCC => 
							MEMORIA_END <= std_logic_vector(pc);
							MEMORIA_RW <= MODO_READ;
							MEMORIA_E <= '1';
							seletor_endereco <= MULTI_A;     -- utiliza o valor fornecido
						--------------------------------------
						-- ### OPERACOES ## --
						when CI_MOV =>
							-- Rd = Rr (Rd = Rr + 0)
							ident_rd <= instrucao.segundo;
							imm <= "00000000";              -- roubando e usando imm
							ident_rz <= instrucao.primeiro; -- salva no rd
							operacao <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_INC =>
							-- Rd = Rd + 1 (Rd = Rd + 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							imm <= "00000001";        -- roubando e usando imm
							operacao <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_DEC =>
							-- Rd = Rd - 1 (Rd = Rd - 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							imm <= "00000001";        -- roubando e usando imm
							operacao <= O_SUB;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_INCC =>
							-- Rd = Rd + c (Rd = Rd + c)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							if flag_carry = '1' then
								imm <= "00000001";        -- roubando e usando imm
							else
								imm <= "00000000";
							end if;
							operacao <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_DECB =>
							-- Rd = Rd - c + 1 (Rd = Rd - c + 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							if flag_carry = '1' then
								imm <= "00000000";        -- roubando e usando imm
							else
								imm <= "00000001";
							end if;
							operacao <= O_SUB;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_ADD =>
							-- Rd = Rd + Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							operacao <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
						
						when CI_SUB =>
							-- Rd = Rd - Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							operacao <= O_SUB;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
					
						when CI_CP =>
							-- Rd - Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							-- ident_rz <= instrucao.primeiro; -- nao vai salvar
							operacao <= O_SUB;
							-- seletor_valor <= MULTI_A;     -- nao vai salvar
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
						
						when CI_NEG =>
							-- Rd = -Rd
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro; 
							operacao <= O_SUB;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
						
						when CI_NOT =>
							-- Rd = ~Rd
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							operacao <= O_NOT;
							seletor_valor <= MULTI_A;
						
						when CI_AND =>
							-- Rd = Rd & Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							operacao <= O_AND;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_A;
						
						when CI_OR =>
							-- Rd = Rd | Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							operacao <= O_AND;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_A;
						
						when CI_XOR =>
							-- Rd = Rd ^ Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							operacao <= O_XOR;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_A;
						
						when CI_TST =>
							-- Rd & Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							operacao <= O_AND;
							seletor_operador <= MULTI_A;
					
						when CI_LSL =>
							-- Rd = LSL(Rd)
							ident_rd <= instrucao.primeiro;
							imm <= "00000000";
							ident_rz <= instrucao.primeiro;
							operacao <= O_SHL;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_B;	-- usando imm
						
						when CI_LSR =>
							-- Rd = LSR(Rd)
							ident_rd <= instrucao.primeiro;
							imm <= "00000000";
							ident_rz <= instrucao.primeiro;
							operacao <= O_SHR;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_B;	-- usando imm
						
						when CI_ROL =>
							-- Rd = ROL(Rd)
							ident_rd <= instrucao.primeiro;
							if flag_carry = '1' then
								imm <= "00000000";        
							else
								imm <= "00000001";
							end if;
							ident_rz <= instrucao.primeiro;
							operacao <= O_SHL;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_B;	-- usando imm
						
						when CI_ROR =>
							-- Rd = ROL(Rd)
							ident_rd <= instrucao.primeiro;
							if flag_carry = '1' then
								imm <= "00000000";        
							else
								imm <= "00000001";
							end if;
							ident_rz <= instrucao.primeiro;
							operacao <= O_SHR;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_B;	-- usando imm
						
						when others =>
							operacao <= O_XXX;
					end case;
					estado <= Execute; -- proximo estado
					
				when Execute =>
					-- instrucao := decodifica_instrucao(cir);
					case instrucao.codigo is
						-- MEMORIA
						when CI_LDI => REGISTRO_E <= '1';
						when CI_LD => REGISTRO_E <= '1';
						when CI_ST => MEMORIA_E <= '1';
						when CI_PUSH => MEMORIA_E <= '1';
						when CI_POP => REGISTRO_E <= '1';
						
						-- SALTOS
						when CI_IJMP => pc <= unsigned(ALU_IN);
						when CI_JMP => flag_memoria <= '1';-- pc <= unsigned(MEMORIA_IN);
						when CI_BRZ =>
							if flag_zero = '1' then
								flag_memoria <= '1';
								-- pc <= unsigned(MEMORIA_IN);
							else
								pc <= pc + 1;
							end if;
						when CI_BRNZ =>
							if flag_zero = '0' then
								flag_memoria <= '1';
								-- pc <= unsigned(MEMORIA_IN);
							else
								pc <= pc + 1;
							end if;
						when CI_BRCS =>
							if flag_carry = '1' then
								flag_memoria <= '1';
								-- pc <= unsigned(MEMORIA_IN);
							else
								pc <= pc + 1;
							end if;
						when CI_BRCC =>
							if flag_carry = '0' then
								flag_memoria <= '1';
								-- pc <= unsigned(MEMORIA_IN);
							else
								pc <= pc + 1;
							end if;
						
						-- OPERACOES
						when CI_MOV => REGISTRO_E <= '1';
						when CI_INC => REGISTRO_E <= '1';
						when CI_DEC => REGISTRO_E <= '1';
						when CI_INCC => REGISTRO_E <= '1';
						when CI_DECB => REGISTRO_E <= '1';
						when CI_ADD => REGISTRO_E <= '1';
						when CI_SUB => REGISTRO_E <= '1';
						-- when CI_CP => -- nao salva no registro
						when CI_NEG => REGISTRO_E <= '1';
						when CI_NOT => REGISTRO_E <= '1';
						when CI_AND => REGISTRO_E <= '1';
						when CI_OR => REGISTRO_E <= '1';
						when CI_XOR => REGISTRO_E <= '1';
						-- when CI_TST => -- nao salva no registro
						when CI_LSL => REGISTRO_E <= '1';
						when CI_LSR => REGISTRO_E <= '1';
						when CI_ROL => REGISTRO_E <= '1';
						when CI_ROR => REGISTRO_E <= '1';
						when others => -- instrucao invalida
					end case;
					-- armazena as flags das operacoes
					flag_carry <= ALU_FCARRY;
					flag_zero <= ALU_FZERO;
					estado <= Fetch1; -- proximo estado
			end case;
		end if;
	end process;
end rtl;

