library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
	port(
		CLK: in std_logic;
		DATA: in std_logic_vector(5 downto 0);
		
		ADDR: out std_logic_vector(3 downto 0);
		OP: out std_logic_vector(1 downto 0);
		EN: out std_logic;
		SEL: out std_logic_vector(3 downto 0)
	);
end control_unit;

architecture rtl of control_unit is
	type EstagioT is (Fetch, Execute);
	
	signal estagio: EstagioT := Fetch;
	signal pc: integer range 0 to 15 := 0;
	
	signal operacao: std_logic_vector(1 downto 0) := "00";
	signal registradores: std_logic_vector(3 downto 0) := "0000";
	
begin
	
	-- codigo concorrente, para ja decodificar a instrucao
	operacao <= DATA(5 downto 4);
	registradores <= DATA(3 downto 0);

	process (CLK, estagio, pc, operacao, registradores) is 
	begin
		if rising_edge(CLK) then
			ADDR <= (others => '0');
			OP   <= (others => '0');
			SEL  <= (others => '0');
			EN <= '0';
		
			case estagio is
				when Fetch =>
					-- apresenta o endereco a memoria
					ADDR <= std_logic_vector(to_unsigned(pc, 4));
					pc <= pc + 1;
					estagio <= Execute;
				
				when Execute =>
					-- faz o caminho de dados para a alu
					OP <= operacao;
					SEL <= registradores;
					
					-- salva no registro e atualiza pc
					if operacao = "11" then		-- jump
						pc <= to_integer(unsigned(registradores));
					else
						EN <= '1';
					end if;
					estagio <= Fetch;
			
			end case;
		end if;
	end process;

end rtl;

