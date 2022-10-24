LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY teste IS
END teste;
 
ARCHITECTURE behavior OF teste IS 
    COMPONENT processador
    PORT(
         CLK : IN  std_logic;
         DATA : OUT  std_logic_vector(5 downto 0);
         RD : OUT  std_logic_vector(7 downto 0);
         RR : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';

 	--Outputs
   signal DATA : std_logic_vector(5 downto 0);
   signal RD : std_logic_vector(7 downto 0);
   signal RR : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processador PORT MAP (
          CLK => CLK,
          DATA => DATA,
          RD => RD,
          RR => RR
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
		wait for CLK_period*20;

      wait;
   end process;

END;
