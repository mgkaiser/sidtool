.if !.xmatch(current_file, "print.s")
    .import gotoxy: near
    .import print: near   
    .import convert_16bit_to_decimal: near     
    .import convert_16bitptr_to_decimal: near
.endif

.macro printat y_pos, x_pos, str_addr
    ldx #x_pos
    ldy #y_pos
    jsr gotoxy
    ldx #<str_addr
    ldy #>str_addr
    jsr print
.endmacro

.macro scnclr
    lda #$93          ; Clear screen code
    jsr $FFD2         ; C64 KERNAL CHROUT routine   
.endmacro
