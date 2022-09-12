# Interfaces

## Sinais Externos

### Metaestabilidade

FPGAs precisam de comunicação com o mundo real para fazer coisas úteis. Porém, muitas vezes esses sinais externos são assíncronos com o *clock* do FPGA.

O problema de sinais assíncronos é que podem violar os tempos de *setup* e *hold*.

Ninguém pode dizer quando alguém vai apertar o botão do elevador, e quando vai ter borda em relação ao *clock*. Também pode acontecer quando o sinal deveria estar estável.

O que acontece numa violação dos tempos de *setup* e *hold*? Nesse caso, a saída do flip-flop ficará **instável** por algum tempo **inderteminístico**, e depois cai em um dos estados.

### Sincronização de bits

Para evitar metaestabilidade, precisamos **sincronizar** o sinal assíncrono. Normalmente é feito através de dois flip-flops.

A entrada D do FF1 é assíncrona, então a saída Q do FF1 pode ficar meta-estável. Mas, se a metaestabilidade convergir dentro de um ciclo do *clock*, a saída Q do FF2 sempre fica estável. O preço é um **atraso de dois ciclos**.

Cada vez em que um sinal assíncrono é transferido para um sistema síncrono, precisamos de um sincronizador.

O sincronizador é fácil de escrever em VHDL. A entidade é

```vhdl
entity sycronizer is
    port(CLK, A: in  std_logic;
         B     : out std_logic
    );
end entity;
```

Nas declarações da arquitetura, definimos o atributo ```ASYNC_REG```, que manda o sintetizador **minimizar o caminho** entre dois flip-flops. Isso maximiza o tempo disponível para convergência da meta-estabilidade.

```vhdl
architecture rtl of syncronizer is
    signal M: std_logic_vector(1 downto 0) := "00";

    attribute ASYNC_REG: string;
    attribute ASYNC_REG of M: signal is "TRUE";
```

O código em si é

```vhdl
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            M <= M(0) & A;
        end if;
    end process;
    B <= M(1);
end architecture;
```

Onde podemos reconhecer um *delay line* de dois elementos, que então é implementado por flip-flops.

### Detecção de bordas

Para detectar bordas, precisamos comparar o sinal sincronizado com uma versão atrasada por um ciclo do *clock*. Dependendo da diferença, podemos detectar uma borda qualquer, positiva ou negativa.

É importante usar depois de um sincronizador, porque senão a saída pode ficar ligada só por um tempo muito curto, caso a borda chegar perto do *clock*.

Além de ser assíncrono, sinais feitos através de chaves tem um comportamento ruim. Precisamos evitar interpretar como se fosse mais que uma borda.

Esse processamento, chamado *debounce*, consiste em descartar pulsos que chegam dentro de um certo tempo de espera. Podemos fazer usando uma máquina de estados.

Agora, só transfere uma borda positiva quando esteja estável por algum tempo.

### Sincronização de múltiplos sinais

Quando precisa sincronizar múltiplos sinais relacionados, não é suficiente colocar um sincronizador em cada sinal, porque diferenças pequenas no tempo de propagação podem causar sincronização em *clocks* diferentes.

Para evitar receber valores misturados podemos definir um novo **sinal de sincronização**. Só na borda desse sinal fazemos a captura dos sinais a serem sincronizados.

Podemos definir todo o circuito em uma entidade simples:

```vhdl
entity sync_vector is
    port (CLK, SYNC: in  std_logic;
          A        : in  std_logic_vector;
          B        : out std_logic_vector
    );
end entity;
architecture rtl of sync_vector is
    sinal M: std_logic_vector(1 downto 0) := "00";
    
    attribute ASYNC_REG: string;
    attribute ASYNC_REG of M: signal is "TRUE";
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            if M(1) = '0' and M(0) = '1' then
                B <= A;
            end if;
            M <= M(0) & SYNC;
        end if;
    end process;
end architecture;
```

## Sinais internos

### Domínios de clock

Não só sinais externos podem chegar assincronamente. Também pode ter clocks diferentes dentro do mesmo FPGA. Isso pode acontecer quando tem uma entidade com um tempo de propagação diferente que uma outra entidade, e você não quer reduzir o clock global para acomodar a entidade mais lenta.

Todas as entidades que usam o mesmo sinal de clock ficam num **domínio de clock**. Uma ligação entre dois domínios de clock diferentes é chamada um *clock domain crossing*, e deve ser sincronizada. A sincronização pode ser a mesma que a para sinais externos.

No caso de clocks diferentes, mas **derivados de um único clock mestre**, podemos resolver o problema através de *buffering*:

1. Evitar lógica combinacional depois o último flip-flop da entidade que manda o sinal;
2. Evitar lógica combinacional antes do primeiro flip-flop da entidade que recebe o sinal.

Assim, existe um caminho sem atraso entre as entidades, que então sempre cumpre as exigências do clock mestre: **qualquer borda de um clock necessariamente deve acontecer numa borda do clock mestre**.

### Protocolos

Em todos os casos anteriores, existe a possibilidade de **perder informação**, se o sinal a ser sincroniazdo tem frequência maior que o clock de destino.

Efetivamente, estende o tempo de setup do flip-flop do destino pelo período do clock dele: a entrada deve ficar estável por pelo menos o período do clodk do destino.

Para a transmissão de pulsos curtos, é usado um sistema que transforma os pulsos em mudanças de nível, e dpeois reconverte. Com clocks assíncronos também precisa de um sincronizador.

O código do alternador é bem simples:

```vhdl
entity alternator is
    port (CLK, A: in  std_logic;
        B     : out std_logic
    );
end entity;
architecture rtl of alternator is
    signal M: std_logic := '0';
begin
    process (CLK) is
    begin
        if rising_edge(CLK) then
            if A = '1' then
                M <= not M;
            end if;
        end if;
    end process;
    B <= M;
end architecture;
```

Ainda existe a possibilidade de perda de dados, caso tenha mais que um pulso por ciclo do clock de destino. Isso precisa de um **protocolo** que gerencia a transmissão. Normalmente é implementado usando máquinas de estados e sinais de ```REQuest``` e ```ACKnowledge```.

Um protocolo comum é o de 4 fases, em que o transmissor afirma ```REQ``` quando tem dados para mandar, o receptor afirma ```ACK``` quando leu, e desafirma ```ACK``` quando está pronto para receber dados novos.

## Comunicação Serial

Para poupar fios e pinos, muitas vezes a comunicação entre CIs é feita através de **comunicação serial**. Quer dizer: ao invés de mandar *N* bits ao mesmo tempo, manda 1 bit por vez, *N* vezes. Existem duas classes desse tipo de comunicação:

* **Comunicação síncrona:** Cada bit é indicado por uma borda de clock. Exemplos: SPI, I2C.

* **Comunicação assíncrona:** Cada bit fica estável por um tempo fixo. Exemplos: Asynchronous start-stop, RS232, USB.

### Comunicação serial síncrona

Em comunicação serial síncrona, geralmente um mestre gera o clock do sinal, e existe um canal separado para os dados.

Geralmente, o bit menos significativo é mandado primeiramente, mas depende do protocolo. Existem tempos de setup e hold para cada borda do clock.

O *Serial Peripheral Interface* é um protocolo serial muito usado para comunicação entre CIs. Consiste em quatro fios:

* ```SCLK```: Serial Clock
* ```MOSI```: Master Out Slave In: dados transmitidos pelo mestre;
* ```MISO```: Master In Slave Out: dados transmitidos pelo outro dispositivo;
* ```-SS```: seleção do dispositivo (caso tenha mais que um no barramento);

Quando o mestre quer comunicar, seleciona o dispositivo usando ```-SS``` e gera um pulso do clock para cada bit a ser transmitido. Em cada borda positiva do clock, o mestre transmite um bit no ```MOSI``` e recebe um bit no ```MISO```.

Implementando o mestre de SPI em VHDL:

O ```SCLK``` é gerado através de um divisor de clock. Nas bordas positivas, um bit é lido, e nas bordas negativas o novo bit é montado. Cada pulso do ```VI```, uma nova palavra é transmitida e recebida, e depois ```VO``` é pulsado. Entre os pulsos de ```VI``` e ```VO```, ```EN``` é afirmado para habilitar o ```SCLK```.

Podemos implementar o protocolo usando uma máquina de estados. Nesse caso, uma máquina de Mealy, mas existem várias opções:

```vhdl
-- ESTADO: "init"
--     SAIDA: CNT <= 0
--     TRANSICAO PARA "sync": SCLK = '1'

-- ESTADO: "sync"
--     SAIDA: -
--     TRANSICAO PARA "setup": SCLK = '0' / MOSI <= MOUT(CNT)

-- ESTADO: "setup"
--     SAIDA: EN <= '1'
--     TRANSICAO PARA "nextBit": SCLK = '1' / MIN(CNT) <= MISO

-- ESTADO: "nextBit"
--     SAIDA: -
--     TRANSICAO PARA "sync": CNT < 7 / CNT <= CNT + 1
--     TRANSICAO PARA "idle": CNT = 7 and SCLK = '0' / VO <= '1'

-- ESTADO: "idle":
--     SAIDA: VO <= '0', EN <= '0'
--     TRANSICAO PARA "init": VI = '1' / MOUT <= DIN

entity spi_driver is
    port (
        CLK, SCLK, MISO: in  std_logic;
        MOSI, EN       : out std_logic;
        DIN            : in  std_logic_vector(7 downto 0);
        VI             : in  std_logic;
        DOUT           : out std_logic_vector(7 downto 0);
        VO             : out std_logic
    );
end entity;
architecture rtl of spi_driver is 
    type StateT is (Idle, Init, Sync, Setup, NextBit);
    signal state: StateT := Idle;

    signal MIN, MOUT: std_logic_vector(7 downto 0);
    signal CNT: integer range 0 to 7;
begin
    process(CLK) is
    begin
        if rising_edge(CLK) then
            case state is
                when Idle =>
                    VO <= '0';
                    EN <= '0';
                    if VI = '1' then
                        MOUT <= DIN;
                        state <= Init;
                    end if;
                when Init =>
                    CNT <= 0;
                    if SCLK = '1' then
                        state <= Sync;
                    end if;
                when Sync =>
                    if SCLK = '0' then
                        MOSI <= MOUT(CNT);
                        state <= Setup;
                    end if;
                when Setup =>
                    EN <= '1';
                    if SCLK = '1' then
                        MIN(CNT) <= MISO;
                        state <= NextBit;
                    end if;
                when NextBit =>
                    if CNT = 7 and SCLK = '0' then
                        VO <= '1';
                        state <= Idle;
                    elsif CNT < 7 then
                        CNT <= CNT + 1;
                        state <= Sync;
                    end if;
            end case;
        end if;
    end process;
    DOUT <= MIN;
end architecture;
```

No pulso de ```VI``` , o *driver* habilita o ```SCLK``` e espera as bordas negativas para montar ```MOSI```. Depois o último bit (CNT=111), pulsa ```VO``` e volta para o estado ```Idle```.

Um segundo protocolo síncrono é I2C. Usa só dois fios, `SCL` e `SDA`. A comunicação entãp é *half duplex*: só um dispositivo pode transmitir dados ao mesmo tempo.

O início da comunicação é indicado pela condição `START`: uma borda negativa no `SDA` com `SCL` alto. A condição `STOP` é uma borda positiva no `SDA` com `SCL` alto. Isso significa que durante a comunicação em si `SDA` só pode mudar quando `SCL`está baixo.

### Comunicação serial assíncrona

Podemos diminuir ainda mais a quantidade de fios, tirando o clock. Nesse caso, é usado um tempo predeterminado por bit *Tbit*. Porque a comunicação pode começar a qualquer momento, o receptor usa a condição `START` para sincronizar o contador.

Porque não existe clock, e é impossível distinuguir uma sequência longa de '1's do fim da palavra, então os dispositivos tem que usar a mesma composição da palavra. Existem várias opções, usando o padrão:

```text
    <Quantidade de data bits><Paridade><Quantidade de stop bits>
```

Exemplos comuns são (sempre tem 1 start bit):

* `8N1`: 8 databits, sem paridade, 1 stop bit;
* `7E1`: 7 databits, 1 bit de paridade par (#'1' mod 2), 1 stop bit;
* `7E2`: 7 databits, 1 bit de paridade par, 2 stop bits.

O mais comum (99% dos casos) é `8N1`.

Exemplo para comunicação assíncrona:

```vhdl
-- ESTADO: "idle"
--     SAIDA: CNT <= 0, RESET <= 0, VO <= '0'
--     TRANSICAO PARA "start": RX = '0'

-- ESTADO: "start"
--     SAIDA: RESET <= '0'
--     TRANSICAO PARA "waitBit": HALF_BIT = '1' / RESET <= '1'

-- ESTADO: "waitBit"
--     SAIDA: RESET <= '0'
--     TRANSICAO PARA "nextBit": FULL_BIT = '1' / RESET <= '1', DATA(CNT) <= RX

-- ESTADO: "nextBit"
--     SAIDA: RESET <= '0'
--     TRANSICAO PARA "waitBit": CNT < 7 / CNT <= CNT + 1
--     TRANSICAO PARA "stop": CNT = 7 / RESET <= '1'

-- ESTADO: "stop":
--     SAIDA: RESET <= '0'
--     TRANSICAO PARA "idle": FULL_BIT = '1' / VO <= '1' 

entity async_rx is
    port (
        CLK, RX: in  std_logic;
        DOUT   : out std_logic_vector (7 downto 0);
        VO     : out std_logic
    );
end entity;
architecture rtl of async_rx is
    type StateT is (Idle,Start,WaitBit,NextBit,Stop);
    constant FULL_BIT_CLOCKS: integer := 434;
    signal state: StateT := Idle;
    signal MIN: std_logic_vector(7 downto 0);
    signal CNT: integer range 0 to 7 := 0;
    signal RESET: std_logic := '0';
    signal CLK_DIV: integer range 0 to FULL_BIT_CLOCKS;
    signal HALF_BIT, FULL_BIT: std_logic := '0';
begin
    DOUT <= MIN;
    process(RESET, CLK) is
    begin
        if RESET = '1' then
            CLK_DIV <= 0;
        elsif rising_edge(CLK) and CLK_DIV < FULL_BIT_CLOCKS then
            CLK_DIV <= CLK_DIV + 1;
        end if;
    end process;
    HALF_BIT <= '1' when CLK_DIV >= FULL_BIT_CLOCKS/2
                    else '0';
    FULL_BIT <= '1' when CLK_DIV >= FULL_BIT_CLOCKS
                    else '0';

    process(CLK) is
    begin
        if rising_edge(CLK) then
            case state is
                when Idle =>
                    CNT <= 0;
                    RESET <= '1';
                    VO <= '0';
                    if RX = '0' then
                        state <= Start;
                    end if;
                when Start =>
                    RESET <= '0';
                    if HALF_BIT = '1' then
                        RESET <= '1';
                        state <= WaitBit;
                    end if;
                when WaitBit =>
                    RESET <= '0';
                    if FULL_BIT = '1' then
                        RESET <= '1';
                        MIN(CNT) <= RX;
                        state <= NextBit;
                    end if;
                when NextBit =>
                    RESET <= '0';
                    if CNT = 7 then
                        state <= Stop;
                    else
                        CNT <= CNT + 1;
                        state <= WaitBit;
                    end if;
                when Stop =>
                    RESET <= '0';
                    if FULL_BIT = '1' then
                        VO <= '1';
                        state <= Idle;
                    end if;
            end case;
        end if;
    end process;
end architecture;
```

Depois da descida do `RX`, a máquina aguarda meio bit, para amostrar no meio dos bits. Depois o start bit, aguarda 8 data bits e o stop bit.

AVISO: Em um sistema real, também teria vários casos para reconhecer erros, por exemplo quando ler um start bit que não é '0', ou um stop bit que não é '1' (framing error).

Um protocolo assíncrono muito comum é o RS232, desenvolvido para a comunicação entre um terminal (DTE) e um modem (DCE). Especifica as tensões dos níveis lógicos (`1` entre -3V e -15V, `0` entre 3V e 15V), e mais alguns sinais. Os mais importantes hoje em dia são:

* **RST** *Ready to Send*: indica que o DTE pode receber dados;
* **CTS** *Clear to Send*: indica que o DCE pode receber dados

em sistenas que não ligam terminal com modem, então precisa definir quem é DCE e DTE, ou usar um cabo *null-modem* que troca os sinais, assim possibilitando os dois dispositivos se comportarem como DTEs.