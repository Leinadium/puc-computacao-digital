LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY teste IS
END teste;
 
ARCHITECTURE behavior OF teste IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT terminal
    PORT(
         CLK_50MHZ : IN  std_logic;
         PS2_CLK : IN  std_logic;
         PS2_DATA : IN  std_logic;
         LCD_RS : OUT  std_logic;
         LCD_E : OUT  std_logic;
         LCD_RW : OUT  std_logic;
         SF_D : OUT  std_logic_vector(3 downto 0);
			TESTE_LED : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_50MHZ : std_logic := '0';
   signal PS2_CLK : std_logic := '0';
   signal PS2_DATA : std_logic := '0';

 	--Outputs
   signal LCD_RS : std_logic;
   signal LCD_E : std_logic;
   signal LCD_RW : std_logic;
   signal SF_D : std_logic_vector(3 downto 0);
	signal TESTE_LED : std_logic;

   -- Clock period definitions
   constant CLK_50MHZ_period : time := 20 ns;
   constant PS2_CLK_period : time := 10 ns;

	type DataT is array (0 to 11) of std_logic_vector(7 downto 0);
	constant DATA : DataT := (
		"00101010", "11110000", "00101010", -- "V" + 0xF0 + "V"
		"00110011", "11110000", "00110011", -- "H" + 0xF0 + "V"
		"00100011", "11110000", "00100011", -- "D" + 0xF0 + "V"
		"01001011", "11110000", "01001011"  -- "L" + 0xF0 + "V"
		);

	procedure ps2_bit (B : in std_logic ;
							signal CLK , DATA : out std_logic ) is
	begin
		DATA <= B ;
		wait for 15 us ;
		CLK <= '0' ;
		wait for 30 us ;
		CLK <= '1' ;
		wait for 15 us ;
	end procedure ;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: terminal PORT MAP (
          CLK_50MHZ => CLK_50MHZ,
          PS2_CLK => PS2_CLK,
          PS2_DATA => PS2_DATA,
          LCD_RS => LCD_RS,
          LCD_E => LCD_E,
          LCD_RW => LCD_RW,
          SF_D => SF_D,
			 TESTE_LED => TESTE_LED
        );

   -- Clock process definitions
   CLK_50MHZ_process :process
   begin
		CLK_50MHZ <= '0';
		wait for CLK_50MHZ_period/2;
		CLK_50MHZ <= '1';
		wait for CLK_50MHZ_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		-- esperando configuracoes
		wait for 40 ms;
		
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
