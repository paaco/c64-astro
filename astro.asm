;
; astro
;

SCREEN=$0400
ENDSCREEN=$0400+7*40

    * = $0801
    !byte $0c,$08,$b5,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
start:
            lda #<SCREEN
            sta $fb
            lda #>SCREEN
            sta $fc

            ldx #100 ; count
volgende:
            ; determine next star
            clc
            lda $fb
            adc #47 ; TODO real next star
            sta $fb
            bcc .ok
            inc $fc
.ok:
            ; check overflow
            ; if $FB/$FC >ENDSCREEN, reduce by (ENDSCREEN-SCREEN)
            lda $fc
            cmp #>ENDSCREEN
            bmi .no_overflow
            lda $fb
            cmp #<ENDSCREEN
            bmi .no_overflow
            ; reduce $FB/$FC by (ENDSCREEN-SCREEN)
            lda $fb
            sec
            sbc #<(ENDSCREEN-SCREEN)
            sta $fb
            lda $fc
            sbc #>(ENDSCREEN-SCREEN)
            sta $fc

.no_overflow:
plotster:
            ;lda #42         ; star
            txa
            ldy #0
            sta ($fb),y

            dex
            bne volgende
            rts
