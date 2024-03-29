;
; astro
;
; aay64.txt VIC PAL/NTSC Differences indicates PAL 19656 cycles/frame (63/line) or 17095 NTSC

!addr {
SCREEN=$0400
ENDSCREEN=$0400+25*40
CHARSET=$2000

; variables
scrptr = $fb
}

    * = $0801
    !byte $0c,$08,<2020,>2020,$9e,$20,$32,$30,$36,$32,$00,$00,$00
start:
            ; cls
            lda #0
            ldx #0
-           sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$300,x
            inx
            bne -
            ; color
            lda #1
            ldx #0
-           sta $D800,x
            sta $D900,x
            sta $DA00,x
            sta $DB00,x
            inx
            bne -

subpixels:
            ; erase previous bits first before updating
            lda #0
            ldy #0 ; old y-offset layer0
            sta CHARSET + %00000001*8,y
            sta CHARSET + %00000011*8,y
            sta CHARSET + %00000101*8,y
            sta CHARSET + %00000111*8,y
            ldy #1 ; old y-offset layer1
            sta CHARSET + %00000010*8,y
            sta CHARSET + %00000110*8,y
            sta CHARSET + %00000011*8,y
            sta CHARSET + %00000111*8,y
            ldy #2 ; old y-offset layer2
            sta CHARSET + %00000100*8,y
            sta CHARSET + %00000101*8,y
            sta CHARSET + %00000110*8,y
            sta CHARSET + %00000111*8,y

            ; layer0 is 001
            ldx #0 ; x-offset layer0
            ldy #0 ; y-offset layer0
            lda starbits,x
            sta CHARSET + %00000001*8,y
            sta CHARSET + %00000011*8,y
            sta CHARSET + %00000101*8,y
            sta CHARSET + %00000111*8,y
            ; layer1 is 010
            ldx #1 ; x-offset layer1
            ldy #1 ; y-offset layer1
            lda CHARSET + %00000010*8,y
            ora starbits,x
            sta CHARSET + %00000010*8,y
            lda CHARSET + %00000011*8,y
            ora starbits,x
            sta CHARSET + %00000011*8,y
            lda CHARSET + %00000110*8,y
            ora starbits,x
            sta CHARSET + %00000110*8,y
            lda CHARSET + %00000111*8,y
            ora starbits,x
            sta CHARSET + %00000111*8,y
            ; layer2 is 100
hackme:     ldx #2 ; x-offset layer1
            ldy #2 ; y-offset layer1
            lda CHARSET + %00000100*8,y
            ora starbits,x
            sta CHARSET + %00000100*8,y
            lda CHARSET + %00000101*8,y
            ora starbits,x
            sta CHARSET + %00000101*8,y
            lda CHARSET + %00000110*8,y
            ora starbits,x
            sta CHARSET + %00000110*8,y
            lda CHARSET + %00000111*8,y
            ora starbits,x
            sta CHARSET + %00000111*8,y

            ;layer0 x and y scroll
            lda #1 ; 0..24 increase to scroll up
            sta layer0y
            lda #0 ; 0..39 increase to scroll right
            sta layer0x
            ;layer1 x and y scroll
            lda #5 ; 0..24 increase to scroll up
            sta layer1y
            lda #18 ; 0..39 increase to scroll right
            sta layer1x
            ;layer2 x and y scroll
            lda #20 ; 0..24 increase to scroll up
            sta layer2y
            lda #38 ; 0..39 increase to scroll right
            sta layer2x

drawlayer:
            lda #<SCREEN
            sta scrptr
            lda #>SCREEN
            sta scrptr+1
            ldx #0
            clc
.nextstar:
            ; Y = (layer0[layer0y] + layer0x) mod 40
            layer0y = *+1
            ldy layer0,x        ; self modified low-byte offset
            layer0x = *+1
            lda modulo40,y      ; self modified low-byte offset
            tay
            lda (scrptr),y
            ora #1
            sta (scrptr),y

            ; Y = (layer1[layer1y] + layer1x) mod 40
            layer1y = *+1
            ldy layer1,x        ; self modified low-byte offset
            layer1x = *+1
            lda modulo40,y      ; self modified low-byte offset
            tay
            lda (scrptr),y
            ora #2
            sta (scrptr),y

            ; Y = (layer2[layer2y] + layer2x) mod 40
            layer2y = *+1
            ldy layer2,x        ; self modified low-byte offset
            layer2x = *+1
            lda modulo40,y      ; self modified low-byte offset
            tay
            lda (scrptr),y
            ora #4
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
            bne .nextstar

            ; put logo on screen
            lda #%00011000 ; charset per $800 bits 3-1; $2000=$800*4
            sta $D018

            logo_row = 11
            ldx #logo_width - 1
-           lda logo,x
            sta SCREEN + (logo_row+0)*40 + (40-logo_width)/2,x
            lda logo+logo_width,x
            sta SCREEN + (logo_row+1)*40 + (40-logo_width)/2,x
            dex
            bpl -

            ; DEBUG rasterloop
            lda #$80
-           cmp $D012
            bne -

            ldx hackme+1
            inx
            cpx #8
            bne +
            ldx #0
+           stx hackme+1
            jmp subpixels

; each layer of the starfield consists of 25 stars, one per screen line on a random x-position
            !align $ff,0,0 ; align on new page
layer2:
layer1:
layer0:     !byte 18,12,26,16,21,31,35,31,3,4,10,30,27,31,27,18,2,26,38,6,29,21,14,23,8
            !byte 18,12,26,16,21,31,35,31,3,4,10,30,27,31,27,18,2,26,38,6,29,21,14,23,8

starbits:
            !byte 128,64,32,16,8,4,2,1

            !align $ff,0,0 ; align on new page
modulo40:
            !for i,0,39 { !byte i }
            !for i,0,39 { !byte i }

logo_width = 14
logo:
            !source "generated/astrobe-charmap.inc"

    ;----------------------
            *= $2000
    ;----------------------

            ; charset
            !fill 2^3*8, 0 ; keep room for starfield characters
            !source "generated/astrobe-charset.inc"

;TODO separate starfields
;TODO move stars
;TODO black; logo white, stars dark grey
;TODO 16kb cart
