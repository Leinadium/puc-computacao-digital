      .org 0x00
      jmp @main

      .org 0x20
main: ldi  r0, 0
loop: inc  r0
      jmp  @loop
