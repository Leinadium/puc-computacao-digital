LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.pacote_processador.ALL;
 
ENTITY teste_processador IS
END teste_processador;
 
ARCHITECTURE behavior OF teste_processador IS 
 
    COMPONENT processador
    PORT(
         CLK : IN  std_logic;
         ENDERECO : OUT  std_logic_vector(7 downto 0);
         Z : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    
   --Inputs
   signal CLK : std_logic := '0';

 	--Outputs
   signal ENDERECO : std_logic_vector(7 downto 0);
   signal Z : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processador PORT MAP (
          CLK => CLK,
          ENDERECO => ENDERECO,
          Z => Z
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 
		wait for CLK_period*100;
		
      wait;
   end process;

END;
