# Save in R1 0x23675692
addi r1, r0, #0x2367
slli r1, r1, #16
ori r1, r1, #0x5692

# Save in R2 0x23675660
addi r2, r0, #0x2367
slli r2, r2, #16
ori r2, r2, #0x5660

sub r3, r1, r2              # Positive 50
sub r4, r2, r1              # Negative 50

addi r1, r0, #-19
addi r2, r0, #26
sub r3, r1, r2              # Negative 
sub r3, r2, r1              # Positive

addi r1, r0, #-45
addi r2, r0, #-3
add r3, r1, r2
sub r4, r1, r2