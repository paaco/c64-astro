;
; astro
;
; aay64.txt VIC PAL/NTSC Differences indicates PAL 19656 cycles/frame (63/line) or 17095 NTSC

SCREEN=$0400
ENDSCREEN=$0400+25*40

    * = $0801
    !byte $0c,$08,<2019,>2019,$9e,$20,$32,$30,$36,$32,$00,$00,$00
start:
            ; cls
            lda #32
            ldx #0
.cls        sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$300,x
            inx
            bne .cls

            lda #<SCREEN
            sta $fb
            lda #>SCREEN
            sta $fc

            ldx #200 ; count
next:
            ; determine next star
            clc
            lda $fb
            adc #47 ; TODO real next star
            sta $fb
            bcc .ok
            inc $fc
.ok:
            ; check overflow
            ; if $FB/$FC > ENDSCREEN, reduce by (ENDSCREEN-SCREEN)
            lda $fc
            cmp #>ENDSCREEN
            bcc .lessthan
            bne .greater
            lda $fb
            cmp #<ENDSCREEN
            bcc .lessthan
.greater:   ; reduce $FB/$FC by (ENDSCREEN-SCREEN)
            ;lda $fb  already so
            ;sec      already so
            sbc #<(ENDSCREEN-SCREEN)
            sta $fb
            lda $fc
            sbc #>(ENDSCREEN-SCREEN)
            sta $fc
.lessthan:
plotstar:
            ;lda #42         ; star
            txa
            ldy #0
            sta ($fb),y

            dex
            bne next
            rts
