# Linguagem VHDL

## Entidade

```vhdl

-- define as portas de entrada e a porta de saída
entity and2 is
    port (A, B: in  std_logic;
          C:    out std_logic);
end entity;
```

Comparando com C, é basicamente a assinatura da função em C


## Arquitetura

A definição do IC dentro do encapsulamento, ou seja, a definição da função,
é feita através da arquitetura.

```vhdl
architecture rt1 of and2 is
begin
    C <= A and B;
end architecture;
```

Não precisa redefinir as entradas.

Podem haver várias arquiteturas. Por isso que é definido um nome para cada arquitetura.


## Portas

Cada porta tem um nome, a direção, e o tipo.

Também existem portas `inout`e `buffer`, mas não são bem suportadas.

Opcionalmente, a declaração das portas pode ser seguida pelo valor padrão (entrada) ou inicial (saída)

```vhdl
port (A, B: in  std_logic := '0';
      C:    out std_logic := '0');
```


## Sinais

Sinal != variável

Arquiteturas também podem definir sinais intermediários

```vhdl
architecture rt1 of nand2 is
    signal D: std_logic;
begin
    D <= A and B;
    C <= not D;
end architecture
```

Sinais não tem direção, mas podem ter valor inicial,

```vhdl
signal D: std_logic := '0';
```

Sinais que não mudam devem ser definidos como constantes, para deixar a síntese mais eficiente:

```vhdl
constant zero: std_logic := '0';
```


## Tipos de dados

`std_logic` é um tipo d dados do pacote `std_logic_1164` da biblioteca `ieee`.
Os tipos básicos de VHDL são:

* `bit` - Valores '0' e '1'
* `boolean` - Valores `true` e `false`
* `bit_vector` - Vetor de bits (por exemplo, un byte)
* `integer` - Valores inteiros sem definição específica da representação

Contrário de C, `bit` e `boolean` são tipos diferentes. `bit` é um sinal
digital, e `boolean` é o resultado de uma comparação (por exemplo, `A < B`)

Ao invés de `bit` e `boolean`, é mais indicado usar `std_logic` e `std_logic_vector`, porque definem mais valores úteis para a verificação de erros:

*  `'U'` - Não inicializado
*  `'X'` - Desconhecido
*  `'0'` - 0 forte
*  `'1'` - 1 forte
*  `'Z'` - Alta impedância _[não será usado]_
*  `'W'` - Desconhecido fraco _[não será usado]_
*  `'L'` - 0 fraco (usando resistor pull-down) _[não será usado]_
*  `'H'` - 1 fraco (usando resistor pull-up) _[não será usado]_
*  `'-'` - don't care _[não será usado]_

FGPAs não suportam alta impedância ou resistores pull-up ou pull-down

Valores inteiros usam a tipo `integer`. Sem especificação do `range`, a
faixa é de pelo menos 32 bits (com sinal).

```vhdl
signal I32: integer;
```

Normalmente queremos limitar a faixa para minimizar a quantidad de fios necessários para a implementação:

```vhdl
-- inteiro com sinal de 5 bits (4 + signal)
signal I5: integer range -3 to 11
```

## Vetores

`std_logic_vector` é um _array_ de valores do tipo `std_logic`.
Na hora de definir um sinal ou uma porta, tem que especificar o tamanho
do vetor usando `range`:

```vhdl
port (A, B: in  std_logic_vector (7 downto 0);
      C:    out std_logic := '0');
```

É comum especificar a faixa de vetores de bits começando com o MSB, mas 
também pode começar com o LSB:

```vhdl
signal V: std_logic_vector (0 to 3);
```

Em ambos os casos, a faixa é inclusiva. Literais de vectores são
ser escritas usando aspas duplas (como string em C).

```vhdl
signal D: std_logic_vector (7 downto 0) := "0101001";
```


## Código concorrente

O código dentro de uma arquitetura lembra linguagens procedurais como C e
Pascal, mas é executado simultaneamente, porquem descrevem _hardware_ e 
não _software_. Espeficamente, a ordem de execução é indefinida.

```vhdl
entity switch2 is
    port (A, B, S: in  std_logic;
          C, D:    out std_logic);
end entity;

architecture rt1 of switch2 is
begin
    -- os seguintes comandos acontecem ao mesmo tempo
    C <= (B and S) or (A and not S);
    D <= (A and S) or (B and not S);
end architecture;
```

## Atribuições

A maioria dos comandos em código concorrente consiste em atribuição
de expressões a sinais.

Embora que pareça atribuição a uma variável, é melhor pensar que seja uma conexão de circuitos. Por exemplo, não é possível atribuir o mesmo sinal duas vezes.

```vhdl
C <= '0';
C <= '1';   -- erro
```

Também não existe problema de ordem de xecução no seguinte código, mesmo que D seja atribuído depois de uso.

```vhdl
E <= C or D;
D <= A or B;
```

## Expressões

**Operadores lógicos**: `not`, `and`, `or`, `xor`, `nand`, `nor`, `xnor`;

**Operadores relacionais**: `=`, `/=`, `<`, `<=`, `>`, `>=`


## Operadores

### Operadores sintetiźaveis

`+`, `-`, `*`, `abs`

Para adição, subtração e multiplicação existem células padronizadas que são 
instanciadas quando necessário.

### Operadores parcialmente sintetizáveis

`/`, `mod`, `rem`, `**`

Operadores que precisam de divisão ou exponenciação devem ser implementados com 
circuitos sequenciais e então só podem ser sintetizados com um operador fixo.

```vhdl
architecture rt1 of exemplo is
    signal A, B, C, D: integer
begin
    A <= 0;     -- literal
    C <= A + B;
    D <= C / 2; -- so para potenciais de 2 fixas
end architecture;
```

### Operadores sobre vetores

#### Operadores de deslocamento

`ssl`, `srl`, `sla`, `sra`, `rol`, `ror` 

`ssl`e `srl` (logica shift) preenchem com '0', enquanto `sla` e `sra` (arithmetic shift) repetem o bit da direita ou da esquerda, respectivamente. Geralmente é mais transparente implementar usando operadores embaixo;

#### Operadores de concatenação

`&`

Concatena dois vetores, gerando um vetor com o comprimento da soma dos comprimentos dos operandos;

#### Extração de elementos

`()`

Pode-se pegar um _slice_ dos elementos individuais de um vetor.

### Exemplos

Definir os operadores de deslocamento assim:

```vhdl
entity deslocamento is
    port(X: in std_logic_vector(7 downto 0);
         Y1, Y2, Y3, Y4, Y5, Y6:
            out std_logic_vector(7 downto 0));
end entity;

architecture rtl of deslocamento is
begin
    Y1 <= X(6 downto 0) & '0'; -- X sll 1
    Y2 <= '0' & X(7 downto 1); -- X srl 1
    Y3 <= X(6 downto 0) & X(0); -- X sla 1
    Y4 <= X(7) & X(7 downto 1); -- X sra 1
    Y5 <= X(6 downto 0) & X(7); -- X rol 1
    Y6 <= X(0) & X(7 downto 1); -- X ror 1
end architecture;
```


## Comandos condicionais

Reescrevendo o código anterior utilizando condicionais

```vhdl
-- código anterior
C <= (B and S) or (A and not S);
D <= (A and S) or (B and not S);

-- novo código
C <= B when S = '1' else A;
D <= A when S = '1' else B;
```

O condicional pode ter mais que duas opções, por exemplo:

```vhdl
Y <= -1 when X < 0 else
      1 when X > 0 else
      0;
```

## Comandos de seleção

Um pouco menos geral é o `select`, que só trabalha com valores específicos 
( e não comparações gerais)

```vhdl
entity mux2 is 
    port (A, B, C, D: in  bit;
          S:          out bit_vector (1 downto 0);
          E:          out bit);
end entity;

architecture rt1 of mux2 is
begin
    with S select
        E <= A when "00",
             B when "01",
             C when "10",
             D when "11", 
end architecture
```

O select permite definir mais que uma opção por valor, e também suporta a palavra `others`, que reúne todas as opções não definidas explicitamente. Na verdade, isso é
necessário quando usar `std_logic`, por causa dos valores `X`, `U`, etc.

```vhdl
entity xor2 is
    port(A, B: in std_logic;
         C:    out std_logic);
end entity;

architecture rtl of xor2 is
    signal M: std_logic_vector(1 downto 0);
begin
    M <= A & B;
    with M select
        B <= '1' when "01" | "10",
             '0' when others;
end architecture;
```

## Circuitos realimentados

É possível especificar circuitos com realimentação

```vhdl
A <= B or A
```

Porém, circuitos sem estado estacionário são dificeis de simular e prever.
Em geral, **não use realimentação em código concorrente**.

```vhdl
entity ringosc is
    port(A: out std_logic);
end entity;

architecture rtl of ringosc is
    signal M: std_logic;
begin
    M <= not (not (not M)); -- Otimizado
    A <= M;
end architecture;
```

## Tempo

Para simular tempo, precisamos especificar quanto tempo demoram as operações.
Isso é feito através da palavra `after`, que só funciona em simulação.

```vhdl
entity clkgen is
    port (CLK: out std_logic);
end entity;

architecture sim of clkgen is
    signal M: std_logic := '0';
begin
    M <= not M after 50 ns;
    CLK <= M;
end architecture;
```