# Save in R1 0x23675692
addui r1, r0, #0x2367
slli r1, r1, #16
ori r1, r1, #0x5692

# Save in R2 0x23675660
addui r2, r0, #0x2367
slli r2, r2, #16
ori r2, r2, #0x5660

subu r3, r1, r2              # Positive 50
subu r4, r2, r1              # Negative 50

addui r1, r0, #-19           # Positive (loadec without sign-ext)
addui r2, r0, #26            # Positive
subu r3, r1, r2              # Negative 
subu r3, r2, r1              # Positive

addui r1, r0, #-45
addui r2, r0, #-3
addu r3, r1, r2
subu r4, r1, r2