;
; astro
;
; aay64.txt VIC PAL/NTSC Differences indicates PAL 19656 cycles/frame (63/line) or 17095 NTSC

!addr {
SCREEN=$0400
ENDSCREEN=$0400+25*40

; variables
scrptr = $fb
count = $fd
xoff = $fe
}

    * = $0801
    !byte $0c,$08,<2020,>2020,$9e,$20,$32,$30,$36,$32,$00,$00,$00
start:
            ; cls
            lda #32
            ldx #0
-           sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$300,x
            inx
            bne -

            ldx #0 ; 0..24 increase to scroll up
            ldy #0 ; 0..39 increase to scroll right
            jsr drawlayer

            ldx #7 ; 0..24 increase to scroll up
            ldy #26 ; 0..39 increase to scroll right
            jsr drawlayer

            ldx #18
            ldy #4
            jsr drawlayer
            rts

; X = y-scroll (0..24, values scroll up)
; Y = x-scroll (0..39, values scroll right)
drawlayer:
            stx count
            sty xoff
            lda #<SCREEN
            sta scrptr
            lda #>SCREEN
            sta scrptr+1
.nextstar:
            clc
            lda layer0,x
            and #63
            adc xoff
            cmp #40
            bcc +
            sbc #40
+           tay
            lda #42 ; star
            sta (scrptr),y
            ; next line
            ;clc ;cleared by sbc
            lda scrptr
            adc #40
            sta scrptr
            bcc +
            inc scrptr+1
            ; next star
+           inx
            cpx #25
            bne +
            ldx #0
+           cpx count
            bne .nextstar
            rts

; each layer of the starfield consists of 25 stars, one per screen line on a random x-position
layer0:     !byte 18,12,26,16,21,31,35,31,3,4,10,30,27,31,27,18,2,26,38,6,29,21,14,23,8
