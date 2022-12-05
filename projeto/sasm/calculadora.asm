.include "constantes.asm"

.org 0x0
    jmp @main

.org 0x20

;; OBS: todas as "funcoes" modificam r3
;; as funcoes esperam o endereco para retorno na pilha
;; 
;; escreve_lcd e escreve_lcd_comando espera um argumento em r0
;; get_tecla retorna o valor em r0

;;;; FUNCOES ;;;;

escreve_lcd:    ;; pega de r0
    push r0  ;; salva para usar depois
escreve_lcd_loop:
    ldi  r3, @MEM_LCD_CARACTER
    ;; precisa esperar estar livre o local
    ld   r0, [r3]
    mov  r0, r0
    brnz @escreve_lcd_loop
    ;; agora sim, escreve
    pop  r0
    st   r0, [r3]
    pop  r3      ;; return
    ijmp r3

escreve_lcd_comando:    ;; pega de r0
    push r0  ;; salva para usar depois
escreve_lcd_comando_loop:
    ldi  r3, @MEM_LCD_COMANDO
    ;; precisa esperar estar livre o local
    ld   r0, [r3]
    mov  r0, r0
    brnz @escreve_lcd_comando_loop
    ;; agora sim, escreve
    pop  r0
    st   r0, [r3]
    pop  r3      ;; return
    ijmp r3

get_tecla:
    ldi  r3, @MEM_TECLADO ; pega o end de @teclado
get_tecla_loop:
    ld   r0, [r3]  ; Get character from keyboard
    mov  r0, r0           ; config a flag
    brz  @get_tecla_loop  ; repete se nao tiver nada
    ;; imprime no 7seg o que chegou
    ldi  r3, @MEM_SEG
    st   r0, [r3]  
    ;; chama funcao de imprimir no lcd
    ;; endereco de retorno eh o proprio dessa
    ;; mesma funcao, entao nao precisa
    ;; fazer um pop para depois fazer um push
    jmp  @escreve_lcd


get_tecla_sem_lcd:
    ldi  r3, @MEM_TECLADO
get_tecla_sem_lcd_loop:
    ld   r0, [r3]
    mov  r0, r0
    brz  @get_tecla_sem_lcd_loop
    pop  r3
    ijmp r3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; INICIO ;;;;
main:
    ;; limpa o lcd ;;
    ldi  r0, 0x01  ; comando de clear
    ldi  r3, @primeira_tecla
    push r3
    jmp @escreve_lcd_comando
;;;;;;;;;;;;;;;;

;;;; PARSING DAS TECLAS ;;;;
primeira_tecla:
    ;; espera a primeira tecla ;;
    ldi  r3, @segunda_tecla
    push r3
    jmp  @get_tecla   ;; armazena a primeira tecla em r0
segunda_tecla:
    mov  r2, r0       ;; coloca o primeiro digito em r2
    ;; espera a segunda tecla ;;
    ldi  r3, @terceira_tecla
    push r3
    jmp  @get_tecla
terceira_tecla:
    mov  r1, r0       ;; coloca a operacao em r1
    ;; espera a terceira tecla ;;
    ldi  r3, @imprimir_igual
    push r3
    jmp  @get_tecla

imprimir_igual:
    push r0   ;; salva o primeiro valor
    ldi  r0, @ASCII_IGUAL
    ldi  r3, @executar_operacao
    push r3
    jmp  @escreve_lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; OPERACOES DA CALCULADORA ;;;;
executar_operacao:
    pop  r0
    ;; primeiro digito em r2
    ;; operacao em r1
    ;; segundo digito em r0 (do terceira tecla)

    ;; convertendo r0 e r2
    ldi  r3, @ASCII_0
    sub  r0, r3
    sub  r2, r3
    ;; fazendo soma
    ldi  r3, @ASCII_MAIS
    cp   r1, r3
    brz  @operacao_soma
    ;; fazendo subtracao
    ldi  r3, @ASCII_MENOS
    cp   r1, r3
    brz  @operacao_subtracao

    ;; se nao deu certo, invalido
    jmp @invalido
operacao_soma:
    add r2, r0
    mov r0, r2
    jmp @resultado
operacao_subtracao:
    sub r2, r0
    mov r0, r2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; IMPRIMINDO O RESULTADO ;;;;
resultado:
    ;; valor esta em r0
    ;; se tiver dois digitos, imprime o primeiro
    ldi r3, 0x0A
    cp  r0, r3
    brcs @resultado_ultimo_digito  ;; pula se deu underflow

resultado_primeiro_digito:
    push r0   ;; salva o resultado para nao perder
    ldi  r0, @ASCII_1
    ldi  r3, @pos_resultado_primeiro_digito
    push r3
    jmp  @escreve_lcd

pos_resultado_primeiro_digito:
    pop  r0    ;; restaura r0 do print acima
    ldi  r3, 0x0A
    sub  r0, r3

resultado_ultimo_digito:
    ;; colocando o valor ASCII do numero
    ldi  r3, @ASCII_0
    add r0, r3
    ;; imprimindo o digito
    ldi  r3, @final
    push r3
    jmp  @escreve_lcd
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; CODIGO INVALIDO ;;;;
invalido:
    ;; imprimindo uma interrogacao
    ldi  r0, @ASCII_ERRO
    ldi  r3, @final
    push r3
    jmp  @escreve_lcd
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; FINAL ;;;;
final:
    ;; espera a tecla BACKSPACE
    ldi  r3, @final_tecla
    push r3
    jmp  @get_tecla_sem_lcd   ;; armazena a tecla em r0
final_tecla:
    ldi  r3, @ASCII_BACK
    cp   r0, r3
    brz  @main
    jmp  @final
;;;;;;;;;;;;;;;