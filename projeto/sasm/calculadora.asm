.include "constantes.asm"

.org 0x0
    jmp @main

.org 0x20


get_tecla:
    ldi  r3, @MEM_TECLADO ; pega o end de @teclado
get_tecla_loop:
    ld   r0, [r3]  ; Get character from keyboard
    mov  r0, r0           ; config a flag
    brz  @get_tecla_loop  ; repete se nao tiver nada
    ;; imprime no 7seg o que chegou
    ldi  r3, @MEM_SEG
    st   r0, [r3]
    ;; imprime no lcd o que chegou
    ldi  r3, @MEM_LCD_CARACTER
    st   r0, [r3]
    ;; retorna    
    pop  r3   ; return
    ijmp r3

get_tecla_sem_print:
    ldi  r3, @MEM_TECLADO ; pega o end de @teclado
get_tecla_sem_print_loop:
    ld   r0, [r3]  ; Get character from keyboard
    mov  r0, r0           ; config a flag
    brz  @get_tecla_sem_print_loop
    ;; retorna    
    pop  r3   ; return
    ijmp r3


main:
    ;; limpa o lcd ;;
    ldi  r3, @MEM_LCD_COMANDO  ; pega o end de @caracter
    ldi  r2, 0x01  ; comando de clear
    st   r2, [r3]  ; escreve em @seg

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
    ldi  r3, @espera_enter
    push r3
    jmp  @get_tecla
espera_enter:
    push r0
    ;; espera a tecla BACKSPACE
    ldi  r3, @espera_enter_tecla
    push r3
    jmp  @get_tecla_sem_print
espera_enter_tecla:
    ldi  r3, @ASCII_ENTER
    cp   r0, r3
    brz  @executar_operacao
    jmp  @espera_enter

executar_operacao:
    pop r0
    ;; primeiro digito em r2
    ;; operacao em r1
    ;; segundo digito em r0

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

resultado:
    ;; valor esta em r0
    ;; se tiver dois digitos, imprime o primeiro
    ldi r3, 0x0A
    cp  r0, r3
    brcc @resultado_ultimo_digito
    ;; imprimindo o primeiro dos digitos (so pode ser 1)
    ldi  r3, @MEM_LCD_CARACTER
    ldi  r2, @ASCII_1
    st   r2, [r3]
    ;; faz a subtracao para imprimir o segundo digito
    ldi  r3, 0x0A
    sub  r0, r3
resultado_ultimo_digito:
    ;; imprimindo o digito
    ldi  r3, @MEM_LCD_CARACTER
    st   r0, [r3]
    jmp @final

invalido:
    ;; imprimindo uma interrogacao
    ldi  r3, @MEM_LCD_CARACTER
    ldi  r2, @ASCII_ERRO
    st   r2, [r3]
    jmp @final

final:
    ;; espera a tecla BACKSPACE
    ldi  r3, @final_tecla
    push r3
    jmp  @get_tecla   ;; armazena a tecla em r0
final_tecla:
    ldi  r3, @ASCII_BACK
    cp   r0, r3
    brz  @main
    jmp  @final
