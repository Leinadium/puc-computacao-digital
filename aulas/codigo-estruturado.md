# Código estruturado

## Arquiteturas estruturais

### Metáfora

VHDL usa a metáfora de uma Placa de Circuito Impresso (PCI), em que vários CIs são integrados numa placa

* `architecutre` --> *die* (pastilha) do circuito integrado;
* `entity` --> Encapsulamento do *die*;
* `component` --> Soquete soldado na PCI;

Um `architecture` que implementa a placa, definindo quais são os soquetes (`components`) e como são interligados com tlirhas (`signals`), é chamado de uma arquitetura estrutural. Precisa fazer:

* *Declaração dos componentes*: Quais portas têm, quais tipos de sinais;
* *Declaração dos sinais*: Os *nets* da PCI;
* *Instanciação dos componentes*: Quantas peças de cada componente, e como são interligados;
* *Configuração*: Qual CI colocar em cada instância, e usando qual arquitetura.

### Arquiteturas estruturais

Suponha que temos um projeto com duas entidades: um divisor de *clock* e um multiplexador para escolher usar o *clock* original ou dividido.

Essa entidade tem declaração

```vhdl
entity optdiv is
    port (CLK, SEL:   in  std_logic;
          CLK_OPTDIV: out std_logic);
end entity;
```

Nos módulos das entidades individuais, eles têm as declarações

```vhdl
entity optdiv is
    port (CLK:     in  std_logic;
          CLK_DIV: out std_logic);
end entity;
```
e 
```vhdl
entity mux2 is
    port (A, B, S: in  std_logic;
          O      : out std_logic);
end entity;
```

e arquiteturas tipo `rtl` que implementam a funcionalidade desejada.

Precisamos **repetir** as declarações das entitdades nas declarações da arquitetura estrutural, trocando `entity` por `component`

```vhdl
architecture structural of optdiv is
    component clkdiv is
        port (CLK    : in  std_logic;
              CLK_DIV: out std_logic);
    end component;
    component mux2 is
        port (A, B, S: in  std_logic;
              O      : out std_logic);
    end component;
```

Na próxima fase, definimos o sinal que interliga as instâncias dos componentes, e as instâncias em si.

```vhdl
    signal CLK_DIV: std_logic;
begin
    divider: clkdiv port map(CLK, CLK_DIV);
    mux: mux2 port map (CLK, CLK_DIV, S, CLK_OPTDIV);
end architecture;
```

Isso é instanciado **por posição**. Também podemos escrever

```vhdl
    divider: clkdiv port map (CLK=>CLK, CLK_DIV=>CLK_DIV);
```

que faz o mapeamento **por nome** dos sinais. Assim, as portas não mapeadas usam o valor padrão. Também não terá problema quando mudar a **ordem** das portas.

Finalmente, temos que definir qual CI vamos colocar em qual soquete. Isso é feito antes do `begin` da arquitetura.

```vhdl
    signal CLK_DIV: std_logic;

    for diviver: clkdiv use entity work.clkdiv(rtl);
    for mux: mux2 use entity work.mux2(rtl);
begin
```

Para cada instância, define qual entidade (e opcionalmente, qual arquitetura) usar. Para selecionar a mesma entidade para todas as instâncias de um componente, pode usar 

```vhdl
    for all: clkdiv use entity work.clkdiv(rlt);
```

`work` é a biblioteca padrão do projeto atual, que então inclue todas as entidades definidas nos módulos do projeto.

A definição final da arquitetura estrutural é bem palavrosa. Podemos reduzir com alguns **atalhos**:

```vhdl
architecutre strucutral of optdiv is
    signal CLK_DIV: std_logic;
begin
    divider: entity work.clkdiv port map(CLK, CLK_DIV);
    mux: entity work.mux2 port map(CLK, CLK_DIV, S, CLK_OPTDIV);
end architecture;
```

Assim **perde a separação de declaração e configuração**, mas para projetos pequenos é bem mais legível.


## Estruturas de dados

### Definição

Existem outras abordagens de estruturar o código além de arquiteturas estruturais. Uma delas é a definição de novos tipos. Podemos distinguir três classes disso

- *Escalar*: Tipo de um valor de uma certa faixa;
- *Array*: Vetores ou matrizes de valores do mesmo tipo;
- *Record*: Estruturas de valores de tipos diferentes.
  
Também pode-se definir *subtipos*, que aplicam restrições adicionais a um tipo já existente.

Para definir um novo tipo de escalar, basta definir a faixa de valores. Essa faixa pode ser uma enumeração, faixa de valores inteiros, ou faixa de valores de ponto flutuante:

```vhdl
architecture rtl of scalartest is
    type StateT is (Inicio,Preencher,Aquecer,Esvaziar);
    type LedAddressT is range 0 to 7;
    type VoltageT is range 0.0 to 5.0;
```

Porém, tipos de ponto flutuante não são suportados pelo sintetizador. Fora disso, a conversão entre tipos similares não é automática. Precisa de uma **conversão de tipos:**:

```vhdl
    signal addr: LedAddresT;
    signal myint: integer := 4;
begin
    addr <= myint;  -- Erro
    addr <= LedAddressT(myint); -- OK
end architecture
```

Ja vimos o uso de *arrays* na definição de vetores de bits:

```vhdl
    signal in_nibble: std_logic_vector(3 downto 0);
```

Definindo um novo tipo para um *nibble*, podemos reescrever assim:

```vhdl
architecture rtl of arraytest is
    type NibbleT is array(3 downto 0) of std_logic;
    signal in_nibble: NibbleT;
```

De novo, `NibbleT` é um tipo diferente que `std_logic_vector(3 downto 0)`, então para atribuição temos que converter:

```vhdl
    signal myvec: std_logic_vector(3 downto 0) := "0000";
begin
    in_nibble <= myvec;  -- Erro
    in_nibble <= NibbleT(myvec);  -- OK
end architecture;
```

Para a definição de estruturas de dados com tipos diferentes, VHDL usa `record`, que é equivalente a `struct` em C.

```vhdl
architecture rtl of typetest is
    type SMInput is record
        start, stop: std_logic;
        nivel, temp: integer;
    end record;
    type SMOutput is record
        entrada, aquecedor, saida: std_logic;
    end record;
```

Os elementos podem ser acessados por `.`

```vhdl
    signal input: SMInputT;
    signal output: SMOutputT;
begin
    output.entrada <= '1' when input.nivel < 95 else '0';
end architecture;
```

### Atribuição

Muitas vezes queremos atribuir valores a mais que um elemento de um `array` ou `record`. Para *arrays*, ja vimos o uso de aspas duplas

```vhdl
    signal in_nibble1: NibbleT := "0100";
```

mas também podemos usar um ***aggregate*** de elementos individuais:

```vhdl
    signal in_nibble2: NibbleT := ('0', '1', '0', '0');
```

Um *aggregate* pode ser construído por posição (como acima), mas também por índice, e suporta o uso de `others` para índices não definidos

```vhdl
    signal in_nibble3: NibbleT := (2      => '1',
                                   others => '0');
```

A mesma coisa podemos fazer para a atribuição a estruturas

```vhdl
    -- start, stop, nivel, temp
    signal input: SMInputT := ('0', '0', 0, 0);

    -- entrada, aquecedor, saida
    signal output: SMOutputT := (others => '0');
```

Finalmente, pode usar agregação na parte esquerda de atribuições também. Por exemplo, podemos escrever uma rotação esquerda de uma palavra assim

```vhdl
    signal i: NibbleT;
    signal o: NibbleT;
begin
    (o(0), o(3), o(2), o(1)) <= i;
```

E a atribuição das saídas da máquina de estados sem o uso de `record`

```vhdl
    signal entrada, aquecedor, saida := std_logic;
begin
    (entrada, aquecedor, saida) <= std_logic_vector '("000");
```

Onde a expressão `tipo'(expressão)` quer dizer: interpretar a `expressão` como um `tipo` (*qualified expression*).

### Subtipos

Para facilitar a convesrão entre tipos similares, podemos definir novos tipos como `subtype` de um tipo já existente. Ao invés de

```vhdl
    type LedAddresT is range 0 to 7;
    type NibbleT is array (3 downto 0) of std_logic;
```

podemos escrever

```vhdl
    subtype LedAddressT is integer range 0 to 7;
    subtype NibbleT is std_logic_vector(3 downto 0);
```

que deixa converter sinais do tipo original para o tipo mais restringido e vice versa.

```vhdl
    signal addr: LedAddressT;
    signal in_nibble: NibbleT;
begin
    addr <= integer '(4);
    in_nibble <= std_logic_vector '("0000");
```


## Laços (loops)

### Laços

Em linguagens comuns existem comandos para repitir uma sequencia de comandos: `for` e `while`. VHDL também tem `for`, mas é um pouco diferente porque **todas rodam ao mesmo tempo**. Por isso devem ter uma quantidade limitada de iterações.

Os dois laços mais importantes são:

- para código concorrente: `label: for <variavel> in <faixa> generate`
- para código sequencial (processo): `for <variavel> in <faixa> loop`

Usando `for...generate` podemos escrever um reversor de palavras genérico

```vhdl
entity rev32 is
    port (A:  in  std_logic_vector(31 downto 0);
          B:  out std_logic_vector(31 downto 0));
end entity
architecture rtl of rev32 is
begin
    gen_rev: for i in 0 to A'high generate
        B(A'high-i) <= A(i);
    end generate;
end architecture;
```

O circuito é o mesmo que escrever cada iteração separadamente.
Realmente é um **gerador de código**, não uma sequência de iterações.

Para gerar código irregular, pode usar `if...generate`. Porém, a condição deve ser **estática**.

```vhdl
entity unweave32 is
    port (A   : in  std_logic_vector(31 downto 0);
          B, C: out std_logic_vector(15 downto 0));
end entity;

architecture rtl of unweave32 is
begin
    gen_unweave: for i in 0 to A'high generate
        gen_even: if i rem 2 = 0 generate
            B(i/2) <= A(i);
        end generate;
        gen_odd: if i rem 2 = 1 generate
            C(i/2) <= A(i);
        end generate;
    end generate;
end architecture;
```

Para código sequencial, existe `for...loop` que funciona da mesma forma que `for...generate`. Porém, não precisa usar `if...generate`, porque já existe `if...then` em código sequencial.

```vhdl
architecture rtl_seq of unweave32 is
begin
    process(A) is
    begin
        for i in 0 to A'high loop
            if i rem 2 = 0 then
                B(i/2) <= A(i);
            else
                C(i/2) <= A(i);
            end if;
        end loop;
    end process;
end architecture;
```

### Condições dinâmicas

As condições em laçoes sequenciais podem ser dinâmicas. Assim, pode executar só uma parte do laço

```vhdl
entity count1 is
    port (A: in  std_logic_vector(31 downto 0);
          B: out integer
    );
end entity;

architecture rtl of count1 is
begin
    process(A) is
        variable count: integer range 0 to A'high := 0;
    begin
        for i in 0 to A'high loop
            if A(i) = '1' then
                count := count + 1;
            end if;
        end loop;
        B <= count;
    end process;
end architecture;
```

Mas tem que ter cuidado! O código no slide anterior gera um circuito que ocupa 2% do espaço **TOTAL** do Spartan 3E, e que tem tempo de propagação de 100ns (frequẽncia máxima: 10MHz).

Quando usar um laço, então sempre tem que pensar no circuito que está gerando.

Em laços sequenciais, também pode usar `next` (continuar com próxima iteração) e `exit` (sair do laço), os equivalentes de `continue` e `break`. Opcionalmente, esses comandos podem ter uma condição.

```vhdl
entity first1 is
    port (A: in  std_logic_vector(31 downto 0);
          B: out integer);
end entity

architecture rtl of first1 is
begin
    process (A) is
    begin
        for i in A'high downto 0 loop
            B <= 1;
            exit when A(1) = '1';
        end loop;
    end process;
end architecture;
```

De novo, isso pode gerar circuitos muito grandes ou lentos, porque todas as iterações são geradas. É só que os resultados das iterações não executadas são **descartadas**


### Generics

Em todos os exemplos anteriores, o código dentro da arquitetura é genérico, usando `A'high`. Porém, a entidade é especifica para um certo tamanhp da entrada:

Quando o tamanho realmente não é importante, podemos omitir a faixa. Assim, automaticamente pega a faixa do sinal usado na instância

```vhdl
entity first1 is
    port (A: in  std_logic_vector;
          B: out integer);
end entity;
```

As vezes, é útil definir algum parâmetro explicitamente. Por exemplo, no `unweave32`, as saídas devem ter a metade do tamanho da entrada. Nesse caso, podemos usar um `generic`

```vhdl
entity unweave is
    generic (N: integer := 32);
    port (A   : in  std_logic_vector(N-1 downto 0);
          B, C: out std_logic_vector(N/2-1 downto 0));
end entity;
```

Na hora de instanciar, precisamos definir o valor dos parâmetros genéricos

```vhdl
unweave32: entity work.unweave
    generic map (32)
    port map (A, b):
```

#### Exemplo

Construindo um circuito para atrasar um sinal N ciclos de *clock*

```vhdl
entity delayline is
    generic (N: positive);  -- restringe N maior que 0
    port (CLK, A: in  std_logic;
          B     : out std_logic
    );
end entity

architecture rtl of delayline is
    signal memoria: std_logic_vector(N-1 downto 0);
begin
    process (CLK) is
    begin
        if rising_edge(CLK) then
            B <= memoria(N-1);  -- atualiza a saida
            for i in N-1 downto 1 loop
                M(i) <= M(i-1); -- atualiza a memoria
            end loop;
        end if;
    end process;
end architecture
```


## Sub-rotinas

Apesar de ser possível escrever código modular através de arquiteturas estruturais, é bem palavroso; normalmente é usado para subcircuitos maiores. Para rotinas pequenas que fazem mais sentido aplicar dentro do código mesmo, existem sub-rotinas, usando as palavras `function` e `procedure`

- `function`: Sub-rotinas que devolvem um valor;
- `procedure`: Sub-rotinas genéricas que não devolvem um valor mas usam sinais para passar dados.

`function` e `procedure` que não ficam dentro de um pacote devem ser definidos nas declarações de um arquitetura.

### Function

Funções geralmente calculam uma coisa simples. Podem ser usadas em código concorrente ou sequencial, mas o código dentro de uma função sempre é sequencial. Podem declarar variáveis locais, mas são temporárias: não mantêm o valor. A forma genérica é

```vhdl
function nome(parametros) return tipo is
    -- declaracoes
begin
    -- codigo sequencial
end function;
```
onde `parametros` é uma lista de parâmetros de entrada, separados por `;`.

#### Exemplo

Para converter um `std_logic_vetor` para `integer` podemos escrever uma função `u2i` para interpretar o sinal binário.

```vhdl
function u2i(A: std_logic_vector) return integer is
    variable R: integer := 0;
begin
    for i in A'range loop
        R := 2 * R;
        if A(i) = '1' then
            R := R + 1;
        end if;
    end loop;
    return R;
end function;
```

Uma função fica na parte das declarações da arquitetura, e pode ser chamada em qualquer expressão

```vhdl
entity threshold is
    port (LEVEL:     in  std_logic_vector (7 downto 0);
          LOW, HIGH: out std_logic);
end entity;
architecture rtl of threshold is
    function u2i(A: std_logic_vetor) return integer is
        -- implementação aqui
    end function;
begin
    LOW  <= '1' when u2i(LEVEL) < 5 else '0';
    HIGH <= '1' when u2i(LEVEN) > 95 else '0';
end architecture;
```

### Procedure

Para sub-rotinas que devem devolver mais que um valor, use-se `procedure`. Na verdade, não devolvem um valor, mas usa argumentos de entrada e saída como se fosse um entidade. Os argumentos podem ser constantes, variáveis ou sinais.

```vhdl
procedure nome(parametros) is
    -- declaracoes
begin
    -- codigo sequencial
end procedure;
```

Nesse caso, os `parametros` têm que definir o tipo (`constant`, `variable` ou `signal`) e a direção (`in`, `out` ou `inout`).

#### Exemplo

Escrevendo uma entidade para decodificar dois sinais de 2 bits. Então para cada entrada de 2 bits temos 4 saídas.

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode2 is
    port (A, B          : in  std_logic_vector(1 downto 0);
          A0, A1, A2, A3: out std_logic;
          B0, B1, B2, B3: out std_logic
    );
end entity;

architecture rtl of decode2 is
    -- funcao que decodifica vetores de qualquer tamanho
    function decode(A: std_logic_vector) return std_logic_vector is
        variable B: std_logic_vetor(0 to 2**A'length-1) := (others => '0');
    begin
        for i in B'range loop
            -- to_integer é a forma padrão do pacote numeric_std
            -- para conveter std_logic_vector para integer
            if i = to_integer(unsigned(A)) then
                B(i) := '1';
            end if;
        end loop;
    end function;

    -- decodifica um sinal de 2 bits
    procedure decode24(
        signal A         : in  std_logic_vector(1 downto 0);
        signal B, C, D, E: out std_logic
    ) is
    begin
        (B, C, D, E) <= decode(A);
    end procedure;
begin
    decode24(A, A0, A1, A2, A3);
    decode24(B, B0, B1, B2, B3);
end architecture;
```

## Pacotes e bibliotecas

Tipos e sub-rotinas normalmente são genéricas, então faz sentido usá-los em mais que uma arquiteture. Fora disso, pode ser vantajoso criar um conjunto de entidades generalizadas para uso em vários projetos. Para permitir isso, VHDL usa os conceitos de **pacotes** e **bibliotecas**

- **pacote**: Conjunto de declarações de tipos, componentes e subrotinas;
- **biblioteca**: Conjunto de pacotes e entidades.

A biblioteca padrão é `work`, então todos os pacotes e entidades dentro dos módulos do **projeto atual** ficam lá.

### Pacotes

Um pacote é definido usando a palavra `package`, onde ficam as declarações

```vhdl
package minha_pacote is
    type NibbleT is array(3 downto 0) of std_logic;
    
    component mux2 is
        port (A, B, S: in  std_logic;
              O      : out std_logic);
    end component;
    function decode(A: std_logic_vector) return
        std_logic_vector;
end package;
```

As definições de funções e procedures ficam dentro de um `package body`, que também pode conter outras declarações não visíveis

```vhdl
package body minha_pacote is
    function decode(A: std_logic_vector) return std_logic_vector is
        variable B: std_logic_vector(0 to 2**A'length-1)
            := (others => '0');
    begin
        for i in B'range loop
            if i = to_integer(unsigned(A)) then
                B(i) := '1';
            end if;
        end loop;
        return B;
    end function;
end package;
```

Para poder usar um pacote, precisa refenciar no módulo. Usa-se

```vhdl
use work.minha_pacote.all;  -- todas as declaracoes
use work.minha_pacote.NibbleT;  -- uma especifica
```

Obs: precisa referenciar os pacotes antes de cada entidade num módulo. Então se tiver duas entidades definidas num só módulo, precisa referenciar os pacotes importados duas vezes.

### Bibliotecas

Bibliotecas são conjuntos de arquivos VHDL que podem ser usados em vários projetos. Frequentemente são reunidos numa pasta, mas não necessariamente. 