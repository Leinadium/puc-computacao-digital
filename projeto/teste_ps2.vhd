LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
  
ENTITY teste_ps2 IS
END teste_ps2;
 
ARCHITECTURE behavior OF teste_ps2 IS 
  
	COMPONENT processador
	PORT(
		CLK_50MHZ : IN  std_logic;
		PS2_CLK : IN  std_logic;
		PS2_DATA : IN  std_logic;
		SAIDA_J1 : OUT  std_logic_vector(3 downto 0);
		SAIDA_J2 : OUT  std_logic_vector(3 downto 0);
		
		SF_D: out std_logic_vector(3 downto 0);
		LCD_E, LCD_RS, LCD_RW: out std_logic
		
	  );
	END COMPONENT;

   --Inputs
   signal CLK_50MHZ : std_logic := '0';
   signal PS2_CLK : std_logic := '0';
   signal PS2_DATA : std_logic := '0';

 	--Outputs
   signal SAIDA_J1 : std_logic_vector(3 downto 0);
   signal SAIDA_J2 : std_logic_vector(3 downto 0);
	signal SF_D: std_logic_vector(3 downto 0);
	signal LCD_E, LCD_RS, LCD_RW: std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
   constant PS2_CLK_period : time := 10 ns;
	
	type DataT is array (0 to 11) of std_logic_vector(7 downto 0);
	constant DATA : DataT := (
		x"45", "11110000", x"45", -- "0" + 0xF0 + "0"
		x"16", "11110000", x"16", -- "1" + 0xF0 + "1"
		x"1E", "11110000", x"1E", -- "2" + 0xF0 + "2"
		x"26", "11110000", x"26"  -- "3" + 0xF0 + "3"
	);

	procedure ps2_bit (B : in std_logic ;
							signal CLK , DATA : out std_logic ) is
	begin
		DATA <= B;
		wait for 15 us ;
		CLK <= '0';
		wait for 30 us ;
		CLK <= '1';
		wait for 15 us ;
	end procedure;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: processador PORT MAP (
          CLK_50MHZ => CLK_50MHZ,
          PS2_CLK => PS2_CLK,
          PS2_DATA => PS2_DATA,
          SAIDA_J1 => SAIDA_J1,
          SAIDA_J2 => SAIDA_J2,
			 SF_D => SF_D,
			 LCD_E => LCD_E,
			 LCD_RS => LCD_RS,
			 LCD_RW => LCD_RW
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK_50MHZ <= '0';
		wait for CLK_period/2;
		CLK_50MHZ <= '1';
		wait for CLK_period/2;
   end process;
	
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		-- esperando o lcd se configurar
		wait for 30 ms;
      
		wait for CLK_period*20;

      -- mandando os digitos
		for i in DATA'range loop
			ps2_bit('0',PS2_CLK, PS2_DATA); -- start
			
			for j in 0 to 7 loop
				ps2_bit(DATA(i)(j), PS2_CLK , PS2_DATA ) ;
			end loop ;
			ps2_bit('0', PS2_CLK, PS2_DATA ) ; -- parity ( discard )
			ps2_bit('1', PS2_CLK, PS2_DATA ) ; -- stop
			wait for 10 ms ;
			end loop ;

      wait;
   end process;

END;
