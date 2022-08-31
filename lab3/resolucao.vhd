library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY resolucao IS
	PORT (
		CLK												: IN STD_LOGIC;
		BTN_UP, BTN_DOWN, SENS_UP, SENS_DOWN   : IN  STD_LOGIC;
		LED_UP, LED_DOWN, MOTOR_UP, MOTOR_DOWN : OUT STD_LOGIC
	);
END resolucao;

ARCHITECTURE rtl OF resolucao IS
	TYPE Estado is (
		Parado, 
		SubindoParaParar, SubindoParaDescer,
		DescendoParaParar, DescendoParaSubir
	);
	SIGNAL estadoAtual, estadoProximo: Estado := Parado;

BEGIN
	-- registro
	PROCESS(CLK) is
	BEGIN
		IF rising_edge(CLK) THEN
			estadoAtual <= estadoProximo;
		END IF;
	END PROCESS;
	
	-- funcao de transicao
	PROCESS (estadoAtual, BTN_UP, BTN_DOWN, SENS_UP, SENS_DOWN) IS
	BEGIN
		estadoProximo <= estadoAtual;
		CASE estadoAtual IS
			WHEN Parado =>
				-- PARADO -> SUBINDOPARAPARAR
				IF BTN_UP = '1' AND SENS_DOWN = '1' THEN
					estadoProximo <= SubindoParaParar;
				-- PARADO -> DESCENDOPARAPARAR
				ELSIF BTN_DOWN = '1' AND SENS_UP = '1' THEN
					estadoProximo <= DescendoParaParar;
				END IF;
			
			WHEN SubindoParaParar =>
				-- SUBINDOPARAPARAR -> PARADO
				IF SENS_UP = '1' THEN
					estadoProximo <= Parado;
				-- SUBINDOPARAPARAR -> SUBINDOPARADESCER
				ELSIF BTN_DOWN = '1' AND SENS_UP = '0' THEN
					estadoPRoximo <= SubindoParaDescer;
				END IF;
			
			WHEN SubindoParaDescer =>
				-- SUBINDOPARADESCER -> DESCENDOPARAPARAR
				IF SENS_UP = '1' THEN
					estadoProximo <= DescendoParaParar;
				END IF;
			
			WHEN DescendoParaParar =>
				-- DESCENDOPARAPARAR -> PARADO
				IF SENS_DOWN = '1' THEN
					estadoProximo <= Parado;
				-- DESCENDOPARAPARAR -> DESCENDOPARASUBIR
				ELSIF BTN_UP = '1' AND SENS_DOWN = '0' THEN
					estadoPRoximo <= DescendoParaSubir;
				END IF;
			
			WHEN DescendoParaSubir =>
				-- DESCENDOPARASUBIR -> SUBINDOPARADESCER
				IF SENS_DOWN = '1' THEN
					estadoProximo <= SubindoParaParar;
				END IF;
		END CASE;
	END PROCESS;
	
	-- funcao de saida
	LED_UP     <= '0' WHEN estadoAtual = Parado OR estadoAtual = DescendoParaParar ELSE '1';
	LED_DOWN   <= '0' WHEN estadoAtual = Parado OR estadoAtual = SubindoParaParar ELSE '1';
	MOTOR_UP   <= '1' WHEN estadoAtual = SubindoParaParar OR estadoAtual = SubindoParaDescer ELSE '0';
	MOTOR_DOWN <= '1' WHEN estadoAtual = DescendoParaParar OR estadoAtual = DescendoParaSubir ELSE '0';
			
END ARCHITECTURE;

