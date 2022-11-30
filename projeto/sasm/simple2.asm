; reset vector
     .org 0x00
      jmp @main

; start of text
      .org 0x20

main: 
      ldi  r0, 0x01
      ldi  r1, 0x00
      ; preparando endereco de store (display7seg)
      ldi  r3, 0x18

; fibonnaci usando pilha
loop: push r0
      add r0, r1
      pop r1
      st  r0, [r3]
      jmp @loop 
