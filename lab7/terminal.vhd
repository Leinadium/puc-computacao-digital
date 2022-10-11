library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity terminal is
	port(
		CLK_50MHZ, PS2_CLK, PS2_DATA: in std_logic;
		LCD_RS, LCD_E, LCD_RW: out std_logic;
		SF_D: out std_logic_vector(3 downto 0);
		TESTE_LED: out std_logic
	);
end terminal;

architecture structural of terminal is
	component sincronizador is
		port(
			CLK, A:  in std_logic;
			B:			out std_logic
		);
	end component;

	component receptor_ps2 is
		port(
			CLK_50MHZ: in std_logic;
			PS2_CLK: in std_logic;
			PS2_DATA: in std_logic;
			CODE: out std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	component filtro_ps2 is
		port(
			CLK_50MHZ: in std_logic;
			VI: in std_logic;
			DIN: in std_logic_vector(7 downto 0);
			VO: out std_logic
		);
	end component;
	
	component scan_to_char is
		port (
			SCAN: in std_logic_vector (7 downto 0);
			CHAR: out std_logic_vector (7 downto 0)
		);
	end component;
	
	component escrever_asmd is
		port(
			CLK_50MHZ: in std_logic;
			VI: in std_logic;
			BYTE_IN: in std_logic_vector (7 downto 0);
			
			SF_D: out std_logic_vector(3 downto 0); -- nibble saida			
			LCD_E: out std_logic; -- enable do lcd
			LCD_RS: out std_logic; -- troca entre comando e digito
			LCD_RW: out std_logic	-- rw (vai ser sempre 0)
		);
	end component;
	
	signal clk_sync: std_logic := '0';
	signal code_conn: std_logic_vector(7 downto 0) := (others => '0');
	signal lcd_data: std_logic_vector (7 downto 0) := (others => '0');
	signal v_receptor: std_logic := '0';
	signal v_lcd: std_logic := '0';

begin
	-- parece correto
	inst_sincronizador: sincronizador port map (
		CLK => CLK_50MHZ,
		A => PS2_CLK,
		B => clk_sync
	);
	
	-- parece correto
	inst_receptor_ps2: receptor_ps2 port map (
		CLK_50MHZ => CLK_50MHZ,
		PS2_CLK => clk_sync,
		PS2_DATA => PS2_DATA,
		CODE => code_conn,
		VO => v_receptor
	);
	
	-- parece correto
	inst_scan_to_char: scan_to_char port map (
		SCAN => code_conn,
		CHAR => lcd_data
	);
	
	inst_filtro_ps2: filtro_ps2 port map (
		CLK_50MHZ => CLK_50MHZ,
		VI => v_receptor,
		DIN => code_conn,
		-- DIN => (others => '0'),
		VO => v_lcd
	);
	
	inst_escrever_asmd: escrever_asmd port map (
		CLK_50MHZ => CLK_50MHZ,
		VI => v_lcd,
		BYTE_IN => lcd_data,
		SF_D => SF_D,			
		LCD_E => LCD_E,
		LCD_RS => LCD_RS,
		LCD_RW => LCD_RW
	);
	
	TESTE_LED <= PS2_DATA;

end structural;

