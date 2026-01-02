.scope
.define current_file "math.s"

.include "mac.inc"
.include "math.inc"

.segment "MAIN"

; Define exports for all public functions in this module
.export divide_16bit_by_8bit
.export REMAINDER

; Divide a 16-bit number in TMP2:TMP2 + 1 by an 8-bit divisor in TMP3
; Result: TMP2:TMP2 + 1 = quotient, REMAINDER = remainder
; usage:
;   TMP2:TMP2 + 1 = dividend (16-bit)
;   TMP3 = divisor (8-bit)
;   jsr divide_16bit_by_8bit
;   Result: TMP2:TMP2 + 1 = quotient, REMAINDER = remainder
.proc divide_16bit_by_8bit : near
    ldx #$10          ; 16 bits to process (loop counter)
    lda #$00          ; Clear REMAINDER
    sta REMAINDER

divide_shift_loop:
    ; Shift the 16-bit value left (TMP2:TMP2+1) into REMAINDER
    lda TMP2          ; Load low byte of TMP2
    asl               ; Shift left
    sta TMP2          ; Store shifted value back in TMP2
    lda TMP2 + 1      ; Load high byte of TMP2 + 1
    rol               ; Rotate left through carry
    sta TMP2 + 1      ; Store shifted value back in TMP2 + 1
    lda REMAINDER     ; Load REMAINDER
    rol               ; Rotate left through carry
    sta REMAINDER     ; Store shifted value back in REMAINDER

    ; Compare REMAINDER with divisor (TMP3)
    lda REMAINDER     ; Load REMAINDER into A
    cmp TMP3          ; Compare A (REMAINDER) with TMP3 (divisor)
    bcc no_subtract   ; If REMAINDER < divisor, skip subtraction

    ; Subtract divisor from REMAINDER
    sec               ; Set carry for subtraction
    sbc TMP3          ; Subtract TMP3 (divisor) from A (REMAINDER)
    sta REMAINDER     ; Store the result back in REMAINDER

    ; Increment the quotient
    lda TMP2          ; Load low byte of TMP2
    ora #$01          ; Set the least significant bit
    sta TMP2          ; Store the updated value back in TMP2

no_subtract:
    dex               ; Decrement loop counter
    bne divide_shift_loop ; Repeat until all 16 bits are processed

    rts               ; Return
.endproc

;additional data definitions
REMAINDER: .res 1       ; Temporary storage for division remainder

.endscope