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
		MEMORIA_E: out std_logic;   -- enable
		MEMORIA_IN: in ByteT;       -- dado lido da memoria
		-- banco de registros
		REGISTRO_R0: out IdentT;    -- valor R0
		REGISTRO_R1: out IdentT;    -- valor R1
		REGISTRO_RZ: out IdentT;    -- valor Rz
		REGISTRO_E: out std_logic;  -- enable
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
	signal pc_atual, pc_prox: integer range 0 to MAX_REG := 0;
	signal cir_atual, cir_prox: ByteT := (others => '0');
	-- flags
	signal flag_carry: std_logic := '0';
	signal flag_zero: std_logic := '0';
	-- maquina de estado
	type Estado is (Fetch1, Fetch2, Decode, Execute);
	signal estado_atual, estado_prox: Estado := Fetch1;
	-- multiplexadores
	signal seletor_endereco: std_logic := MULTI_A;
	signal seletor_valor: std_logic := MULTI_A;
	signal seletor_operador: std_logic := MULTI_A;
	-- identificadores dos registradores
	signal ident_rd: IdentT := "00";
	signal ident_rr: IdentT := "00";
	signal ident_rz: IdentT := "00";
	
begin
	-- configurando os multiplexadores
	SELECT_END <= seletor_endereco;
	SELECT_VAL <= seletor_valor;
	SELECT_OPE <= seletor_operador;

	-- ciclo dos estados
	process (CLOCK) is
	begin
		if rising_edge(CLOCK) then
			estado_atual <= estado_prox;
			pc_atual <= pc_prox;
			cir_atual <= cir_prox;
		end if;
	end process;

	-- ciclo da maquina de estados
	process (CLOCK, estado_atual) is
		variable instrucao: InstrucaoT;
		variable operacao: Operacao;
	begin
		if rising_edge(CLOCK) then
			-- valores padrao
			-- instrucao e operacao
			instrucao := (CI_UNDEFINED, "00", "00");
			operacao := O_XXX;
			-- enables (valores default = 0)
			MEMORIA_E <= '0';
			REGISTRO_E <= '0';
			-- inicio do case
			case estado_atual is
				when Fetch1 => 
					-- fetch 1: enviar pc para a memoria, pedindo a proxima instrucao
					MEMORIA_END <= ByteT(pc_atual);   -- endereco
					MEMORIA_RW <= MODO_READ;          -- modo leitura
					MEMORIA_E <= '1';                 -- enable
					estado_prox <= Fetch2;            -- proximo estado
				
				when Fetch2 =>
					-- fetch2: recebe a memoria e incrementa o program counter
					cir_prox <= MEMORIA_IN;   -- entrada memoria
					pc_prox <= pc_atual + 1;
					
				when Decode =>
					-- decode: decodifica a instrucao e prepara o caminho de dados
					-- ou seja, prepara os registradores e configura a operacao
					instrucao := decodifica_instrucao(cir_atual);
					carry_enviado <= '0';
					case instrucao.codigo is
						when CI_LDI =>
							-- Rd = MEM[pc + 1],  pc += 2
							MEMORIA_END <= ByteT(pc_atual);
							MEMORIA_RW <= MODO_READ;
							seletor_endereco <= MULTI_A;     -- utilza o valor fornecido
							ident_rz <= instrucao.primeiro;
							pc_prox <= pc_atual + 1;
							
						when CI_LD =>
							-- Rd = MEM[Rr]
							-- carrega o endereco com o valor do registrador
							ident_rd <= instrucao.primeiro;  -- registro a ser editado
							ident_rr <= instrucao.segundo;	-- endereco para memoria
							ident_rz <= instrucao.primeiro;
							MEMORIA_RW <= MODO_READ;
							seletor_endereco <= MULTI_B;     -- utilza o valor do registrador
						
						when CI_ST =>
							-- MEM[Rr] = Rd
							ident_rd <= instrucao.primeiro;  -- dado a ser escrito esta em Rd
							ident_rr <= instrucao.segundo;   -- endereco a ser usado vem de rr
							MEMORIA_RW <= MODO_WRITE;
							seletor_endereco <= MULTI_B;     -- utiliza o endereco do registrador
							seletor_valor <= MULTI_B;        -- utiliza o valor que vira da memoria
						
						when CI_PUSH =>
							-- TODO
						
						when CI_POP =>
							-- TODO
						
						when CI_MOV =>
							-- Rd = Rr (Rd = Rd + 0)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							ALU_IMM <= "00000000";        -- roubando e usando imm
							ALU_OP <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_INC =>
							-- Rd = Rd + 1 (Rd = Rd + 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							ALU_IMM <= "00000001";        -- roubando e usando imm
							ALU_OP <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_DEC =>
							-- Rd = Rd - 1 (Rd = Rd - 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							ALU_IMM <= "00000001";        -- roubando e usando imm
							ALU_OP <= O_SUB;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_INCC =>
							-- Rd = Rd + c (Rd = Rd + c)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							if flag_carry = '1' then
								ALU_IMM <= "00000001";        -- roubando e usando imm
							else
								ALU_IMM <= "00000000";
								ALU_OP <= O_ADD;
							end if;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_DECB =>
							-- Rd = Rd - c + 1 (Rd = Rd - c + 1)
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro;
							if flag_carry = '1' then
								ALU_IMM <= "00000000";        -- roubando e usando imm
							else
								ALU_IMM <= "00000001";
								ALU_OP <= O_SUB;
							end if;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_B;	-- roubando e usando o meu valor
						
						when CI_ADD =>
							-- Rd = Rd + Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							ALU_OP <= O_ADD;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
						
						when CI_SUB =>
							-- Rd = Rd - Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							ident_rz <= instrucao.primeiro;
							ALU_OP <= O_SUB;
							seletor_valor <= MULTI_A;     -- salvar o resultado da operacao
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
					
						when CI_CP =>
							-- Rd - Rr
							ident_rd <= instrucao.primeiro;
							ident_rr <= instrucao.segundo;
							-- ident_rz <= instrucao.primeiro; -- nao vai salvar
							ALU_OP <= O_SUB;
							-- seletor_valor <= MULTI_A;     -- nao vai salvar
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
						
						when CI_NEG =>
							-- Rd = -Rd
							ident_rd <= instrucao.primeiro;
							ident_rz <= instrucao.primeiro; 
							ALU_OP <= O_SUB;
							seletor_valor <= MULTI_A;
							seletor_operador <= MULTI_A;	-- usando o valor de Rr
					
					end case;
			end case;
		end if;
	end process;

end rtl;

