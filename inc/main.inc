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