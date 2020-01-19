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
            ldy #2 ; 0..39 increase to scroll right
            jsr drawlayer

            ; ldx #7 ; 0..24 increase to scroll up
            ; ldy #26 ; 0..39 increase to scroll right
            ; jsr drawlayer

            ; ldx #18
            ; ldy #4
            ; jsr drawlayer
            rts

; X = y-scroll (0..24, values scroll up)
; Y = x-scroll (0..39, values scroll right)
drawlayer:
            stx count
            dey                 ; to correct for C=1 from 'sec' later
            sty xoff
            lda #<SCREEN
            sta scrptr
            lda #>SCREEN
            sta scrptr+1
            sec                 ; now loop is always entered with C=1
.nextstar:
            ; Y = A = layer0[x] + xoff
            lda layer0,x
            adc xoff            ; sets C=0
            tay
            ; if Y >= 40 then Y = A - 40
            sbc #40-1           ; 1 to correct for C=0
            bcc +
            clc
            tay
+
            ; plot star
            lda #42 ; star
            sta (scrptr),y

            ; next line
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

;TODO improvements:
;TODO - modulo40 table
;TODO - double layer0 to allow for rollover (no need to reset counter)
;TODO - inline layers into a single loop
;TODO - plot a star with lda, ora, sta
;TODO - calculate star characters