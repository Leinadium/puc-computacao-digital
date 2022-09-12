# Revisão da G1

## 1. VHDL

### Exercício 1.1

**Descreva os dois papéis de VHDL. Como essa dupla utilização influenciou o desenho e uso da linguagem?**

Síntese e simulação. Tem coisas na linguagem que só fazem sentido para a simulação, outras que só fazem sentido para a síntese.

### Exercício 1.2

**Descreva a diferença entre `bit_vector` e `std_logic_vector`. Por que existe essa diferença?**

O bit_vector só tem 0 ou 1. O std_logic_vector pode possuir `X` e outros sinais. Ajuda na hora de debugar seu circuito na hora da simulação. Também na sintese.


## 2. Código concorrente

### Exercício 2.1

**Pode atribuir um sinal condicionalmente usando `when` ou `select`. Descreva quando é mais indicado o uso de `select`.**

O select é para valores mais específicos e deixa mais legível, tipo um `case`. O when permite condições, mas mais palavroso.

### Exercício 2.2

```vhdl
entity reversos ir
    port(
        A: in  std_logic_vector(3 downto 0);
        B: out std_logic_vector(3 downto 0)
    );
```

**Dado um entidade que inverte a ordem de bits de uma palavra de 4 bits,**

**1. Dá as entradas e saídas esperadas de um testbench para distinguir a entidade de outras entidades parecidas, como um inversor dos bits, e as funções de deslocamento.**

```text
| entr | said | inv  |  sl  |  sr  |  rl  |  rr  |
| 1000 | 0001 | 0111 | 0000 | 0100 | 0001 | 0100 |
| 1011 | 1101 | 0100 | 0110 | 0101 | 0111 | 1101 |
```

**2. Como pode ter certeza que a entidade realmente implementa a inversão de ordem, e nenhuma outra função?**

Só é possível testar com todas as entradas possíveis.


## 3. Código sequencial

### Exercício 3.1

**Cada atribuição em código concorrente tem um processo equivalente. Dá o processo equivalente da seguinte atribuição:**

```vhdl
A <= B when S = '0' else C;
```

```vhdl
if S = '0' then
    A <= B;
else
    A <= C;
end if;
```

### Exercício 3.2

**Descreva a relação entre código sequencial e circuitos sequenciais:**

Códigos sequenciais especificam circuitos sequenciais

### Exercício 3.3

**O seguinte código armazena a entrada `DIN` num registro `DOUT` na borda do `CLK`:**

```vhdl
process(CLK)
begin
    DOUT <= DIN;
end process;
```

**1. O código funciona bem em simulação, mas não no FPGA. Por quê?**

O process(CLK) só é usado na simulação, mas não é sintetizado no FPGA.

**2. Como pode resolver?**

```vhdl
if CLK'event then   -- rising_edge é só em uma das bordas 
    DOUT <= DIN; 
end process;
```

### Exercício 3.4

```vhdl
entity counter is
    port (
        CLK : in std_logic ;
        UP, DOWN : in std_logic ;
        CNT : out integer range 0 to 255
    );
end entity ;
architecture rtl of counter is
begin
    process ( CLK ) is
        variable V : integer := 0;
    begin
        if rising_edge ( CLK ) then
            if UP = '1' and V < 255 then
                V := V + 1;
            end if ;
            if DOWN = '1' and V > 0 then
                V := V - 1;
            end if ;
            CNT <= V ;
        end if ;
    end process ;
end architecture ;
```

**O seguinte código usa uma variável. Reescreve para implementar um contador:**

```vhdl
entity counter is
    port (
        CLK      : in  std_logic;
        UP, DOWN : in  std_logic;
        CNT      : out integer range 0 to 255
    );
end entity;
architecture rtl of counter is
    signal S: integer := 0;
begin
    process ( CLK ) is
    begin
        if rising_edge ( CLK ) then
            -- if UP = '1' and V < 255 then
            if UP = '1' and DOWN = '0' and V < 255 then
                S <= S + 1;
            end if ;
            -- if DOWN = '1' and V > 0 then
            if DOWN = '1' and UP = '0' and V > 0 then
                S <= S - 1;
            end if ;
        end if;
    end process;
    -- colocando fora do process
    -- pois dentro do process o tempo não passa
    CNT <= S ;
end architecture;
```

## 4. Código estruturado

### Exercício 4.1

**Descreva os conceitos de código estruturado, arquitetura estrutural, estruturas de dados:**

Código estruturado é um conceito geral de programação, é usar qualquer forma de estruturação de código que usa função, loops, que possuem alguma estrutura

Arquitetura estrutural é ...

Estruturas de dados são por exemplo os tipos.

### Exercício 4.2

**VHDL suporta laços, mas são diferentes que linguagens comuns:**

**1. Descreva a diferença entre os laços `for ... generate` e `for ... loop:`**

for/generate é usado para código concorrente e não pode ser dinâmico. for/loop é usado em código sequencial e pode ser dinâmico, semelhante a linguagens comuns.

**2. Qual é diferença principal entre um laço e um circuito sequencial com contador que gera o mesmo resultado?**

o laço faz em um clock só. O circuito sequencial faz em vários ciclos de clock.