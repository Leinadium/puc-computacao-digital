LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.pacote_processador.ALL;
 
ENTITY teste_alu IS
END teste_alu;
 
ARCHITECTURE behavior OF teste_alu IS 
  
    COMPONENT unidade_logica_aritmetica
    PORT(
         A : IN  std_logic_vector(7 downto 0);
         B : IN  std_logic_vector(7 downto 0);
         OPERACAO : IN  Operacao;
         Z : OUT  std_logic_vector(7 downto 0);
         F_CARRY : OUT  std_logic;
         F_ZERO : OUT  std_logic
        );
    END COMPONENT;
   --Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');
   signal OPERACAO : Operacao;
 	--Outputs
   signal Z : std_logic_vector(7 downto 0);
   signal F_CARRY : std_logic;
   signal F_ZERO : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
	signal clock : std_logic;
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: unidade_logica_aritmetica PORT MAP (
          A => A,
          B => B,
          OPERACAO => OPERACAO,
          Z => Z,
          F_CARRY => F_CARRY,
          F_ZERO => F_ZERO
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait for 10 ns;	
      
		-- O_ADD
		A <= "00000001"; B <= "00000010"; OPERACAO <= O_ADD;
		wait for 10 ns;
		
		-- O_SUB
		A <= "00000100"; B <= "00000010"; OPERACAO <= O_SUB;
		wait for 10 ns;
		
		-- O_NOT
		A <= "10101010"; OPERACAO <= O_NOT;
		wait for 10 ns;
		
		-- O_AND
		A <= "00110011"; B <= "01010101"; OPERACAO <= O_AND;
		wait for 10 ns;
		
		-- O_OR
		A <= "00110011"; B <= "01010101"; OPERACAO <= O_OR;
		wait for 10 ns;
		
		-- O_XOR
		A <= "00110011"; B <= "01010101"; OPERACAO <= O_XOR;
		wait for 10 ns;
		
		-- O_SHR
		A <= "00110011"; B <= "00000000"; OPERACAO <= O_SHR;
		wait for 10 ns;

		-- com carry = 1
		B <= "00000001";
		wait for 10 ns;
		
		-- O_SHL
		A <= "00110011"; B <= "00000000"; OPERACAO <= O_SHL;
		wait for 10 ns;

		-- com carry = 1
		B <= "00000001";
		wait for 10 ns;
      
		wait;
   end process;

END;
