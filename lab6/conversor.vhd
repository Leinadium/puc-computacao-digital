library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- implementacao de
-- (0b100000000)/(0bxxxx.xxxx) = (0b[z]zzzz.zzzz)
-- inversor de ponto fixo de 4 bits
entity conversor is
	port (
		CLK, VI: in std_logic;
		ENTRADA: in std_logic_vector(7 downto 0);
		SAIDA: out std_logic_vector(7 downto 0);
		VO: out std_logic
	);
end conversor;
architecture rtl of conversor is
	constant A: std_logic_vector(8 downto 0) := "100000000";
	-- constant M: integer := 9;
	-- constant N: integer := 8;
	
	signal CNT: integer range 0 to 9;
	signal X: unsigned(7 downto 0);
	signal Q: unsigned(8 downto 0);
	signal D: unsigned(16 downto 0);
	signal Q_BUF: std_logic_vector(8 downto 0);
begin
	process (CLK) is
		variable P: unsigned(8 downto 0);
	begin
		if rising_edge(CLK) then
			VO <= '0';
			P := D(16 downto 8);
			if CNT > 0 then
				if P >= X then
					P := P - X;
					D <= P(7 downto 0) & D(7 downto 0) & '0';
					Q <= Q(7 downto 0) & '1';
				else
					D <= D sll 1;
					Q <= Q(7 downto 0) & '0';
				end if;
				CNT <= CNT - 1;
				if CNT = 1 then
					VO <= '1';
				end if;
			elsif VI = '1' then
				CNT <= 9;
				X <= unsigned(ENTRADA);
				D <= (others => '0');
				D(8 downto 0) <= unsigned(A);
				Q <= (others => '0');
			end if;
		end if;
	end process;
	
	Q_BUF <= std_logic_vector(Q);
	SAIDA <= Q_BUF(7 downto 0);

end rtl;

