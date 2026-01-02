.scope
.define current_file "main.s"

.include "mac.inc"
.include "main.inc"
.include "print.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Define exports for all public functions in this module

.proc main: near

    scnclr
    jsr init_voices
    jsr display_template

    ldx #<voice1
    ldy #>voice1
    jsr convert_16bitptr_to_decimal
    
    rts

.endproc

.proc display_template : near
    
    printat 0, 1, str_freq
    printat 0, 2, str_pulse
    printat 0, 3, str_ctrl
    printat 0, 4, str_atk
    printat 0, 5, str_dec
    printat 0, 6, str_sus
    printat 0, 7, str_rel

    rts
.endproc

.proc init_voices : near
    ; Initialize voice 1
    ldx #<voice1
    ldy #>voice1
    jsr init_voice

    ; Initialize voice 2
    ldx #<voice2
    ldy #>voice2
    jsr init_voice

    ; Initialize voice 3    
    ldx #<voice3
    ldy #>voice3
    jsr init_voice

    rts
.endproc

.proc init_voice : near

    ; Store Pointer to voice structure in PTR1
    stx PTR1
    sty PTR1+1  

    ; Initialize voice structure to zero
    ldy #$00
    lda #123
    init_voice_loop:
        sta (PTR1), y           
        iny
        cpy #.sizeof(sid_voice)
        bne init_voice_loop       
    rts
.endproc

.proc display_data :near
    ; Placeholder for future data display routines
    rts
.endproc

; PETSCII strings for the template
str_atk:   .asciiz "ATK : "
str_ctrl:  .asciiz "CTRL: "
str_dec:   .asciiz "DEC : "
str_freq:  .asciiz "FREQ: "
str_pulse: .asciiz "PLS : "
str_rel:   .asciiz "REL : "
str_sus:   .asciiz "SUS : "

; Global variables
voice1: .res .sizeof(sid_voice) ; Reserve space for first SID voice structure
voice2: .res .sizeof(sid_voice) ; Reserve space for second SID voice structure
voice3: .res .sizeof(sid_voice) ; Reserve space for third SID voice structure

.endscope