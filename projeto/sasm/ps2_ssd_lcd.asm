      .equ kdr, 0x14 ; Keyboard data register
      .equ ssd, 0x18 ; 7-segment display register
      .equ lcd, 0x19 ; caracter lcd

; Reset vector (jumps over memory-mapped I/O)
      .org 0x0
      jmp @main

; Start of text
      .org 0x20

; Setup
main:  ldi  r3, @kdr  ; r3 = keyboard data register
       ldi  r2, @ssd  ; r2 = 7-segment display register
       ldi  r1, @lcd  ; r1 = caracter lcd

; Main loop
wkbd:  ld   r0, [r3]  ; Get character from keyboard
       mov  r0, r0    ; Update flags
       brz  @wkbd     ; Wait until nonzero
       st   r0, [r2]  ; Write to SSD
       st   r0, [r1]  ; escreve no lcd o ascii que chegou (sem tratar :0)
       jmp  @wkbd     ; Wait for next character
