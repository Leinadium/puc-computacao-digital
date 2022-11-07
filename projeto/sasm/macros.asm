; Example Macros for ENG1448 processor

; Write character to 7-segment display
; INPUT : Character to write in $0 (cannot be r3)
; OUTPUT: None
      .macro writessd
      push r3        ; Save auxiliary register
      ldi  r3, @ssd  ; 
      st   $0, [r3]  ; Write argument to display
      pop  r3        ; Restore auxiliary register
      .endmacro

; Wait for keyboard character.
; INPUT : None
; OUTPUT: Keyboard character in $0 (cannot be r3)
       .macro waitkb
       push r3       ; Save auxiliary register
       ldi  r3, @kdr ; 
Lwait: ld   $0, [r3] ; Read keyboard character
       mov  $0, $0   ; Set flags
       brz  @Lwait   ; Wait until nonzero
       pop  r3       ; Restore auxiliary register
       .endmacro
