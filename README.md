# c64-astro

Starfield

This is a small exercise in 6502 arithmetic.

The star field is made up from different layers of stars spread out randomly over the 40x25 screen.
Each layer moves with a slightly different speed to create a parallax effect.

Stars are always plot in the same order, however they wrap around (modulo) offset 1000 ($03e8). This uses 16-bit unsigned compares with cmp, sbc and bcc for "less than".
