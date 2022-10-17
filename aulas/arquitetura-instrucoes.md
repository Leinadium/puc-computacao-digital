# Arquitetura de Instruções

## Linguagem Assembly

Processadores executam uma sequência de instruções que vêm da memória. Essas instruções são codificadas num formato binário específico para o processador.

Por exemplo:

| Opcode | Operando 1 | Operando 2 |
| :----- | :--------: | :--------: |
| 0101   |     01     |     10     |
| 1001   |     11     |     00     |

O formato legível do código binário é chamado *assembly*

| Mnemonic | Operando 1 | Operando 2 |
| :------- | :--------: | :--------: |
| *add*    |     r1     |     r2     |
| *xor*    |     r3     |     r0     |

O papel de um programa em assembly é especificar o conteúdo da memória de instruções. O conteúdo pode incluir instruções constantes e endereços. Os padrões variam, mas um conjunto mínimo pode incluir os seguintes comandos:

- **.org**: define a posição atual na memória: onde a instrução deve ficar
- **.db**: define diretamente o conteúdo da memória
- **.equ**: define uma constante (valor, endereço), que pode ser referenciado depois
- **rótulos**: definem um endereço na posição atual que pode ser referenciado depois
- **instruções**: implementam o código do programa

O código de exemplo acima possibilita o seguinte programa:

```nasm
    .equ    led, oxff   ; Registro dos LEDs

    .org    0x20        ; Inicio do programa
    ldi     r1, @led    ; Carrega registro dos LEDs em r1
    ldi     r0, @0x00   ; Contador comeca em 0

loop:
    inc r0          ; Incrementa contador
    st  r0, [r1]    ; Mostra a conta atual nos LEDs
    jmpi    @loop   ; Laco infinito
```

que gera um objeto binário começando em endereço 32 (0x20), implementando um contador infinito. `loop` é uma constante que contém o endereço calculado da instrução `inc r0`.

Para explicar o comportamento das instruções, usamos a notação de transferência entre registros (RTN). Mas nesse caso, não são os registros internos do caminho de dados, mas só os registros acessíveis pelo programa. Não necessariamente são transferências que acontecem em um ciclo do *clock*. Por exemplo,

```assembly
st  r0, [r1]
```

resulta nas transferências

```text
MEM[r1] <- r0
pc <- pc + 1        // será implicito a partir daqui
```

Frequentemente, para acessar memória precisamos calcular o endereço. Por exemplo, para ler de um array, temos que `val = arr[idx];`. O endereço é `arr + sizeof(*arr) * idx`. Processadores podem usar vários *modos de endereçamento* para suportar esse tipo de cálculo. O modo básico é

```assembly
ld  r0, [r1]
```

que implementa a transferência

```text
r0 <-- MEM[r1]
```

Para implementar acesso de *arrays* usando só o modo básico de endereçamento, precisamos de várias instruções para fazer o cálculo. Para reduzir o tamanho do programa, vários processadores suportam modos de endereçamento mais avançados. Exemplos são:

```assembly
ld r0, [N]                  ; r0 <-- MEM[N]
ld r0, [r1]                 ; r0 <-- MEM[r1]]
ld r0, [r1 + N]             ; r0 <-- MEM[r1 + N]
ld r0, [r1 + r2]            ; r0 <-- MEM[r1 + r2]
ld r0, [r1 + r2 + N]        ; r0 <-- MEM[r1 + r2 + N]
ld r0, [r1 + r2 lsl K]      ; r0 <-- MEM[r1 + r2<<K]
ld r0, [r1 + r2 lsl K + N]  ; r0 <-- MEM[r1 + r2<<K + N]
```

Esses modos precisam de circuitos mais complexos. Por isso, alguns conjuntos modernos (RISC-V) só suportam os primeiros três.

Arquiteturas que não permitem acesso a memória para instruções aritméticas são chamadas arquiteturas *load/store*. Nesse caso, para executar a instrução

```asm
add ro, [r1]
```

precisa primeiramente acessar a memória e na próxima instrução fazer o cálculo

```asm
ld  r1, [r1]
add r0, r1
```

Instruções que podem misturar cálculos com acesso a memória precisam de um estágio EX depois do estágio MEM, que de novo deixa o circuito mais complexo.

Existia um debate entre qual filosofica é melhor, instruções simples ou complexas:

- **CISC**: Arquiteturas tipo *Complex Instruction Set Computing* usam instruções complexas, com vários modos de endereçamento, que podem misturar cálculos e acesso à memória e que têm tamanho e duração variáveis. 6502, 8051 e x86 são CISC. Por exemplo, a instrução `repnz movs` em x86 pode copiar uma string terminado em `\0` de uma parte da memória para outra parte.
- **RISC**: Arquiteturas tipo *Reduced Instruction Set Computing* usam instruções simples, com tamanho e duração fixos. AVR, ARM, MIPS e RISC-V são RISC.

Hoje em dia, mesmo processadores que implementam conjuntos de instruções complexos usam *micro-operações* tipo RISC internamente.

## Instruções

Conjuntos de instruções normalmente suportam as seguintes instruções básicas, além de instruções específicas para o processador.

- Movimento de dados
  - Acesso de memória
  - Movimentação entre registros
- Operações aritméticas
  - Adição
  - Subtração
  - Multiplicação
  - etc.
- Operações de deslocamento
  - Deslocamento
  - Rotação
- Saltos
  - Saltos condicionais
  - Saltos não condicionais
  - Chamar e voltar de sub-rotinas

Cada linguagem *assembly* tem a sua própria notaao, mas o comportamento é mais ou menos igual.

### Instruções básicas

Já vimos algumas instruções de movimento de dados:

```assembly
ldi Rd, N       ; Load immediate: Rd <-- N
ld  Rd, [Rr]    ; Load indirect: Rd <-- MEM[Rr]
st  Rd, [Rr]    ; Store indirect: MEM[Rr] <-- Rd
mov Rd, Rr      ; Move register: Rd <-- Rr
```

onde `Rd` é o registro de destino, e `Rr` um registro fonte. Geralmente pode usar qualquer registro do banco de registros, por exemplo `r0` até `r15`.

A instrução `ldi` também pode ter o *mnemonic* `mov`.

```assembly
mov Rd, N       ; Move immediate: Rd <-- N
```

Operações aritméticas geralmente seguem um dos seguintes padrões.

```text
MNE RD, Rr          ; Rd <-- Rd OP Rr
MNE Rd, Rr, Rr2     ; Rd <-- Rr OP Rr2
```

A segunda forma é mais geral (não sobreescreve o primeiro operando), porém precisa codificar três registros na instrução. Operações comuns são:

| Mnemonic | Operação |
| :------- | -------: |
| **add**  |        + |
| **sub**  |        - |
| **mul**  |        x |
| **div**  |        / |

Onde **mul** deve ter variações diferentes para valores com ou sem sinal. Também pode existir as instruções `inc Rd` ou `dec Rd`

Para fazer cálculos com valores que não cabem em um só registro, existem variações das instruções. Por assembly

```assembly
addc Rd, Rr     ; Rd <-- Rd + Rr + carry
subb Rd, Rr     ; Rd <-- Rd - Rr - borrow
```

Onde `borrow = 1 - carry`. Assim, pode escrever

```assembly
add  r1, r3 ; r1 <-- r1 + r3
addc r0, r2 ; r0 <-- r0 + r2 + carry
```

Para adicionar o valor no **conjunto dos registros** `r2` e `r3` ao valor no conjunto `r0`, `r1`. Portanto, o tamanho da palavra de um processador (8-bit, 32-bit, etc.) não define o tamanho dos valores que pode processar, só o tamanho que pode processar **em um ciclo de clock**.

As operações lógicas funcionam da mesma forma que as operações aritméticas. Operações ocmuns são `and`, `or` e `xor`, bem como operações específicas para calcular os complementos para 1 e 2.

```assembly
not Rd  ; Rd <-- ~Rd
neg Rd  ; Rd <-- ~Rd + 1
```

Também podem existir operações para setar e resetar bits específicos num registro. Logicamente, as seguintes operações são equivalentes:

```assembly
or  r0, 0x04    ; r0 <-- r0 OR "100"
sbr r0, 2       ; r0(2) <-- 1
```

mas em alguns processadores o ato de escrever em um bit tem efeito, e a segunda versão evita escrever todos os bits.

As operações de deslocamento são as mesmas que em VHDL porém geralmente têm interação com o *carry*: o valor que saiu do registro é guardado no *carry*.

```assembly
lsl Rd  ; Rd(N-1 .. 1) ← Rd(N-2 .. 0), Rd(0) ← 0, C ← Rd(N-1)
lsr Rd  ; Rd(N-2 .. 0) ← Rd(N-1 .. 1), Rd(N-1) ← 0, C ← Rd(0)
asr Rd  ; Rd(N-2 .. 0) ← Rd(N-1 .. 1), Rd(N-1) ← Rd(N-1),
        ; C ← Rd(0)
```

Para as rotações, frequentemente existe uma diferença entre rotações com e sem o *carry*:

```assembly
rol Rd  ; Rd(N-1 .. 1) ← Rd(N-2 .. 0), Rd(0)   ← Rd(N-1)
ror Rd  ; Rd(N-2 .. 0) ← Rd(N-1 .. 1), Rd(N-1) ← Rd(0)
rcl Rd  ; Rd(N-1 .. 1) ← Rd(N-2 .. 0), Rd(0)   ← C, C ← Rd(N-1)
rcr Rd  ; Rd(N-2 .. 0) ← Rd(N-1 .. 1), Rd(N-1) ← C, C ← Rd(0)
```

De novo, as versões com carry são usadas para trabalhar com valores que não cabem em um só registro.

### Saltos

Um programa não é só uma sequência de instruções. **Saltos** podem mudar a ordem de execução. Existem saltos não condicionais (*jumps*) e saltos condicionais (*branches*). Saltos têm três formas comuns: absoluto, relativo e indireto.

```assembly
jmp N   ; pc ← N
rjmp N  ; pc ← pc + N
ijmp Rd ; pc ← Rd
```

Em arquiteturas com tamanho de instruções limitado, o `N` não pode alcançar a memória inteira. Porém, a maioria de destinos dos saltos fica perto da origem. Por isso, saltos relativos são muito usados.

Para implementar um comando if, precisamos de saltos condicionais. A condição pode testar uma equação, comparação ou condição especial. Assim, existem muitas variações, por exemplo:

```assembly
brz N  ; Branch if zero
brnz N ; Branch if non zero
brlo N ; Branch if lower (valores sem sinal)
brlt N ; Branch if less than (valores com sinal)
brcs N ; Branch if carry set
brcc N ; Branch if carry clear
```

Essas condições atuam nos *flags* da ALU, e **não fazem comparações em si**. Por exemplo, para usar `brlo`, primeiramente precisa comparar os dois valores

```assembly
cmp Rd, Rr  ; calcular flags para operação Rd - Rr
```

`Rd - Rr` gera um carry caso `Rd` fica maior ou igual a `Rr`. Então, a instrução `brlo` salta se o carry está desativado. Assim, `brlo` é igual a `brcc`. 

Uma outra opção, ao invés de ter saltos condicionais, é usar **instruções condicionais**: cada instrução tem um campo que define a condição em que deve ser executada. Por exemplo, o código:

```assembly
    cmp     r0, r1      ; if (r0 == r1)
    brnz    @L1         ;
    lsl     r2          ; r2 <<= 1;
    jmp     @L2         ;
L1: lsr     r2          ; else rs >>= 1;
L2: inc     r2          ; r2++;
```

Pode ser escrito:

```assembly
        cmp r0, r1
( zero) lsl r2
(!zero) lsr r2
        inc r2
```

A quantidade de instruções por ramo define qual versão é mais eficiente.

### Pilha

Quase todos os processadores usam uma **pilha** para gerenciar memória temporária. Os usos mais ocmuns são

- **Register spilling**: Guardar variáveis que não cabem nos registros. Por que é memória rápida com várias portas, processadores têm poucos registros. Quando a computação precisa de mais dados temporários que registros, as demais variáveis são armazenadas na pilha.
- **Chamar sub-rotinas**: Na hora de chamar uma sub-rotina, os registros da função que chamou são colocados na pilha até a sub-rotina voltar.

Uma pilha é definida pelo *stack pointer* `sp`. Geralmente começa no fim da memória e é decrementado ao escrever e incrementado ao ler da pilha. As operações básicas são:

```assembly
push Rd ; MEM[sp] ← Rd      , sp ← sp - 1
pop Rd  ; Rd ← MEM[sp+1]    , sp ← sp + 1
```

Por exemplo, caso queremos trocar `r0` com `r1` mas todos os outros registros são ocupados, podemos escrever

```assembly
push r0     ; MEM[sp] ← r0, sp ← sp - 1
mov r0, r1  ; r0 ← r1
pop r1      ; r1 ← MEM[sp+1] = r0, sp ← sp + 1
```

Na hora de chamar uma sub-rotina, precisamos guardar todos os registros usados pela função que chamou. Na volta deve ser recuperados.

```assembly
push r0
push r1
...
call @SUB1 ; pc ← @SUB1, MEM[sp] ← pc + 1, sp ← sp - 1
...
pop r1
pop r0
```

A operação `call`, além de mudar o `pc`, coloca a posição da próxima instrução na pilha. Assim, a função chamada sabe para onde voltar. Isso é feito através da operação `ret`:

```assembly
ret ; pc ← MEM[sp+1], sp ← sp + 1
```

Para reagir a eventos assíncronos, processadores usam *interrupts*. Um *interrupt handler* é uma sub-rotina que pode ser chamada **assincronamente** à execução normal do programa. Ao receber um sinal do *interrupt controller*, a unidade de controle:

1. Guarda o estado atual dos *flags* e demais registros de estado;
2. Guarda `pc` na pilha.
3. Busca o endereço da sub-rotina a ser executada através da fonte do *interrupt* no *interrupt vector table*;
4. Opcionalmente, desabilita demais *interrupts*;
5. Faz um salto para a sub-rotina.

Para voltar, o *interrupt handler* usa uma instrução especial, `reti`. Além de voltar para a instrução original, também reabilita outros *interrupts* e restaura o estado do processador.

O *interrupt handler*, ao ser executado, não pode mudar nenhum dos registros. Por isso, primeiramente deve saltar os registros usados na pilha.

```assembly
ivec:   push r0
        push r1
        push r2
        ldi  r1, @led
        ld   r0, [r1]
        ldi  r2, 0x01
        xor  r0, r2
        st   r0, [r1]
        pop  r2
        pop  r1
        pop  r0
        reti
```

Para evitar isso, alguns processadores tem **registros específicos para interrupts**. Mas então não pode interromper um *interrupt*

### Codificação

Código escrito em *assembly* deve ser executado pelo processador, então precisa ser traduzido em *código de máquina* binária. A diferença entre assembly e outras linguagens é que para assembly existe uma correspondência 1:1 entre instruções ASM e instruções do processador: a codificação.

A codificação em arquiteturas RISC é bastante regular, com campos específicos para opcode e os registros de origem e destino. 

## Organização da memória

### Memória de instruções

Tendo o programa em código da máquina, é armazenado na memória de instruções. O arquivo binário é exatamente o conteúdo da memória. Porḿe, a memória não contém só instruções. Uma organização básica pode ser:

|       Memória       |
| :-----------------: |
| *interrupt vectors* |
|      Programa       |
|     Constantes      |

Para chegar a essa organização, o nosso programa pode ser:

```assembly
    .org  0x00  ; Reset vector: inicio do programa
    jmp   @main
    .org  0x04  ; UART data received
    jmp   @recv
    .org  0x20  ; Fim da tabela de interrupt vectors
main: 
    ldi   r1, @val
    ldi   r2, 4
loop: 
    ld    r0, [r1]
    ...
recv: 
    push  r0
    ...
    pop   r0
    reti
val: 
    .db 0x56, 0x48, 0x44, 0x4C
```

### Memória de dados

A memória da dados também tem uma organização padrão. Frequentemente, a pilha começa no fim, e no início tem registros de E/S mapeados na memória.

|    Memória    |
| :-----------: |
| Entrada/Saída |
|     Dados     |
|     Pilha     |

Um microcontrolador contém muitos circuitos periféricos que devem ser controlados. Pensa em comunicação serial, (U(S)ART), pinos (GPIO), timers, circuitos PWM, etc. O controle é feito através de registros. Existem duas opções:

- Os registros ficam num espaço de memória separada. Precisa de instruções especiais para acessá-los (`in`, `out`).
- Os registros ficam no mesmo espaço da memória que dados, e podem ser acessados usando as mesmas instruções (`ld`, `st`).

A segunda opção precisa de uma **decodificação do endereço** para saber a qual periférico os dados devem ser mandados.

O decodificador do endereço habilita o periférico de qual o endereço cai no espaço de memória dele.

## Systems-on-chip

### Especificação de um system-on-chip

Para desenhar um *system-on-chip* específico para uma certa tarefa precisamos definir:

- Os circuitos específicos para a tarefa (comunicação, processamento de sinais, criptografia)
- O conjunto de instruções do processador (RISC, CISC)
- A codificação das instruções (tamanho, fixo ou variável)
- A arquitetura da memória (Harvard, von Neumann)
- Os componentes do processador (RU: quantidade de registros, ALU: implementação da multiplicação, etc.)
- Os estágios da unidade de controle (*fetch*, *decode*, *execute*)
- Implementação *pipelining* ou *superscalar*

O conjunto de instruções em si exige várias decisões:

- Quais modos de endereçamento permitir?
- Arquitetura *load/store* ou misturada?
- Dois ou três operandos?
- Usar condições ou saltos condicionais?
- Codificação regular ou otimizada?
- Instruções para cálculos com ponto flutuante?
- Instruções para cálculos com vetores?

Para agilizar o desenho e reduzir a quantidade de erros, as partes bem conhecidas normalmente são comprados de vendedores:

- interfaces (DRAM, USB, Ethernet, Wifi)
- (De)codificação (áudio, vídeo)
- FFT, DCT
- Gerenciamento de energia
- Processadores
- etc.

Esses blocos (*IP Cores*) são fornecidos em VHDL/Verilog e ainda podem ser ajustados (tamanho da palavra, núcleos, etc.). Geralmente usam algum barramento padrão (AMBA, por exemplo).