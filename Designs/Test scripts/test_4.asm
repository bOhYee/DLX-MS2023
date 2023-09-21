# Sum the first 3 even numbers then exit the loop
addi r1, r0, #0x00
addi r2, r0, #0x00
addi r3, r0, #0x00

cycle:
seqi r4, r1, #3
bnez r4, end        # Jump only when R1 is equal to 3 (seq returns 1)

addi r3, r3, #1     # Verify if even by checking if LSB is 0
andi r5, r3, #1
snei r6, r5, #1
beqz r6, cycle

addi r1, r1, #0x01
add r2, r2, r1
jal cycle

end:
nop