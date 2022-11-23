      .org 0x00
      jmp @main

      .org 0x20
main: ldi  r0, 0x01
      ldi  r1, 0x00
      ldi  r3, 0x32


loop: mov  r2, r0
      add  r0, r1
      mov  r1, r2
      st   r0, [r3]
      jmp  @loop
