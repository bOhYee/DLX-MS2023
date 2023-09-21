# Sum the first 3 numbers then exit the loop
addi r1, r0, #0x00
addi r2, r0, #0x00

cycle:
seqi r3, r1, #3
bnez r3, end        # Jump only when R1 is equal to 3 (seq returns 1)
addi r1, r1, #0x01
add r2, r2, r1
j cycle

end:
nop