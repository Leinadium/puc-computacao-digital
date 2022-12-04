; Macros para a calculadora

.include "constantes.asm"


.macro escreve_seg
; write_seg(r): Escreve o digito no 7-Seg
; Args:
;   r: rX com o numero a ser escrito
; Returna:
;   None
; Restricoes:
    r nao pode ser r3
;;;;;;;;;;;;;
    push r3        ; prepara r3
    ldi  r3, @MEM_SEG  ; pega o end de @seg
    st   $0, [r3]  ; escreve em @seg
    pop  r3        ; restaura r3
    .endmacro
;;;;;;;;;;;;;


.macro get_tecla
; get_tecla(r): Pega tecla do teclado. Blocking
; Args:
;   None
; Retorna:
;   r: rX com codigo ASCII da tecla
; Restricoes:
;   r nao pode ser r3
;;;;;;;;;;;;;
    push r3               ; prepara r3
    ldi  r3, @MEM_TECLADO ; pega o end de @teclado
get_tecla_loop:
    ld   $0, [r3]  ; Get character from keyboard
    mov  $0, $0           ; config a flag
    brz  @get_tecla_loop  ; repete se nao tiver nada
    pop  r3               ; restaura r3
    .endmacro
;;;;;;;;;;;;;


.macro escreve_lcd
; escreve_led(r): Escreve o ASCII no teclado
; Args:
;   r: rX com o codigo ASCII da tecla
; Retorna:
;   None
; Restricoes:
;   r nao pode ser r3 ou r2
;;;;;;;;;;;;;
    push r3        ; prepara r3
    ldi  r3, @MEM_LCD_CARACTER  ; pega o end de @caracter
    st   $0, [r3]  ; escreve em @seg
    pop  r3        ; restaura r3
    .endmacro
;;;;;;;;;;;;;


.macro limpa_lcd
; limpa_tela(): Limpa a tela do lcd
; Args:
;   None
; Retorna:
;   None
; Restricoes:
;   None
;;;;;;;;;;;;;
    push r3        ; prepara r3
    push r2        ; prepara r2
    ldi  r3, @MEM_LCD_COMANDO  ; pega o end de @caracter
    ldi  r2, 0x01  ; comando de clear
    st   r2, [r3]  ; escreve em @seg
    pop  r2        ; restaura r2
    pop  r3        ; restaura r3
    .endmacro
;;;;;;;;;;;;;