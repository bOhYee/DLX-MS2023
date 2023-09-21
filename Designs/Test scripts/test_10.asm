# Q = 1D R = 4
addi r1, r0, #0x1298
addi r2, r0, #0xA4
div r3, r1, r2

# Q = 1; R = 0
addi r1, r0, #0x1298
addi r2, r0, #0x1298
div r4, r1, r2

# Save in R1 0x93675692
addui r1, r0, #0x9367
slli r1, r1, #16
ori r1, r1, #0x5692

# Q = 983A R = 9366BE58
addi r2, r0, #0xF7E3
div r5, r1, r2

# Q = 4 R = FFFFEEEF
addi r1, r0, #0xFA24
div r6, r5, r1