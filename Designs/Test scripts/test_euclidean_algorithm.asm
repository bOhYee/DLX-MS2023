addi r30, r0, #0

# initialize r1 and r2
addi r1, r30, #1071		# a = 1071
addi r2, r30, #462		# b = 462

loop:
seqi r3, r2, #0
bnez r3, end_loop

add r4, r30, r2		# t = b

# calculate b = a mod b
div r5, r1, r2			# r5 = a/b
multlo r6, r5, r2		# r6 = r5 * b
sub r7, r1, r6			# r7 = a - r6		this is the rest of the division
add r2, r30, r7			# b = r7 (rest)

# save in register 1 the value t
add r1, r30, r4		# a = t
j loop

#final result is saved in r1 (a)
end_loop:
nop