; Enum to define SID control flags
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

.enum sid_filter_flags
    FILTER_VOICE1  = $01
    FILTER_VOICE2  = $02
    FILTER_VOICE3  = $04
    FILTER_EXTERNAL= $08
.endenum

.enum sid_filter_modes
    FILTER_LOW_PASS    = $10
    FILTER_BAND_PASS   = $20
    FILTER_HIGH_PASS   = $40
    FILTER_MUTE_VOICE3 = $80
.endenum

; Structure definition for a SID voice
.struct sid_voice
    freq            .word   ; 16-bit Frequency
    pulse_width     .word   ; 12-bit Pulse Width
    ctrl            .byte   ; Control flags
    attack          .byte   ; 4-bit attack rate
    decay           .byte   ; 4-bit decay rate  
    sustain         .byte   ; 4-bit sustain level 
    release         .byte   ; 4-bit release rate
.endstruct  

.struct sid_general
    filter_cutoff   .word   ; 12-bit cutoff frequency
    filter_res      .byte   ; 4-bit resonance
    filter_flag     .byte   ; filter routing flags
    filter_mode     .byte   ; filter mode flags
    volume          .byte   ; master volume (4 bits)    
.endstruct

; Set or clear reverse video based on current cursor position
; Usage:
;   cur_col: Current column to compare against
;   cur_row: Current row to compare against
; Returns:
;   Nothing
; Results:
;   PETSCII reverse on if cursor matches, off otherwise
; Destroys:
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

; Jump to a target if the accumulator matches a character
; Usage:
;   char:   Character to compare against
;   target: Target label to jump to if match
; Returns:
;   Nothing
; Results:
;   JMP to target if match
; Destroys:
;   Nothing
.macro goto_if_char char, target 
    cmp #char
    beq target
.endmacro

; Call a subroutine if the accumulator matches a character
; Usage:
;   char:   Character to compare against
;   target: Target subroutine to call if match
; Returns:
;   Nothing
; Results:
;   JSR to target if match
.macro gosub_if_char char, target 
    cmp #char
    bne :+
    jsr target
:    
.endmacro

; Add a constant to a 16-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to add
;   mask:  Mask to apply after addition
; Results:
;   16-bit value at structure offset incremented by constant and masked
; Destroys:
;   A, Y
.macro add_const_to_struct_16 ptr, ofs, value, mask
    clc
    ldy #ofs
    lda (ptr), y
    adc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    adc #.hibyte(value)    
    and #.hibyte(mask)
    sta (ptr), y
.endmacro

; Subtract a constant from a 16-bit value in a structure
; Usage:
;   ptr:   Pointer to structure
;   ofs:   Offset within structure
;   value: Constant to subtract
;   mask:  Mask to apply after subtraction
; Results:
;   16-bit value at structure offset decremented by constant and masked
; Destroys:
;   A, Y
.macro sub_const_from_struct_16 ptr, ofs, value, mask
    sec
    ldy #ofs
    lda (ptr), y
    sbc #.lobyte(value)
    and #.lobyte(mask)
    sta (ptr), y
    ldy #ofs+1
    lda (ptr), y
    sbc #.hibyte(value)    
    and #.hibyte(mask)
    sta (ptr), y
.endmacro
