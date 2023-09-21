# Load 0x548BAE72
addi r1, r0, #0x548B
slli r1, r1, #16
ori r1, r1, #0xAE72

# Load 0x1298BA01
addi r2, r0, #0x1298
slli r2, r2, #16
ori r2, r2, #0xBA01

and r3, r1, r2          # 0x1088aa00
nand r4, r1, r2         # 0xEF7755FF
or r5, r1, r2           # 0x569bbe73
nor r6, r1, r2          # 0xA964418C
xor r7, r1, r2          # 0x46131473
xnor r8, r1, r2         # 0xB9ECEB8C

andi r1, r8, #0x2716    # 0x00002304
nandi r2, r5, #0x0182   # 0xFFFFFFFD
ori r5, r3, #0x9182     # 0x1088bb82
nori r3, r4, #0x1812    # 0x1088A200
xori r4, r6, #0x3711    # 0xA964769d
xnori r6, r7, #0xFFFF   # 0xB9EC1473