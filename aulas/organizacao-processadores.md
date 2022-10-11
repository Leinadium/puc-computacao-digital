# Organização de Processadores

## Componentes de processadores

### Organização

As aplicações mais conhecidas de computação digital são *processadores* de vários tipos: microcontroladores, microprocessadores, processadores gráficos, etc. Vantagens sobre circuitos específicos (ASICs):

- **Vantagens:** Fácil de definir e mudar comportamento, fácil de descrever computações complexas:
- **Desvantagens:** Lento, sequencial, ineficiente.

Muitas vezes faz sentido instanciar um processador dentro de um FPGA ou ASIC, para as tarefas que não precisam de rapidez ou paralelismo. É o mesmo propósito que um *Sistem-on-chip*.

Um processador normalmente tem os seguintes componentes:

- **Unidade de controle**: O FSM que gerencia o ciclo de instruções
- **Controlador de *interrupts***: gerencia eventos assíncronos.
- **Unidade *load/store***: controlador de memória
- ***Caches***: memória rápida de instruções e dados
- **Unidade lógica aritmética**: faz os cálculos, também chamada ALU.

Além disso, um microcontrolador adiciona vários componentes para tarefas específicas, tais como in terfaces seriais, paralelas (GPIO), unidades para criptografia, (de)codificação de vídeo, etc.

Os componentes são interligados usando um ou mais barramentos internos do CPU. Os barramentos transportam os dados dos registros de origem até as entradas das unidades *load/store*, ALU e E/S, e também devolvem a saída a ser escrita para o registro de destino.

### Componentes

A unidade de controle (CU - *control unit*) gerencia a execução das instruções. Isso inclui

- quais são os registros de origem e de destino
- qual operação deve ser feita na ALU
- quais unidades têm acesso ao(s) barramento(s).
- em alguns casos, quais devem ser as entradas das unidades.

Toda essa informação vem da instrução a ser executada. dependente da instrução, diferentes unidades são ativadas.

A unidade de controle contém uma máquina de estados que gerencia asa outras unidades que fazem parte do caminho de dados. Além da máquina de estados, geralmente tem registros para armazenar a instrução atual (CIR - *current instruction register*) e o endereço atual no programa (PC - *program counter*). O PC geralmente avança automaticamente, mas em caso de instrução *jump* ou *branch* pode mudar.

Muitos eventos que acontecem fora do processador são assíncronos. Exemplos são comunicação serial, GPIO, rede, etc. Para evitar laços fazendo *polling* do estado, como ```while (input == 0);``` o programa pode ser **interrompido** quando acontecer alguma situação predefinida (ex: borda positiva numa entrada). Nesse caso, o *program counter* muda para uma sub-rotina específica para o evento. O controlador de *interrupts* gerencia qual evento tem prioridade.

O banco de registros (RF - *register file*) é uma memória especifica que fornece os operandos de todas as instruções. Sempre é acessível em 1 ciclo de clock.

Porque uma instrução pode ter várias entradas e uma saída, o banco de registros é uma memória com mais que uma porta.

A unidade *load/store* (LSU) gerencia a interface com a memória. Tem dois registros: o MAR (*memory address register*) que guarda o endereço a ser escrito/lido, e o MDR (*memory data register*) que guarda os dados a serem escritos/lidos.

Quando a CU manda escrever na memória, a LSU escreve os dados do MDR no endereço do MAR. E quando a CU manda ler, a LSU lê os dados no endereço do MAR no MDR.

Os registos MAR/MDR **desacomplam** os barramentos internos do CPU dos barramentos externos para a memória. Isso é importante quando

- a memória é mais lenta que o CPU, e a saída demora para ser disponível. Desacoplando o CPU pode continuar outras operações enquanto espera a memória.
- a memória precisa de algum outro tipo de gerenciamento, por exemplo o *refresh* de DRAM. Nesse caso terá uma pequena máquina de estados dentro da LSU.

Ligando um CPU de baixa frequência com SRAM rápida pode poupar um ciclo de clock dispensando os registros.

Em sistemas de alto desempenho, a memória geralmente é bem mais lenta que o processador. Não só em termos de largura de banda, mas especialmente em termos de latência. Pode demorar **centenas de ciclos** para carregar dados na memória do sistema.

Para evitar o processador para execução, os dados dos endereços de memória mais usados são armazenados numa memória mais rápida chamada *cache*. Geralmente tem vários níveis de cache (L1, L2, L3), com cada nível superior ficando maior porém tendo mais latência.

Cada vez que dados são carregados da memória, são armazenados no *cache* para reuso. Quando fica cheio, os dados usados menos recentemente (*least recently used*) são sobrescritos.

A unidade lógica aritmética (ALU - *arithmetic logic unit*) faz os cálculos e outras operações aritméticas

A CU seleciona qual operação deve ser feita. As bandeiras (*carry out*, *overflow*, *zero*, etc.) voltam para a CU que pode usá-las para modificar a próxima instrução (instrução *branch*).

Um CPU pode ter mais que uma unidade aritmética. Exemplos são:

- **Divisor**: implementado separadamente porque tem uma latência grande;
- **FPU**: *Floating Point Unit*. Unidade para cálculos com ponto flutuante.
- **Vector unit**: para fazer cálculos com mais que um valor ao mesmo tempo (4x8-bit ao invés de 32-bit).

Geralmente só faz sentido ter mais que um ALU para CPUs que podem executar mais que uma instrução ao mesmo tempo (*superscalar*).

## Caminho de dados

### Barramentos

A organização do processador com 1 barramento precisa de menos interconexões porém precisa de ciclos separados para fornecer as entradas às unidades.

O mais comum hoje em dia são 3 barramentos, assim conseguindo carregar duas entradas e descarregar uma saída por ciclo de clock.

Existem duas arquiteturas de barramento clássicas:

- **Harvard**: instruções e dados ficam em memórias separadas. O processador usa uma unidade *load/store* e barramento externo para acessar as instruções, e outra para acessar a memória de dados.
- **Von Neumann**: instruções e os dados compartilham a mesma memória (mas normalmente ficam em partes separadas), e são acessados pelo mesmo barramento externo.

Na arquitetura **Harvard**, as memórias de instruções e de dados podem ter tamanhos diferentes, e a memória de instruções pode ser implementada usando ROM ou Flash. Pode carregar instruções e dados ao mesmo tempo.

A arquitetura **Von Neumann** precisa de menos pinos que Harvard, e possibilita a execução de código de lugares diferentes, por exemplo de um disco rígido ou da rede. Até pode moficiar o código na hora de rodar.

A maioria de microprocessadores hoje em dia usa a arquitetura Harvard modificada, usando só um LSU, mas *caches* diferentes para instruções e dados. assim, combina as vantagens das duas arquiteturas.

## Ciclo de instrução

Para executar uma instrução, várias coisas têm que acontecer

- **Fetch** (IF): Ler a instrução da memória
- **Decode** (ID): Configurar o caminho de dados
- **Execute** (EX): Fazer a operação desejada (aritmética, acesso de memória).

Cada estágio precisa de um ou mais ciclos de clock. Diferentes processadores podem usar diferentes estágios, por exemplo para lidar com memória lenta ou instruções lentas (por exemplo, porque em si podem acessar memória).

### Fecth

O estágio *fetch* consiste em dois passos. No primeiro, o endereço do *program counter* é apresentado a memória:

$$
MAR ← PC
$$

Supondo uma memória de instruções que devolve o conteúdo em 1 ciclo de clock, no próximo passo o resultado é disponível para armazenar no CIR. Ao mesmo tempo, o PC é incrementado, seja por um incrementador dentro da CU, ou pela ALU.

$$
CIR ← MEM[MAR]
PC ← PC + N
$$

onde N é o tamnho da instrução em palavras da memória de instruções.

### Decode

No estágio *decode*, a CU decodifica a instrução no CIR para decidir como configurar o caminho de dados para executá-lo. Por exemplo, para executar a instrução

```text
ADD R2, R0, R1
```

que adiciona `R0` e `R1`, colocando o resultado em `R2`, esse estágio configura a RU para forneceser `R0` e `R1` às entradas da ALU:

$$
A ← R0
B ← R1
$$

### Execute

No estágio *execute* é feita a operação desejada. A unidade escolhida (nesse caso, a ALU), executa a operação configurada pela CU. No caso do exemplo

```text
ADD R2, R0, R1
```

A ALU faz os cálculos e a RU armazena no registro desejado:

$$
R2 ← A + B
$$

### Exemplo

As transfências de registros feitas na execução da instrução:

```text
ADD R2, R0, R1
```

então são (assumindo PC incrementado pela ALU):

$$
MAR ← PC
A ← PC
B ← N
CIR ← MEM[MAR]
PC ← A + B
A ← R0
B ← R1
R2 ← A + B
$$

Para a instrução

```text
LDR R0, [R1]
```

que lê o conteúdo da memória no endereço `R1` e escreve no registro `R0`, as transferências são:

$$
MAR ← PC
A ← PC
B ← N
CIR ← MEM[MAR]
PC ← A + B
MAR ← R1
R0 ← MEM[MAR]
$$

### Saltos

Para implementar sub-rotinas ou ações condicionais, o PC deve mudar programaticamente. Por exemplo, para a instrução

```text
RJMP R0
```

a próxima instrução a ser executada fica no endereço ```PC + R0```. Nesse caso, o novo valor do PC é calculado no estágio *execute*:

$$
...
PC ← A + B
A ← PC
B ← R0
PC ← A + B
$$

Nessa implementação, a próxima instrução é ```PC + R0 + N```, porque fica depois do incremento automático.

## Arquiteturas avançadas

A arquiteutar do exemplo é bem simples, e pode ser implementada no projeto de uma disciplina de graduação. Processadores reais usam técnicas mais avançadas para aumentar o desempenho. Por exemplo:

- ***Pipelining***: executar vários estágios ao mesmo tempo
- **Superscalar**: executar várias instruções de um programa sequencial ao mesmo tempo:
- **VLIW**: *Very long instruction word*, usar instruções que definem mais que uma operação (por exemplo, uma operação por ALU dentro do processador).

Dessa técnicas, *pipelining* é o mais comum, sendo implementado até em microcontroladores pequenas.

### Pipelining

No exemplo, os estágios fetch, decode, execute acontecem sequencialmente. A ideia de pipelining é que podem acontecer **ao mesmo tempo**, porém para instruções diferentes. Enquanto o processador está decodificando a instrução no endereço `PC`, já pode buscar a no endereço `PC + N`. A implementação clássica usa 5 estágios.

*Pipelining* permite a execução de 1 ciclo por instrução, porém cada instrução ainda precisa de 5 ciclos para a execução.

O *pipelining* pode gerar problema quando uma operação precisa da saída da operação anterior, que ainda não foi escrita no registro.

```text
ADD R0, R1, R2
SUB R3, R4, R0
```

Nesse caso, precisa encaminhar a saída do estágio EX da operação anterior diretamente para a entrada do estágio EX da operação atual.

Um problema maior é quando uma operação de acesso de memória (com saída só no final do estágio MEM) é usada na próxima operação.

```text
LDR R0, [R1]
SUB R3, R4, R0
```

Nessa situação não é possível encaminhar a saída em tempo suficiente. Precisamos adiar a execução do resto das instruções por 1 ciclo para esperar a saída do estágio MEM ficar disponível.

### Arquitetura *superscalar*

Uma arquitetura que executa ao máxima uma instrução por ciclo do clock é chamada *scalar*. Ambas as arquiteturas *VLIW* e *superscalar* executam mais que uma instrução por ciclo. Enquanto para VLIW isso é explicito, para arquiteturas *superscalar*, o **paralelismo é escondido do programa**.

A vantagem é que pode mudar a quantidades de ALUs sem recompilar o programa, mas o CPU precisa **buscar várias instruções ao mesmo tempo** e determinar quais podem ser executadas em paralelo.

Todas as arquiteturas modernas de alto desempenho (Intel Core, AMD Zen, ARM Cortex), são *superscalar*.

Num processador *superscalar*, mais que uma instrução está ativa no mesmo estágio.

O processador mantém um buffer de instruções a serem executadas, e escolhe instruções independentes para executar no mesmo ciclo. Com *pipeline* de até 20 estágios e 4 instruções por estágio, **CPUs modernos executam até 100 instruções ao mesmo tempo**.