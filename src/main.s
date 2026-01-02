.scope
.define current_file "main.s"

.include "mac.inc"
.include "main.inc"
.include "print.inc"
.include "basicstub.inc"    ; ONLY include this in main.s.  MUST be last include

.segment "MAIN"

; Define exports for all public functions in this module

; Main program entry point
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Main program loop executed
; Destroys:
;   All registers
.proc main: near

    ; Make the background black and the text light green
    lda #VIC_COL_BLACK              ; Color value 
    sta VIC_BORDER_COL              ; Border color
    sta VIC_BG_COL                  ; Background color
    lda #PETSCII_COL_LIGHT_GREEN    ; Text color
    jsr KERNAL_CHROUT
    
    ; Clear the screen
    scnclr

    ; Init col and row
    lda #$00
    sta column
    lda #$01
    sta row

    ; Initialize SID voice structures
    jsr init_voices

    ; Display the template
    jsr display_template

main_loop:    

    ; Display the data
    jsr display_data

    ; Update the SID with the data

    ; Check keys and act upon them
    getkey
    goto_if_char 'Q', exit_program    
    gosub_if_char '+', process_plus1
    gosub_if_char '-', process_minus1
    gosub_if_char 219, process_plus10                   ; SHIFT +
    gosub_if_char 221, process_minus10                  ; SHIFT -
    gosub_if_char PETSCII_CURSOR_LEFT, process_left
    gosub_if_char PETSCII_CURSOR_RIGHT, process_right
    gosub_if_char PETSCII_CURSOR_UP, process_up
    gosub_if_char PETSCII_CURSOR_DOWN, process_down

    ; Loop if they didn't quit
    jmp main_loop

exit_program:        
    rts

.endproc

.proc process_plus1 : near
    
    ; Select the voice structure based on the column value
    lda column        
    bne :+
        lda #<voice1
        sta PTR1
        lda #>voice1
        sta PTR1+1                
        jmp selected_column
:   cmp #$01    
    bne :+
        lda #<voice2
        sta PTR1
        lda #>voice2
        sta PTR1+1        
        jmp selected_column
:   cmp #$02    
    bne :+
        lda #<voice3
        sta PTR1
        lda #>voice3
        sta PTR1+1
        jmp selected_column 

:   jmp exit_proc                   ; This should not happen        

selected_column:               

    ; Increment the value in the selected column
    lda row
    cmp #$01
    bne :+        
        add_const_to_struct_16 PTR1, sid_voice::freq, 1             ; Frequency
        jmp exit_proc
    
:   cmp #$02
    bne :+
        add_const_to_struct_16 PTR1, sid_voice::pulse_width, 1      ; Pulse Width
        jmp exit_proc

:   cmp #$03
    bne :+

        ; Control Register

:   cmp #$04
    bne :+

        ; Attack
    
:   cmp #$05
    bne :+

        ; Decay

:   cmp #$06   
    bne :+
    
        ; Sustain

:   cmp #$07
    bne exit_proc      ; This should not happen
        
        ; Release

exit_proc:
    rts
.endproc

.proc process_minus1 : near

    ; Select the voice structure based on the column value
    lda column        
    bne :+
        lda #<voice1
        sta PTR1
        lda #>voice1
        sta PTR1+1                
        jmp selected_column
:   cmp #$01    
    bne :+
        lda #<voice2
        sta PTR1
        lda #>voice2
        sta PTR1+1        
        jmp selected_column
:   cmp #$02    
    bne :+
        lda #<voice3
        sta PTR1
        lda #>voice3
        sta PTR1+1
        jmp selected_column 

:   jmp exit_proc                   ; This should not happen        

selected_column:      

    ; Increment the value in the selected column
    lda row
    cmp #$01
    bne :+
        sub_const_from_struct_16 PTR1, sid_voice::freq, 1           ; Frequency        
        jmp exit_proc
        
:   cmp #$02
    bne :+
        sub_const_from_struct_16 PTR1, sid_voice::pulse_width, 1    ; Pulse Width
        jmp exit_proc

:   cmp #$03
    bne :+

        ; Control Register

:   cmp #$04
    bne :+

        ; Attack
    
:   cmp #$05
    bne :+

        ; Decay

:   cmp #$06   
    bne :+
    
        ; Sustain

:   cmp #$07
    bne exit_proc      ; This should not happen
        
        ; Release

exit_proc:
    rts
.endproc

.proc process_plus10 : near
    ldx #$0a
loop:
    jsr process_plus1
    dex
    bne loop
    rts
.endproc

.proc process_minus10 : near        
    ldx #$0a
loop:
    jsr process_minus1
    dex
    bne loop
    rts
.endproc

.proc process_left : near

    ; column--
    sec
    lda column
    sbc #$01
    sta column

    ; Did we go below 0?
    cmp #$ff
    bne :+
        lda #$00
        sta column    

:   rts
.endproc

.proc process_right : near
    
    ; column++    
    clc
    lda column
    adc #$01
    sta column

    ; Did we go above 2?
    cmp #$03
    bne :+
        lda #$00
        sta column    

 :  rts
.endproc

.proc process_up : near

    ; row--
    sec
    lda row
    sbc #$01
    sta row

    ; Did we go below 1?
    cmp #$00
    bne :+
        lda #$07
        sta row     
    
:   rts
.endproc

.proc process_down : near

    ; row++
    clc
    lda row
    adc #$01
    sta row

    ; Did we go above 7?
    cmp #$08
    bne :+
        lda #$01
        sta row

:   rts
.endproc

; Display the template on the screen
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Template displayed on screen
; Destroys:
;   A, X, Y
.proc display_template : near
    
    printat #0, #1, str_freq
    printat #0, #2, str_pulse
    printat #0, #3, str_ctrl
    printat #0, #4, str_atk
    printat #0, #5, str_dec
    printat #0, #6, str_sus
    printat #0, #7, str_rel

    rts
.endproc

; Initialize all three SID voice structures to zero
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   All three voice structures initialized to zero
; Destroys:
;   PTR1, PTR+1, A, X, Y
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

; Initialize a SID voice structure to zero
; Usage:
;   x:y = pointer to sid_voice structure
; Returns:
;   Nothing
; Results:
;   Voice structure initialized to zero
; Destroys:
;   PTR1, PTR+1, A
.proc init_voice : near

    ; Store Pointer to voice structure in PTR1
    stx PTR1
    sty PTR1+1  

    ; Initialize voice structure to zero
    ldy #$00
    lda #$00
    init_voice_loop:
        sta (PTR1), y           
        iny
        cpy #.sizeof(sid_voice)
        bne init_voice_loop       
    rts
.endproc

; Display data for all three voices
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Data displayed on screen
.proc display_data :near    

    ; Display data for voice 1
    ldx #<voice1
    ldy #>voice1
    lda #$00
    sta TMP4
    lda #7                      ; Print voice 1 in column 7
    jsr display_data_one_voice

    ; Display data voice 2
    ldx #<voice2
    ldy #>voice2
    lda #$01
    sta TMP4
    lda #13                     ; Print voice 2 in column 13
    jsr display_data_one_voice

    ; Display data voice 3    
    ldx #<voice3
    ldy #>voice3
    lda #$02
    sta TMP4
    lda #19                     ; Print voice 3 in column 19    
    jsr display_data_one_voice

    rts
.endproc

; Display data for one voice
; Usage:
;   x:y = pointer to sid_voice structure
;   A = Column position to display data
;   Displays the data of the voice at fixed screen positions
; Returns:
;   Nothing
; Results:
;   Data displayed on screen
; Destroys:
;   PTR2, PTR2+1, TMP2, TMP2+1, TMP3, TMP3+1, TMP4, TMP4+1, A, X, Y
.proc display_data_one_voice : near

    ; Store the pointer to the voice structure in PTR1
    stx PTR2
    sty PTR2+1  

    ; Store Column position in TMP1
    sta TMP4 + 1   

    ; Prints data on rows 1 - 7
    do_reverse TMP4, #1
    print_decimal_at_16 TMP4 + 1, #1, PTR2, sid_voice::freq
    
    do_reverse TMP4, #2
    print_decimal_at_16 TMP4 + 1, #2, PTR2, sid_voice::pulse_width
    
    do_reverse TMP4, #3
    print_decimal_at_8 TMP4 + 1, #3, PTR2, sid_voice::ctrl
    
    do_reverse TMP4, #4
    print_decimal_at_8 TMP4 + 1, #4, PTR2, sid_voice::attack
    
    do_reverse TMP4, #5
    print_decimal_at_8 TMP4 + 1, #5, PTR2, sid_voice::decay
    
    do_reverse TMP4, #6
    print_decimal_at_8 TMP4 + 1, #6, PTR2, sid_voice::sustain

    do_reverse TMP4, #7
    print_decimal_at_8 TMP4 + 1, #7, PTR2, sid_voice::release
    
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

column:     .res 1
row:        .res 1

.endscope