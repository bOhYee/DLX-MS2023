# Bubble sort implementation
addi r30, r0, #0    # Zero constant
addi r2, r30, #5    # N constant

addi r1, r30, #0    # i
subi r2, r2, #1     # N-1
addi r9, r30, #0    # Swapped flag

inizio_loop:
# i < 5
sge r3, r1, r2
bnez r3, fine_loop

addi r9, r30, #0    # Swapped flag
addi r4, r30, #0    # j
sub r5, r2, r1      # N-i-1

loop_interno:
# j < n-i-1
slt r3, r4, r5
beqz r3, fine_loop_interno

lw r10, 0(r4)
lw r11, 1(r4)
sgt r3, r10, r11
beqz r3, a_min_eq_b

a_magg_b:
sw 1(r4), r10
sw 0(r4), r11
addi r9, r30, #1    # Swapped flag

# Do not swap anything
a_min_eq_b:
addi r4, r4, #1
j loop_interno

fine_loop_interno:
snei r3, r9, #0
beqz r3, fine_loop
nop
nop
addi r1, r1, #1
j inizio_loop

fine_loop:
nop