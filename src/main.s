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
    jsr update_sid  

    ; Check keys and act upon them
    getkey    
    gosub_if_char '+', process_plus1
    gosub_if_char '-', process_minus1
    gosub_if_char 219, process_plus10                   ; SHIFT +
    gosub_if_char 221, process_minus10                  ; SHIFT -
    gosub_if_char 166, process_plus100                  ; CMD +
    gosub_if_char 220, process_minus100                 ; CMD -
    gosub_if_char PETSCII_CURSOR_LEFT, process_left
    gosub_if_char PETSCII_CURSOR_RIGHT, process_right
    gosub_if_char PETSCII_CURSOR_UP, process_up
    gosub_if_char PETSCII_CURSOR_DOWN, process_down
    gosub_if_char PETSCII_F1, voice1_toggle
    gosub_if_char PETSCII_F3, voice2_toggle
    gosub_if_char PETSCII_F5, voice3_toggle
    gosub_if_char 'N', noise_toggle
    gosub_if_char 'P', pulse_toggle
    gosub_if_char 'S', sawtooth_toggle
    gosub_if_char 'T', triangle_toggle
    gosub_if_char 'Y', sync_toggle
    gosub_if_char 'R', ringmod_toggle
    goto_if_char 'Q', exit_program    

    ; Loop if they didn't quit
    jmp main_loop

exit_program:        
    rts

.endproc

; Update the SID registers from the voice structures
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   SID registers updated from voice structures
; Destroys:
;   A, X, Y, TMP1, PTR1
.proc update_sid
    lda #<voice1
    sta PTR1
    lda #>voice1
    sta PTR1+1
    lda #$00
    sta TMP1
    jsr update_sid_voice

    lda #<voice2
    sta PTR1
    lda #>voice2
    sta PTR1+1
    lda #$07
    sta TMP1
    jsr update_sid_voice

    lda #<voice3
    sta PTR1
    lda #>voice3
    sta PTR1+1
    lda #$0e
    sta TMP1
    jsr update_sid_voice

    lda #$15
    sta SID_REG_MODE_VOL

    rts
.endproc

; Update a single SID voice from its structure
; Usage:
;   TMP1 = voice offset (0, 7, or 14)
;   PTR1 = pointer to voice structure
; Returns:
;   Nothing
; Results:
;   SID voice registers updated from voice structure
; Destroys:
;   A, X, Y, TMP1, PTR1
.proc update_sid_voice
    ldx TMP1

    ; Load registers 0 and 1 for voice
    ldy #sid_voice::freq
    lda(PTR1), y
    sta SID1_BASE, x
    ldy #sid_voice::freq + 1
    inx
    lda(PTR1), y
    sta SID1_BASE, x
    inx

    ; Load registers 2 and 3 for voice
    ldy #sid_voice::pulse_width
    lda(PTR1), y
    sta SID1_BASE, x
    ldy #sid_voice::pulse_width + 1
    inx
    lda(PTR1), y
    sta SID1_BASE, x
    inx

    ; Load register 4 for voice
    ldy #sid_voice::ctrl
    lda(PTR1), y
    sta SID1_BASE, x
    inx

    ; Load register 5 for voice
    ldy #sid_voice::attack
    lda(PTR1), y
    rol
    rol
    rol
    rol
    ldy #sid_voice::decay
    ora (PTR1), y
    sta SID1_BASE, x
    inx

    ; Load register 6 for voice
    ldy #sid_voice::sustain
    lda(PTR1), y
    rol
    rol
    rol
    rol
    ldy #sid_voice::release
    ora (PTR1), y
    sta SID1_BASE, x
    inx

    rts
.endproc

; Toggle the noise flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Noise flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc noise_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:    

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_NOISE
    sta (PTR1), y   

exit_proc:        
    rts      
.endproc

; Toggle the pulse flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Pulse flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc pulse_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:  

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_PULSE            
    sta (PTR1), y   

exit_proc:        
    rts      
.endproc

; Toggle the sawtooth flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Sawtooth flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc sawtooth_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:    

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_SAWTOOTH
    sta (PTR1), y   

exit_proc:              
    rts      
.endproc

; Toggle the triangle flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Triangle flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc triangle_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:    

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_TRIANGLE
    sta (PTR1), y   

exit_proc:        
    rts      
.endproc

; Toggle the sync flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Sync flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc sync_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:    

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_SYNC
    sta (PTR1), y   

exit_proc:         
    rts      
.endproc

; Toggle the ringmod flag in the control register of the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Ringmod flag toggled in control register of selected voice
; Destroys:
;   A, Y, PTR1
.proc ringmod_toggle: near
    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen   

selected_column:    

    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #sid_ctrl_flags::FLAG_RINGMOD
    sta (PTR1), y   

exit_proc:        
    rts      
.endproc

; Toggle the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Selected voice changed
; Destroys:
;   A, PTR1
.proc voice1_toggle: near
    lda #<voice1
    sta PTR1
    lda #>voice1
    sta PTR1+1   
    jmp any_voice_toggle
.endproc

; Toggle the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Selected voice changed
; Destroys:
;   A, PTR1
.proc voice2_toggle: near
    lda #<voice2
    sta PTR1
    lda #>voice2
    sta PTR1+1   
    jmp any_voice_toggle
.endproc

; Toggle the selected voice
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Selected voice changed
; Destroys:
;   A, PTR1
.proc voice3_toggle: near
    lda #<voice3
    sta PTR1
    lda #>voice3
    sta PTR1+1   
    jmp any_voice_toggle
.endproc

; Toggle the selected voice
; Usage:
;   PTR1 = pointer to voice structure
; Returns:
;   Nothing
; Results:
;   Selected voice changed
; Destroys:
;   A, Y, PTR1
.proc any_voice_toggle: near
    ldy #sid_voice::ctrl
    lda (PTR1), y
    eor #$01               
    sta (PTR1), y   
    rts
.endproc

; Get a pointer to the current voice structure based on the column
; Usage:
;   column = current column (0, 1, or 2)
; Returns:
;   PTR1 = pointer to current voice structure, or null if invalid column
; Results:
;   PTR1 set to voice structure pointer or null
; Destroys:
;   A, PTR1
.proc cur_voice_to_ptr1: near

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
    
:   lda #$00                    ; You should never get here
    sta PTR1
    sta PTR1+1
    
selected_column:  

exit_proc:
    rts
.endproc

; Process a +1 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column incremented by 1
; Destroys:
;   A, Y, PTR1
.proc process_plus1 : near

    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen        

selected_column:               

    ; Increment the value in the selected column
    lda row
    cmp #$01
    bne :+        
        add_const_to_struct_16 PTR1, sid_voice::freq, 1, $ffff          ; Frequency
        jmp exit_proc
    
:   cmp #$02
    bne :+
        add_const_to_struct_16 PTR1, sid_voice::pulse_width, 1,$0fff    ; Pulse Width
        jmp exit_proc

:   cmp #$03
    bne :+

        ; Control Register
        jmp exit_proc

:   cmp #$04
    bne :+
        ldy #sid_voice::attack                                      ; Attack
        clc
        lda (PTR1), y
        adc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        
    
:   cmp #$05
    bne :+        
        ldy #sid_voice::decay                                       ; Decay
        clc
        lda (PTR1), y
        adc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        

:   cmp #$06   
    bne :+            
        ldy #sid_voice::sustain                                     ; Sustain
        clc
        lda (PTR1), y
        adc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        

:   cmp #$07
    bne exit_proc      ; This should not happen                
        ldy #sid_voice::release                                     ; Release
        clc
        lda (PTR1), y
        adc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc   

exit_proc:
    rts
.endproc

; Process a -1 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column decremented by 1
; Destroys:
;   A, Y, PTR1
.proc process_minus1 : near

    ; Get a pointer to the current voice, bail if it's null
    jsr cur_voice_to_ptr1    
    lda PTR1
    ora PTR1+1
    bne selected_column    
    jmp exit_proc                   ; This should not happen         

selected_column:      

    ; Increment the value in the selected column
    lda row
    cmp #$01
    bne :+
        sub_const_from_struct_16 PTR1, sid_voice::freq, 1, $ffff        ; Frequency        
        jmp exit_proc
        
:   cmp #$02
    bne :+
        sub_const_from_struct_16 PTR1, sid_voice::pulse_width, 1, $0fff ; Pulse Width
        jmp exit_proc

:   cmp #$03
    bne :+

        ; Control Register
        jmp exit_proc

:   cmp #$04
    bne :+
        ldy #sid_voice::attack                                      ; Attack
        sec
        lda (PTR1), y
        sbc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        
    
:   cmp #$05
    bne :+        
        ldy #sid_voice::decay                                       ; Decay
        sec
        lda (PTR1), y
        sbc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        

:   cmp #$06   
    bne :+            
        ldy #sid_voice::sustain                                     ; Sustain
        sec
        lda (PTR1), y
        sbc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        

:   cmp #$07
    bne exit_proc      ; This should not happen                
        ldy #sid_voice::release                                     ; Release
        sec
        lda (PTR1), y
        sbc #$01
        and #$0f
        sta (PTR1), y
        jmp exit_proc        

exit_proc:
    rts
.endproc

; Process a +10 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column incremented by 10
; Destroys:
;   A, Y, PTR1
.proc process_plus10 : near
    ldx #$0a
loop:
    jsr process_plus1
    dex
    bne loop
    rts
.endproc

; Process a -10 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column decremented by 10
; Destroys:
;   A, Y, PTR1
.proc process_minus10 : near        
    ldx #$0a
loop:
    jsr process_minus1
    dex
    bne loop
    rts
.endproc

; Process a +100 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column incremented by 100
; Destroys:

.proc process_plus100 : near
    ldx #100
loop:
    jsr process_plus1
    dex
    bne loop
    rts
.endproc

; Process a -100 command for the selected column
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Value in selected column decremented by 100
; Destroys:
;   A, Y, PTR1
.proc process_minus100 : near        
    ldx #100
loop:
    jsr process_minus1
    dex
    bne loop
    rts
.endproc

; Process a left cursor command
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Column decremented, wrapping around if necessary
; Destroys:
;   A
.proc process_left : near

    ; column--
    sec
    lda column
    sbc #$01
    sta column

    ; Did we go below 0?
    cmp #$ff
    bne :+
        lda #$02
        sta column    

:   rts
.endproc

; Process a right cursor command
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Column incremented, wrapping around if necessary
; Destroys:
;   A
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

; Process an up cursor command
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Row decremented, wrapping around if necessary
; Destroys:
;   A
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

; Process a down cursor command
; Usage:
;   Nothing
; Returns:
;   Nothing
; Results:
;   Row incremented, wrapping around if necessary
; Destroys:
;   A
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

column:     .res 1              ; Current selected column (0, 1, or 2) 
row:        .res 1              ; Current selected row (1 - 7)

.endscope