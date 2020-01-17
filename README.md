# c64-astro

Starfield

This is a small exercise in 6502 arithmetic.

The star field is made up from different layers of stars spread out randomly over the 40x25 screen.
Each layer moves with a slightly different speed to create a parallax effect.

Stars are always plot in the same order, however they wrap around (modulo) offset 1000 ($03e8). This uses 16-bit unsigned compares with cmp, sbc and bcc for "less than".

Unfortunately this trick doesn't work if you also want to scroll sideways.
Stars will wrap around in that case and that looks ugly.

So the approach is to plot a layer from top to bottom, starting with an offset star (scrolling up) and adding an offset to X-position (scrolling right)

    ; just kept for reference on 16-bit calculations
    ;SCREEN=$0400
    ;ENDSCREEN=$0400+25*40
    ;             ; check overflow
    ;             ; if $FB/$FC > ENDSCREEN, reduce by (ENDSCREEN-SCREEN)
    ;             lda $fc
    ;             cmp #>ENDSCREEN
    ;             bcc .lessthan
    ;             bne .greater
    ;             lda $fb
    ;             cmp #<ENDSCREEN
    ;             bcc .lessthan
    ; .greater:   ; reduce $FB/$FC by (ENDSCREEN-SCREEN)
    ;             ;lda $fb  already so
    ;             ;sec      already so
    ;             sbc #<(ENDSCREEN-SCREEN)
    ;             sta $fb
    ;             lda $fc
    ;             sbc #>(ENDSCREEN-SCREEN)
    ;             sta $fc
    ; .lessthan: