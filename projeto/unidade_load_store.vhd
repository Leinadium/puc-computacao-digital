library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pacote_processador.ALL;

entity unidade_load_store is
	port (
		CLOCK: in std_logic; 
		ENDERECO: in ByteT;
		DADO_ENTRADA: in ByteT;
		ENABLE: in std_logic;
		
		DADO_SAIDA: out ByteT
	);
end entity;

architecture rtl of unidade_load_store is
	type ramT is array(0 to 255) of ByteT;
	
	-- inserir abaixo a declaracao da memoria:
	signal ram: ramT := (others => (others => '0'));
	-- fim da insercao

begin
	process (CLOCK, ENABLE) is
	begin
		DADO_SAIDA <= (others => '0'); -- valor default
		
		if rising_edge(CLOCK) then
			if ENABLE = '1' then    -- modo escrita
				-- TODO: verificar I/O
				ram(byte_para_inteiro(ENDERECO)) <= DADO_ENTRADA;
			else                    -- modo leitura
				DADO_SAIDA <= ram(byte_para_inteiro(ENDERECO));
			end if;
		end if;
	end process;
end architecture;
