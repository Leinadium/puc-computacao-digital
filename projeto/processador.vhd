library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity processador is
	port(
		CLK: in std_logic;
		ENDERECO: out ByteT;
		Z: out ByteT
	);
end processador;

architecture structural of processador is
	component unidade_controle is
		port(
			CLOCK: in std_logic;
			MEMORIA_END: out ByteT;     -- endereco do dado
			MEMORIA_RW: out std_logic;  -- modo leitura ou escrita
			MEMORIA_E: out std_logic;   -- enable
			MEMORIA_IN: in ByteT;       -- dado lido da memoria
			REGISTRO_R0: out IdentT;    -- valor R0
			REGISTRO_R1: out IdentT;    -- valor R1
			REGISTRO_RZ: out IdentT;    -- valor Rz
			REGISTRO_E: out std_logic;  -- enable
			ALU_OP: out Operacao;       -- operacao
			ALU_IMM: out ByteT;         -- operador imm
			ALU_IN: in ByteT;           -- resposta da alu
			ALU_FCARRY: in std_logic;   -- flag de carry
			ALU_FZERO: in std_logic;    -- flag de zero
			SELECT_END: out std_logic;  -- seletor do endereco para memoria
			SELECT_VAL: out std_logic;  -- seletor do valor para o banco de registros
			SELECT_OPE: out std_logic   -- seletor do segundo operador para ALU
		);
	end component;
	
	component banco_registros is
		port(
			CLOCK: in std_logic;
			RD: in IdentT;
			RR: in IdentT;
			RZ: in IdentT;
			Z: in ByteT;
			ENABLE: in std_logic;
			A: out ByteT;
			B: out ByteT
		);
	end component;
	
	component unidade_logica_aritmetica is
		port (
			A, B: in ByteT;
			Z: out ByteT;
			OPERACAO: in Operacao;
			F_CARRY, F_ZERO: out std_logic
		);
	end component;
	
	component unidade_load_store is
		port(
			CLOCK: in std_logic; 
			ENDERECO: in ByteT;
			DADO_ENTRADA: in ByteT;
			READ_WRITE: in std_logic;
			ENABLE: in std_logic;
			DADO_SAIDA: out ByteT;
			PS2_DADO: in ByteT;
			PS2_VO: in std_logic;
			NUMERO_7SEG: out ByteT;
			LCD_DADO: out ByteT;
			LCD_TIPO: out std_logic;
			LCD_ENABLE: out std_logic
		);
	end component;
	
	component multiplexador is
		port(
			A, B: in ByteT;
			S: in std_logic;
			Z: out ByteT 
		);
	end component;
	
	signal memoria_controle_saida: ByteT;
	signal controle_memoria_rw: std_logic;
	signal controle_memoria_enable: std_logic;
	signal controle_multiplexador_endereco_select: std_logic;
	signal controle_multiplexador_endereco: ByteT;
	signal controle_alu_operacao: Operacao;
	signal controle_multiplexador_valor_select: std_logic;
	signal controle_registro_r0: IdentT;
	signal controle_registro_r1: IdentT;
	signal controle_registro_rz: IdentT;
	signal controle_registro_enable: std_logic;
	signal controle_multiplexador_operador_select: std_logic;
	signal controle_multiplexador_operador_imm: ByteT;
	signal alu_controle_fcarry: std_logic;
	signal alu_controle_fzero: std_logic;
	signal alu_controle_z: ByteT;
	signal multiplexador_valor_z: ByteT;
	signal alu_a: ByteT;
	signal alu_b: ByteT;
	signal multiplexador_operador_z: ByteT;
	signal multiplexador_endereco_z: ByteT;
	
	signal memoria_numero_7seg: ByteT := "00000000";
	signal memoria_lcd_dado: ByteT := "00000000";
	signal memoria_lcd_tipo: std_logic := '0';
	signal memoria_lcd_enable: std_logic := '0';
	
begin

	ENDERECO <= multiplexador_endereco_z;
	Z <= multiplexador_valor_z;

	inst_unidade_controle: unidade_controle port map (
		ClOCK => CLK,
		MEMORIA_IN => memoria_controle_saida,
		MEMORIA_RW => controle_memoria_rw,
		MEMORIA_E => controle_memoria_enable,
		SELECT_END => controle_multiplexador_endereco_select,
		MEMORIA_END => controle_multiplexador_endereco,
		ALU_OP => controle_alu_operacao,
		SELECT_VAL => controle_multiplexador_valor_select,
		REGISTRO_R0 => controle_registro_r0,
		REGISTRO_R1 => controle_registro_r1,
		REGISTRO_RZ => controle_registro_rz,
		REGISTRO_E => controle_registro_enable,
		SELECT_OPE => controle_multiplexador_operador_select,
		ALU_IMM => controle_multiplexador_operador_imm,
		ALU_FCARRY => alu_controle_fcarry,
		ALU_FZERO => alu_controle_fzero,
		ALU_IN => alu_controle_z
	);
	
	inst_banco_registros: banco_registros port map (
		CLOCK => CLK,
		Z => multiplexador_valor_z,
		RD => controle_registro_r0,
		RR => controle_registro_r1,
		RZ => controle_registro_rz,
		ENABLE => controle_registro_enable,
		A => alu_a,
		B => alu_b
	);
	
	inst_unidade_logica_aritmetica: unidade_logica_aritmetica port map (
		OPERACAO => controle_alu_operacao,
		A => alu_a,
		B => multiplexador_operador_z,
		Z => alu_controle_z,
		F_CARRY => alu_controle_fcarry,
		F_ZERO => alu_controle_fzero
	);
	
	inst_unidade_load_store: unidade_load_store port map (
		CLOCK => CLK,
		PS2_VO => '0',
		PS2_DADO => "00000000",
		READ_WRITE => controle_memoria_rw,
		ENABLE => controle_memoria_enable,
		ENDERECO => multiplexador_endereco_z,
		DADO_ENTRADA => alu_a,
		DADO_SAIDA => memoria_controle_saida,
		NUMERO_7SEG => memoria_numero_7seg,
		LCD_DADO => memoria_lcd_dado,
		LCD_TIPO => memoria_lcd_tipo,
		LCD_ENABLE => memoria_lcd_enable
	);
	
	inst_multiplexador_valor: multiplexador port map (
		A => alu_controle_z,
		B => memoria_controle_saida,
		S => controle_multiplexador_valor_select,
		Z => multiplexador_valor_z
	);
	
	inst_multiplexador_endereco: multiplexador port map (
		A => controle_multiplexador_endereco,
		B => alu_b,
		S => controle_multiplexador_endereco_select,
		Z => multiplexador_endereco_z
	);
	
	inst_multiplexador_operador: multiplexador port map (
		A => alu_b,
		B => controle_multiplexador_operador_imm,
		S => controle_multiplexador_operador_select,
		Z => multiplexador_operador_z
	);

end structural;

