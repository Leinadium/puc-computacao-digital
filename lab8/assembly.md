# Assembly

Set de instruções:

```assembly
clr Rd      ; Rd <-- 0
set Rd      ; Rd <-- 1
add Rd, Rr  ; Rd <-- Rd + Rr
jmp imm     ; pc <-- imm
```

Função para calcular a sequencia de Fibonacci

```assembly
set r0
clr r1

loop:
    clr r2          ;
    add r2, r0      ; r2 = r0
    add r0, r1      ; r0 += r1
    clr r1          ;
    add r1, r2      ; r1 = r2

    jmp @loop
```
