.enum sid_ctrl_flags    
    FLAG_NOISE      = $80
    FLAG_PULSE      = $40        
    FLAG_SAWTOOTH   = $20
    FLAG_TRIANGLE   = $10
    FLAG_TEST       = $08    
    FLAG_RINGMOD    = $04
    FLAG_SYNC       = $02
    FLAG_GATE       = $01
.endenum    

.struct sid_voice
    freq        .word    
    pulse_width .word
    ctrl        .byte    
    attack      .byte
    decay       .byte     
    sustain     .byte    
    release     .byte       
.endstruct  

.macro do_reverse cur_col, cur_row
    lda column
    cmp cur_col
    bne :+
    lda row
    cmp cur_row
    bne :+
    lda #PETSCII_REVERSE_ON
    jsr KERNAL_CHROUT
    jmp :++
:   lda #PETSCII_REVERSE_OFF
    jsr KERNAL_CHROUT
:
.endmacro

.macro goto_if_char char, target 
    cmp #char
    beq target
.endmacro

.macro gosub_if_char char, target 
    cmp #char
    bne :+
    jsr target
:    
.endmacro

.macro add_const_to_struct_16 ptr, ofs, value
    clc
    ldy #ofs
    lda (ptr), y
    adc #.lobyte(value)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    adc #.hibyte(value)    
    sta (ptr), y
.endmacro

.macro sub_const_from_struct_16 ptr, ofs, value
    sec
    ldy #ofs
    lda (ptr), y
    sbc #.lobyte(value)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    sbc #.hibyte(value)    
    sta (ptr), y
.endmacro
