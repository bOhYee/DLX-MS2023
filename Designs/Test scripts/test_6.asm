# 0x29801A20 (696261152)
addi r1, r0, #0x2980
slli r1, r1, #16
ori r1, r1, #0x1A20

# 0x3189BBE2 (831110114)
addi r2, r0, #0x3189
slli r2, r2, #16
ori r2, r2, #0xBBE2

sgeu r4, r1, r2  # 0
sgtu r5, r1, r2  # 0
seq r6, r1, r2   # 0
sne r7, r1, r2   # 1
sleu r8, r1, r2  # 1
sltu r9, r1, r2  # 1

# 0x934D3C16 (-1823654890)
addi r1, r0, #0x934D
slli r1, r1, #16
ori r1, r1, #0x3C16

# 0x20E91BB3 (552147891)
addi r2, r0, #0x20E9
slli r2, r2, #16
ori r2, r2, #0x1BB3

sgeu r4, r1, r2  # 1
sgtu r5, r1, r2  # 1
seq r6, r1, r2   # 0
sne r7, r1, r2   # 1
sleu r8, r1, r2  # 0
sltu r9, r1, r2  # 0

# 0x20E91BB3 (552147891)
addi r1, r0, #0x20E9
slli r1, r1, #16
ori r1, r1, #0x1BB3

# 0x934D3C16 (-1823654890)
addi r2, r0, #0x934D
slli r2, r2, #16
ori r2, r2, #0x3C16

sgeu r4, r1, r2 # 0
sgtu r5, r1, r2 # 0
seq r6, r1, r2  # 0
sne r7, r1, r2  # 1
sleu r8, r1, r2 # 1
sltu r9, r1, r2 # 1 

# 0xC572F52E (-982321874)
addi r1, r0, #0xC572
slli r1, r1, #16
ori r1, r1, #0xF52E

# 0x805BA289 (-2141478263)
addi r2, r0, #0x405B
slli r2, r2, #16
ori r2, r2, #0xA289

sgeu r4, r1, r2 # 1
sgtu r5, r1, r2 # 1
seq r6, r1, r2  # 0
sne r7, r1, r2  # 1
sleu r8, r1, r2 # 0
sltu r9, r1, r2 # 0

# 0xC572F52E (-982321874)
addi r1, r0, #0xC572
slli r1, r1, #16
ori r1, r1, #0xF52E

# 0xC572F52E (-982321874)
addi r2, r0, #0xC572
slli r2, r2, #16
ori r2, r2, #0xF52E

sgeu r4, r1, r2 # 1
sgtu r5, r1, r2 # 0
seq r6, r1, r2  # 1
sne r7, r1, r2  # 0
sleu r8, r1, r2 # 1
sltu r9, r1, r2 # 0

# 0x20E91BB3 (552147891)
addi r1, r0, #0x20E9
slli r1, r1, #16
ori r1, r1, #0x1BB3

# 0x20E91BB3 (552147891)
addi r2, r0, #0x20E9
slli r2, r2, #16
ori r2, r2, #0x1BB3

sgeu r4, r1, r2 # 1
sgtu r5, r1, r2 # 0
seq r6, r1, r2  # 1
sne r7, r1, r2  # 0
sleu r8, r1, r2 # 1
sltu r9, r1, r2 # 0