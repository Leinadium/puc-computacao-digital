# Código sequencial

## Código concorrente

O tipo de código que foi visto é chamado de código concorrente:

```vhdl
Y <= -1 when X < 0 else 
      1 when X > 0 else
      0;
```

Esse código é complicado, mas descreve uma função pura da entrada. 
Para funções com memória, precisamos de outro tipo de código.

## Atributos

Sinais tem atributos, que definem meta-informação sobre a variável (tamanho do vetor, valor máximo de um valor inteiro, etc.). A sintaxe é `sinal'atributo`

Por exemplo, podemos escrever o *shift left 1* de forma genérica:

```vhdl
entity myslll is
      port (A: in  std_logic_vector (7 downto 0);
            B: out std_logic_vector (7 downto 0));
end entity;

architecture rtl of myslll is
begin
      B <= A(A'left-1 downto A'right) & '0';
end architecture
```

Alguns atributos importantes são:

- `left`: índice mais esquerdo do array (MSB quando usar `downto`)
- `right`: índice mais direito do array (LSB quando usar `downto`)
- `high`: índice maior do array (MSB)
- `low`: índice menor do array (LSB)
- `range`: faixa do array (`X to Y` ou `X downto Y`)
- `length`: tamanho do array (quantidade de índices)

O atributo mais importante para essa aula é `'event`, que fica em `'1'` quando teve um evento no sinal, e que podemos usar para atuar na borda de um clock.

## Processos

A estrutura usada para escrever código sequencial, que normalmente gera circuitos sequenciais, é o `process`.

```vhdl
process is
      -- declaracoes
begin
      -- codigo sequencial
end process;
```

O `process` cria um bloco de código sequencial dentro do código concorrente de um `architecture`. Pode-se definir vários blocos assim, que então rodam ao mesmo tempo.

Também existe a estrutura `block`, para definir blocos de código concorrente dentro do código sequencial de um `process`, mas não é muito usado.

## Eventos

Pode-se pensar num processo como um laço infinito. Contrário ao código concorrente, isso **não usa eventos**, e então pode travar a simulação

```vhdl
entity bad is
begin
      port (A: in  std_logic;
            B: out std_logic);
end entity;
architecture rtl of bad is
begin
      process is
      begin
            B <= A;     -- roda sempre, não so quando A mudar
      end process;
end architecture;
```

Não tem problema durante síntese (é um circuito, não código),
mas precisamos resolver o problema de simulação.

### Lista de sensitividade

Um `process` pode definir uma lista de sensitividade, que especifica quando um processo deve rodar. Assim, evita a simulação travar

```vhdl
architecture rtl of better is
begin
      process(A) is
      begin
            B <= A;
      end process;
end architecture;
```

A lista de sensitividade não muda a síntese, então não pode ser usado para definir comportamento, só para melhorar a eficiência da *simulação*

## Processos equivalentes

Cada atribuição em código concorrente tem um processo equivalente,
que tem como lista de sensitividade todos os sinais que aparecem na parte direita:

```vhdl
A <=  B and C;
-- equivale a
process (B, C) is
begin
      A <= B and C;
end process;
```

Consequentemente, não pode atribuir ao mesmo sinal em processos diferentes, porque é equivalente a atribuir o sinal duas vezes em código concorrente. O simulador até deixa (com resultado `X`), mas o sintetizador não.

## Código sequencial

Dentro de um processo, as atribuições são sequenciais, e uma pode sobreescrever outra:

```vhdl
begin
      A <= B;     -- nao tem efeito
      A <= C;
end process;
```

A atribuição ainda só tem efeito depois de um tempo *delta*, então só quando suspender o processo. Tem que ter cuidado na hora de usar a saída de uma atribuição como entrada de outra.

### Comandos condicionais

Uma grande diferença em código sequencial é o uso de comandos condicionais. Ao invés do `when`, que só pode ser usado como parte de uma única atribuição

```vhdl
C <= B when S = '1' else A;
D <= A when S = '0' else B;
```

O `if ... then` pode agrupar vários comandos

```vhdl
process (A, B, S) is
begin
      if S = '1' then
            C <= B;
            D <= A;
      else        -- ou elsif ... then
            C <= A;
            D <= B;
      end if;
end process;
```

Existe a mesma relação entre `with ... select` em código concorrente e `case` em código sequencial

```vhdl
with S select
      E <=  A when "00",
            B when "01",
            C when "10",
            D when "11';
-- equivale a
process (A, B, C, D, S) is
begin
      case S is
            when "00" => E <= A;    -- cada when pode ter vários comandos
            when "01" => E <= B;
            when "10" => E <= C;
            when "11" => E <= D;
      end case;
end process;
```

### Processos sincronizados

A grande aplicação de código sequencial é a definição de circuitos sequenciais (com memória). Isso é feito através de **processos sincronizados**, que atuam na borda de um *clock*:

```vhdl
process (CLK) is
begin
      if CLK'event and CLK = '1' then
            -- roda so na borda positiva do clock
      end if;
end process;
``` 

Esse processo tem o mesmo comportamento dentro do simulador e em *hardware*. A sensitividade ao `CLK` é para o simulador, e a condição `CLK'event` é para o sintetizador.

XST não suporta uma condição usando `'event` sem definição da borda (seja positiva ou negativa).

### Flip-flop

Uma forma mais sucinta de escrever `CLK'event and CLK = '1'` é `rising_edge(CLK)`

```vhdl
entity flipflop is
begin
      port (D, CLK: in  std_logic;
            Q     : out std_logic);
end entity;
architecture rtl of flipflop is
begin
      process(CLK) is
      begin
            if rising_edge(CLK) then
                  Q <= D;
            end if;
      end process;
end architecture;
```

### wait

Processos sem lista de sentitividade podem ter comandos `wait` para aguardar alguma situação. Geralmente, só são usados para criar *testbenches*, porque têm muitas restrições na hora de sintetizar. As formas são:

```vhdl
process is
begin
      wait on CLK;            -- aguarda evento no CLK;
      wait until CLK = '1';   -- aguarda borda positiva do CLK;
      wait for 100 ns;        -- aguarda 100ns;
      wait;                   -- nunca sai
end process;
```

onde `wait until` aguarda um evento que satisfaz a condição, e não só a condição em si. A condição pode ser qualquer expressão com resultado booleana.

Os dois testbenches abaixo são equivalentes

```vhdl
architecture concurrent of my_entity_tb is
begin
      A <= '0', '1' after 100ns;
end architecture;

architecture sequential of my_entity_tb is
begin
      process is
            A <= '0';
            wait for 100 ns;
            A <= '1';
            wait;
      end process;
end architecture;
-- essa ultima forma é mais facil de ler conforme os testbenches ficam mais complexos
```

### Atribuição sequencial

A funcionalidade abaixo não funciona:

```vhdl
process (CLK) is
begin
      M <= A & B;
      case M is
            when "00"   => C <= "0001"
            when "01"   => C <= "0010"
            when "10"   => C <= "0100"
            when others => C <= "1000"
      end case;
end process;
```

Pois o M só é atribuido no final do processo. Então o case vai pegar o valor anterior de M.

### Variáveis

Para resolver isso, podem se usar *variáveis*, que só podem ser definidas nas declarações de um process. Variáveis são atribuidas usando `:=` ao invés de `<=`

```vhdl
process (A) is
      variable V: std_logic;
begin
      V := A;
      B <= V;     -- igual a B <= A
end process;
```

Variáveis sempre são bem limitadas ao processo que foram declaradas. Para comunicação entre processos precisa de sinais.

Observe-se que uma variável mantém o valor sobre iterações; caso necessário, o sintetizador cria um registro..

Embora que sejam parecidos, existem muitas diferenças entre variáveis e sinais.

| tipo               |   variável    |          sinal |
| :----------------- | :-----------: | -------------: |
| código concorrente |      não      |            sim |
| código sequencial  |      sim      |            sim |
| atribuição         |     `:=`      |           `<=` |
| efeito             | imediatamente | depois *delta* |
| escopo             |   processo    |    arquitetura |
| eventos            |      não      |            sim |
| *waveform*         |      não      |            sim |


## Máquina de estados

Uma máquian de estados consiste em **estados**, uma **função de transição** e uma **função de saída**

- **estados**: Nós de comportamento do sistema. A reação do sistema a uma determinada entrada depende do estado atual.
- **função de transição**: Função que descreve qual deve ser o próximo estado dado o estado atual e a entrada atual.
- **função de saída**: Função que descreve a saída do sistema dado o estado atual e opcionalmente a entrada atual.

Uma máquina tem função de transição

| Condição  |  Início   | Preencher | Aquecer  |  Esvaziar |
| :-------- | :-------: | :-------: | :------: | --------: |
| Start='1' | Preencher |     -     |    -     |         - |
| Nivel>95  |     -     |  Aquecer  |    -     |         - |
| Temp>100  |     -     |     -     | Esvaziar |         - |
| Nivel<5   |     -     |     -     |    -     | Preencher |
| Stop='1'  |     -     |  Inicio   |  Inicio  |    Inicio |

e função de saída

| Saída     | Inicio | Preencher | Aquecer | Esvaziar |
| :-------- | :----: | :-------: | :-----: | -------: |
| ENTRADA   |   0    |     1     |    0    |        0 |
| AQUECEDOR |   0    |     0     |    1    |        0 |
| SAIDA     |   0    |     0     |    0    |        1 |

O exemplo acima é de uma **máquina de Moore**, em que a saída depende só do estado atual. Também existem máquinas cuja saída depende do estado atual e da entrada atual. Por exemplo:

| Saída     | Início | Preencher |    Aquecer    | Esvaziar |
| :-------- | :----: | :-------: | :-----------: | -------: |
| ENTRADA   |   0    |     1     |       0       |        0 |
| AQUECEDOR |   0    |     0     | KP*(100-TEMP) |        0 |
| SAIDA     |   0    |     0     |       0       |        1 |

Esse tipo de máquina é uma **máquina de Mealy**

### Efeitos

Em geral máquinas de Mealy precisam de menos estados para implementar um determinado
comportamento. Além disso, a saída é atualizada imediatamente quando a entrada muda,
e não só quando muda o estado.

O segundo efeito acontece porque máquinas de estado normalmente são implementados com processos sincronizados, que só mudam o estado depois de uma borda positiva do *clock*. Consider

### Implementação com registro

```vhdl
entity sm_register is
      port (CLK         : in  std_logic;
            IPOS, INEG  : in  std_logic;
            O           : out std_logic);
end entity;

architecture rtl of sm_register is
      -- enumeracao dos estados
      type StateT is (A, B);
      signal state, next_state: State := A;

begin
      -- funcao de transicao
      next_state <= A when (state=A and IPOS='0') or
                           (state=B and INEG='1') else B;
      
      -- registro
      process (CLK) is
      begin
            if rising_edge(CLK) then
                  state <= next_state
            end if;
      end process;

      -- funcao de saida
      O <= '1' when state=B else '0';
end architecture;
```

### Implementações com processos

O código das funções de entrada e saída geralmente é mais fácil de ler usando `case`.
Assim, deve ser implementado com código sequencial (`process`). Existem inúmeros estilos de fazer. Alguns exemplos são

- 1 processo (Moore): Toda a lógica fica em 1 processo. Parece mais um programa comum;
- 1 processo (Mealy): A mesma coisa, mas define saídas por transição para evitar atraso;
- 2 processos: Separa as funções de transição e da saída do registro;
- 3 processos: Separa todas as funções

### Exemplo

```text
Node INICIO:
      Saída: (EN, AQ, SA) <= "000".
      Transicao START='1' --> PREENCHER.

Node PREENCHER:
      Saída: (EN, AQ, SA) <= "100".
      Transicao NIVEL>95 --> AQUECER
      Transicao STOP='1' --> INICIO

Node AQUECER:
      Saída: (EN, AQ, SA) <= "010".
      Transicao TEMP>100 --> ESVAZIAR
      Transicao STOP='1' --> INICIO

Node ESVAZIAR:
      Saída: (EN, AQ, SA) <= "001".
      Transicao NIVEL<5  --> PREENCHER
      Transicao STOP='1' --> INICIO
```

Usando 3 procesos (registro, função de transição e função de saída). O último processo é feito em código concorrente.

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity chemproc is
      port (CLK, START, STOP          : in  std_logic;
            NIVEL, TEMP               : in  integer;
            ENTRADA, AQUECEDOR, SAIDA : out std_logic);
end entity;

architecture rtl of chemproc is
      type StateT is (Inicio, Preencher, Aquecer, Esvaziar);
      signal state, next_state: StateT := Inicio;
begin
      -- registro
      process(CLK) is
      begin
            if rising_edge(CLK) then
                  state <= next_state;
            end if;
      end process;

      -- funcao de transicao
      process (state, START, STOP, NIVEL, TEMP) is
      begin
            next_state <= state;
            case state is
                  when Inicio =>
                        if START = '1' then
                              next_state <= Preencher;
                        end if;
                  when Preencher =>
                        if STOP = '1' then
                              next_state <= Inicio;
                        elsif NIVEL > 95 then
                              next_state <= Aquecer;
                        end if;
                  when Aquecer =>
                        if STOP = '1' then
                              next_state <= Inicio;
                        elsif TEMP > 100 then
                              next_state <= Esvaziar;
                        end if;
                  when Esvaziar =>
                        if STOP = '1' then
                              next_state <= Inicio;
                        elsif NIVEL < 5 then
                              next_state <= Preencher;
                        end if;
            end case;
      end process;

      -- funcao de saida
      ENTRADA     <= '1' when state = Preencher else '0';
      AQUECEDOR   <= '1' when state = Aquecer   else '0';
      SAIDA       <= '1' when state = Esvaziar  else '0';
end architecture;


-- testbench
sim proc: process(CLK)
begin
      if rising_edge(CLK) then
            if ENTRADA = '1' and SAIDA = '0' then
                  NIVEL <= NIVEL + 1;
            elsif ENTRADA = '0' and SAIDA = '1' then
                  NIVEL <= NIVEL - 1;
            end if;

            if NIVEL < 50 then
                  TEMP <= 25;
            elsif AQUECEDOR = '1' then
                  TEMP <= TEMP + 1;
            end if;
      end if;
end process;

-- stimulus process
stim_proc: process
begin
      wait for 100 ns;
      START <= '1'
      wait for 100 ns;
      START <= '0'
      wait for 2800 ns;
      STOP <= '1'
      wait for 100 ns;
      STOP <= '0'
      wait;
end process;
```
