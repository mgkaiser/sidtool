.scope
.define current_file "math.s"

.include "mac.inc"
.include "math.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export divide_16bit_by_8bit
.export REMAINDER

; Divide a 16-bit number in TMP2:TMP2 + 1 by an 8-bit divisor in Y
; Result: TMP2:TMP2 + 1 = quotient, REMAINDER = remainder
; usage:
;   TMP2:TMP2 + 1 = dividend (16-bit)
;   Y = divisor (8-bit)
;   jsr divide_16bit_by_8bit
;   Result: TMP2:TMP2 + 1 = quotient, REMAINDER = remainder
.proc divide_16bit_by_8bit : near
    ldx #$10  ; 16 bits to process
    lda #$00
    sta REMAINDER
divide_shift_loop:
    asl TMP2
    rol TMP2 + 1
    rol REMAINDER
    cmp REMAINDER, y
    bcc no_subtract
    sec
    sbc REMAINDER, y
    inc TMP2
no_subtract:
    dex
    bne divide_shift_loop
    rts
.endproc

;additional data definitions
REMAINDER: .res 1       ; Temporary storage for division remainder

.endscope