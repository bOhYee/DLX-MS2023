# 0x29801A20 (696261152)
addi r1, r0, #0x2980
slli r1, r1, #16
ori r1, r1, #0x1A20
sw 20(r0), r1

# 0x3189BBE2 (831110114)
addi r2, r0, #0x3189
slli r2, r2, #16
ori r2, r2, #0xBBE2
sw 13(r0), r2

add r1, r0, r0
lw r2, 13(r0)
lw r3, 17(r0)
addi r2, r0, #1
sw 9(r2), r3
addi r3, r0, #0x3487
sw 5(r0), r3

# Test of forwaring stall
lw r5, 20(r0)
ori r6, r5, #0x0B78