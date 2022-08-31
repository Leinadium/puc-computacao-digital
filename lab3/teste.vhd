
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY teste IS
END teste;
 
ARCHITECTURE behavior OF teste IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT resolucao
    PORT(
         CLK : IN  std_logic;
         BTN_UP : IN  std_logic;
         BTN_DOWN : IN  std_logic;
         SENS_UP : IN  std_logic;
         SENS_DOWN : IN  std_logic;
         LED_UP : OUT  std_logic;
         LED_DOWN : OUT  std_logic;
         MOTOR_UP : OUT  std_logic;
         MOTOR_DOWN : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal BTN_UP : std_logic := '0';
   signal BTN_DOWN : std_logic := '0';
   signal SENS_UP : std_logic := '0';
   signal SENS_DOWN : std_logic := '0';

 	--Outputs
   signal LED_UP : std_logic;
   signal LED_DOWN : std_logic;
   signal MOTOR_UP : std_logic;
   signal MOTOR_DOWN : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: resolucao PORT MAP (
          CLK => CLK,
          BTN_UP => BTN_UP,
          BTN_DOWN => BTN_DOWN,
          SENS_UP => SENS_UP,
          SENS_DOWN => SENS_DOWN,
          LED_UP => LED_UP,
          LED_DOWN => LED_DOWN,
          MOTOR_UP => MOTOR_UP,
          MOTOR_DOWN => MOTOR_DOWN
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
		SENS_DOWN <= '1';	-- definindo estado inicial (est� embaixo)
		WAIT FOR 100 ns;
		
		BTN_UP <= '1'; -- apertou o botao
		WAIT FOR 100 ns;
		BTN_UP <= '0';	-- o botao foi solto
		SENS_DOWN <= '0';	-- o elevador saiu
		
		WAIT FOR 500 ns;
		SENS_UP <= '1';		-- o elevador chegou
		
		WAIT FOR 500 ns;
		BTN_DOWN <= '1';   -- alguem pediu pra descer
		WAIT FOR 100 ns;
		BTN_DOWN <= '0';
		SENS_UP <= '0';
		
		WAIT FOR 200 ns;
		BTN_UP <= '1';		-- enquanto desce, alguem pediu pra subir
		WAIT FOR 100 ns;
		BTN_UP <= '0';
		
		WAIT FOR 200 ns;
		SENS_DOWN <= '1';	-- o elevador chegou
		
		WAIT FOR 100 ns;
		SENS_DOWN <= '0';	-- o elevador saiu do terreo.
		
		WAIT FOR 500 ns;
		SENS_UP <= '1';		-- o elevador chegou no andar

      wait;
   end process;

END;
