# Small test to check the behaviour in the presence of a load after a branch
addi r1, r1, #1
beqz r1, end 
lw r2, 13(r0)
add r3, r1, r2

end:
nop