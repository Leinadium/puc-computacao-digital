# Projeto Final

## Instruções


**Acesso de memória**:

```asm
ldi     Rd, N       ; Rd <-- MEM[pc+1],                     pc <--  pc + 2
ld      Rd, [Rr]    ; Rd <-- MEM[Rr],                       pc <--  pc + 1
st      Rd, [Rr]    ; MEM[Rr] <-- Rd,                       pc <--  pc + 1
push    Rd          ; MEM[sp] <-- Rd,       sp <-- sp - 1   pc <--  pc + 1
pop     Rd          ; Rd <-- MEM[sp + 1],   sp <-- sp + 1   pc <--  pc + 1
```

**Aritmética**:

```asm
mov     Rd, Rr  ; Rd ← Rr,              pc ← pc + 1
inc     Rd      ; Rd ← Rd + 1,          pc ← pc + 1
dec     Rd      ; Rd ← Rd - 1,          pc ← pc + 1
incc    Rd      ; Rd ← Rd + carry,      pc ← pc + 1
decb    Rd      ; Rd ← Rd + carry - 1,  pc ← pc + 1
add     Rd, Rr  ; Rd ← Rd + Rr,         pc ← pc + 1
sub     Rd, Rr  ; Rd ← Rd - Rr,         pc ← pc + 1
cp      Rd, Rr  ; Rd - Rr,              pc ← pc + 1
neg     Rd      ; Rd ← -Rd,             pc ← pc + 1
```

**logica**:

```asm
not     Rd      ; Rd ← ~Rd,                             pc ← pc + 1
and     Rd, Rr  ; Rd ← Rd & Rr,                         pc ← pc + 1
or      Rd, Rr  ; Rd ← Rd | Rr,                         pc ← pc + 1
xor     Rd, Rr  ; Rd ← Rd ^ Rr,                         pc ← pc + 1
tst     Rd, Rr  ; Rd & Rr,                              pc ← pc + 1
lsl     Rd      ; Rd ← Rd<6..0>#0,      carry ← Rd<7>,  pc ← pc + 1
lsr     Rd      ; Rd ← 0#Rd<7..1>,      carry ← Rd<0>,  pc ← pc + 1
rol     Rd      ; Rd ← Rd<6..0>#carry,  carry ← Rd<7>,  pc ← pc + 1
ror     Rd      ; Rd ← carry#Rd<7..1>,  carry ← Rd<0>,  pc ← pc + 1
```

**saltos:**

```asm
ijmp Rd ; pc ← Rd
jmp N   ; pc ← MEM[pc+1]
brz N   ; if ( zero)  pc ← MEM[pc+1] else pc ← pc + 2
brnz N  ; if (! zero) pc ← MEM[pc+1] else pc ← pc + 2
brcs N  ; if ( carry) pc ← MEM[pc+1] else pc ← pc + 2
brcc N  ; if (!carry) pc ← MEM[pc+1] else pc ← pc + 2
```

## Opcodes

| Instrução | Opcode | Operando |
|-----------|--------|---------:|
| `ldi`     | 0000   | Rd00     |
| `push`    | 0000   | Rd01     |
| `pop`     | 0000   | Rd10     |
| `ld`      | 0001   | RdRr     |
| `st`      | 0010   | RdRr     |
| `mov`     | 0011   | RdRr     |
| `inc`     | 0100   | Rd00     |
| `dec`     | 0100   | Rd01     |
| `incc`    | 0100   | Rd10     |
| `decb`    | 0100   | Rd11     |
| `add`     | 0101   | RdRr     |
| `sub`     | 0110   | RdRr     |
| `cp`      | 0111   | RdRr     |
| `neq`     | 1000   | Rd00     |
| `not`     | 1000   | Rd01     |
| `and`     | 1001   | RdRr     |
| `or`      | 1010   | RdRr     |
| `xor`     | 1011   | RdRr     |
| `tst`     | 1100   | RdRr     |
| `lsl`     | 1101   | Rd00     |
| `lsr`     | 1101   | Rd01     |
| `rol`     | 1101   | Rd10     |
| `ror`     | 1101   | Rd11     |
| `ijmp`    | 1110   | Rd00     |
| `jmp`     | 1111   | 0000     |
| `brz`     | 1111   | 0001     |
| `brnz`    | 1111   | 0010     |
| `brcs`    | 1111   | 0011     |
| `brcc`    | 1111   | 0100     |

## Organização da memória

O processador começa a executar a instrução no endereço `0x00`.
Porém na memória ficam primeiramente o *interrupt vector table* e a memóai de entrada/saída.
No endereço `0x00` (*reset vector*) então precisa ter um **jmp** para o ínicio do programa.

| Endereço | Uso                                        |
|----------|--------------------------------------------|
| `0x00`   | Reset Vector (`jmp @main`)                 |
| `0x14`   | Último caracter lido do teclado PS/2       |
| `0x18`   | Valor mostrado no *display* de 7 segmentos |
| `0x19`   | Caractere a ser mandado para o LCD         |
| `0x1A`   | Comando a ser mandado para o LCD           |
| `0xff`   | Início da pilha                            |

O registro do teclado volta para 0 ao ler o valor. Os registros do LCD voltam para 0 ao terminar de mandar.