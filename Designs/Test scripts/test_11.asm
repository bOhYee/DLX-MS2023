# Small test to check the behaviour in the presence of two subsequent jumps 
addi r1, r1, #1
beqz r1, end 
nop
j end_add
nop
j end

addi r2, r2, #1

end_add:
addi r1, r1, #1
end:
nop