.scope
.define current_file "help.s"

.include "mac.inc"
.include "help.inc"
.include "main.inc"
.include "print.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export display_help

.proc display_help : near
    ; Clear screen
    scnclr

    ; Move cursor to top-left corner
    ldx #$00
    ldy #$00
    jsr gotoxy
    
    ; Print HELP_TEXT lines
    ldx #<HELP_TEXT_01
    ldy #>HELP_TEXT_01
    jsr print
    ldx #<HELP_TEXT_02
    ldy #>HELP_TEXT_02
    jsr print
    ldx #<HELP_TEXT_03
    ldy #>HELP_TEXT_03
    jsr print
    ldx #<HELP_TEXT_04
    ldy #>HELP_TEXT_04
    jsr print
    ldx #<HELP_TEXT_05
    ldy #>HELP_TEXT_05
    jsr print
    ldx #<HELP_TEXT_06
    ldy #>HELP_TEXT_06
    jsr print
    ldx #<HELP_TEXT_07
    ldy #>HELP_TEXT_07
    jsr print
    ldx #<HELP_TEXT_08
    ldy #>HELP_TEXT_08
    jsr print
    ldx #<HELP_TEXT_09
    ldy #>HELP_TEXT_09
    jsr print
    ldx #<HELP_TEXT_10
    ldy #>HELP_TEXT_10
    jsr print
    ldx #<HELP_TEXT_11
    ldy #>HELP_TEXT_11
    jsr print
    ldx #<HELP_TEXT_12
    ldy #>HELP_TEXT_12
    jsr print
    ldx #<HELP_TEXT_13
    ldy #>HELP_TEXT_13
    jsr print
    ldx #<HELP_TEXT_14
    ldy #>HELP_TEXT_14
    jsr print
    ldx #<HELP_TEXT_15
    ldy #>HELP_TEXT_15
    jsr print
    ldx #<HELP_TEXT_16
    ldy #>HELP_TEXT_16
    jsr print
    ldx #<HELP_TEXT_17
    ldy #>HELP_TEXT_17
    jsr print
    ldx #<HELP_TEXT_18
    ldy #>HELP_TEXT_18
    jsr print
    ldx #<HELP_TEXT_19
    ldy #>HELP_TEXT_19
    jsr print
    ldx #<HELP_TEXT_20
    ldy #>HELP_TEXT_20
    jsr print
    ldx #<HELP_TEXT_21
    ldy #>HELP_TEXT_21
    jsr print
    ldx #<HELP_TEXT_22
    ldy #>HELP_TEXT_22
    jsr print
    ldx #<HELP_TEXT_23
    ldy #>HELP_TEXT_23
    jsr print
    
    ; Wait for a key press
    getkey

    ; Redisplay the main template
    scnclr
    jsr display_template

    rts
.endproc
                    ;         1         2         3         4
                    ;1234567890123456789012345678901234567890
HELP_TEXT_01: .byte "SID TOOL HELP MENU                     ", $0d, $00
HELP_TEXT_02: .byte "-------------------                    ", $0d, $00
HELP_TEXT_03: .byte "ARROW KEYS: MOVE FROM FIELD TO FIELD   ", $0d, $00
HELP_TEXT_04: .byte "+/-:        ADD/SUB 1 FROM FIELD       ", $0d, $00
HELP_TEXT_05: .byte "SHIFT +/-:  ADD/SUB 10 FROM FIELD      ", $0d, $00
HELP_TEXT_06: .byte "CMD +/-:    ADD/SUB 100 FROM FIELD     ", $0d, $00
HELP_TEXT_07: .byte "F1/F3/F5:   TOGGLE VOICE  1/2/3 ON/OFF ", $0d, $00
HELP_TEXT_08: .byte "T:          TOGGLE WAVEFORM TO TRIANGLE", $0d, $00
HELP_TEXT_09: .byte "S:          TOGGLE WAVEFORM TO SAWTOOTH", $0d, $00
HELP_TEXT_10: .byte "P:          TOGGLE WAVEFORM TO PULSE   ", $0d, $00
HELP_TEXT_11: .byte "N:          TOGGLE WAVEFORM TO NOISE   ", $0d, $00
HELP_TEXT_12: .byte "Y:          TOGGLE SYNC                ", $0d, $00
HELP_TEXT_13: .byte "R:          TOGGLE RINGMOD             ", $0d, $00
HELP_TEXT_14: .byte "?:          HELP                       ", $0d, $00
HELP_TEXT_15: .byte "Q:          QUIT                       ", $0d, $00
HELP_TEXT_16: .byte "", $0d, $00
HELP_TEXT_17: .byte "", $0d, $00
HELP_TEXT_18: .byte "", $0d, $00
HELP_TEXT_19: .byte "", $0d, $00
HELP_TEXT_20: .byte "", $0d, $00
HELP_TEXT_21: .byte "", $0d, $00
HELP_TEXT_22: .byte "", $0d, $00
HELP_TEXT_23: .byte "PRESS ANY KEY TO CONTINUE...           ", $0d, $00

.endscope