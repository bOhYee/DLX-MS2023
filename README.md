# DLX-ProjectMS-23
Repository for the DLX project for the Microelectronic Systems course at Polytechnic of Turin. 

## Supported instructions
Here is a list of all the supported instructions of the DLX microprocessor. All of them work on 32-bits input operands to produce 32-bits results. `RS1`, `RS2` and `RD` refers to the registers, contained in the register file, where operands are read/written and they can vary between 0 and 31 (i.e. `r0`, `r1`, ..., `r31`). `#Imm` indicate a 16-bits or 26-bits value, depending on the instruction, that can be inserted by the programmer inside the instruction, using a decimal or hexadecimal notation. It will be sign-extended before using it for computations.

Two registers are treated differently from the rest:
 - `r0` contains always the `0` value;
 - `r31` is used to contain the value of the return address after a `jal` instruction has been processed.

**NOTE**: Neither of these two rules has been forced at the hardware level but they need to be satisfied in order for the microprocessor to work.

### R-type instructions
| Operation | Type       | Description                                                          | <div style="width: 200px">Example of usage </div> |
|-----------|------------|----------------------------------------------------------------------|---------------------------------------------------|
| `add`     | Arithmetic | Signed addition between registers                                    | `add RD, RS1, RS2`                                |
| `addu`    | Arithmetic | Unsigned addition between registers                                  | `addu RD, RS1, RS2`                               |
| `sub`     | Arithmetic | Signed subtraction between registers                                 | `sub RD, RS1, RS2`                                |
| `subu`    | Arithmetic | Unsigned subtraction between registers                               | `subu RD, RS1, RS2`                               |
| `and`     | Logic      | Bitwise AND between registers                                        | `and RD, RS1, RS2`                                |
| `nand`    | Logic      | Bitwise NAND between registers                                       | `nand RD, RS1, RS2`                               |
| `or`      | Logic      | Bitwise OR between registers                                         | `or RD, RS1, RS2`                                 |
| `nor`     | Logic      | Bitwise NOR between registers                                        | `nor RD, RS1, RS2`                                |
| `xor`     | Logic      | Bitwise XOR between registers                                        | `xor RD, RS1, RS2`                                |
| `xnor`    | Logic      | Bitwise XNOR between registers                                       | `xnor RD, RS1, RS2`                               |
| `sll`     | Shift      | Logical left shift of A register (shift specified by B register)     | `sll RD, RS1, RS2`                                |
| `srl`     | Shift      | Logical right shift of A register (shift specified by B register)    | `srl RD, RS1, RS2`                                |
| `sra`     | Shift      | Arithmetic right shift of A register (shift specified by B register) | `sra RD, RS1, RS2`                                |
| `sgt`     | Comparison | Set DEST to one if A is greater than B                               | `sgt RD, RS1, RS2`                                |
| `sge`     | Comparison | Set DEST to one if A is greater or equal than B                      | `sge RD, RS1, RS2`                                |
| `seq`     | Comparison | Set DEST to one if A is equal to B                                   | `seq RD, RS1, RS2`                                |
| `sne`     | Comparison | Set DEST to one if A is not equal to B                               | `sne RD, RS1, RS2`                                |
| `slt`     | Comparison | Set DEST to one if A is lower than B                                 | `slt RD, RS1, RS2`                                |
| `sle`     | Comparison | Set DEST to one if A is lower or equal to B                          | `sle RD, RS1, RS2`                                |

### I-type instructions
| Operation | Type       | Description                                                                   | <div style="width: 200px">Example of usage </div> |
|-----------|------------|-------------------------------------------------------------------------------|---------------------------------------------------|
| `addi`    | Arithmetic | Signed addition between a register and a sign-extended  immediate value       | `addi RD, RS1, #Imm`                              |
| `addui`   | Arithmetic | Unsigned addition between a register and an unsigned immediate value          | `addui RD, RS1, #Imm`                             |
| `subi`    | Arithmetic | Signed subtraction between a register and a sign-extended immediate value     | `subi RD, RS1, #Imm`                              |
| `subui`   | Arithmetic | Unsigned subtraction between a register and an unsigned immediate value       | `subui RD, RS1, #Imm`                             |
| `andi`    | Logic      | Bitwise AND between a register and a sign-extended immediate value            | `andi RD, RS1, #Imm`                              |
| `nandi`   | Logic      | Bitwise NAND between a register and a sign-extended immediate value           | `nandi RD, RS1, #Imm`                             |
| `ori`     | Logic      | Bitwise OR between a register and a sign-extended immediate value             | `ori RD, RS1, #Imm`                               |
| `nori`    | Logic      | Bitwise NOR between a register and a sign-extended immediate value            | `nori RD, RS1, #Imm`                              |
| `xori`    | Logic      | Bitwise XOR between a register and a sign-extended immediate value            | `xori RD, RS1, #Imm`                              |
| `xnori`   | Logic      | Bitwise XNOR between a register and a sign-extended immediate value           | `xnori RD, RS1, #Imm`                             |
| `slli`    | Shift      | Logical left shift of A register (shift specified by an immediate value)      | `slli RD, RS1, #Imm`                              |
| `srli`    | Shift      | Logical left shift of A register (shift specified by an immediate value)      | `srli RD, RS1, #Imm`                              |
| `srai`    | Shift      | Arithmetic left shift of A register (shift specified by an immediate value)   | `srai RD, RS1, #Imm`                              |
| `sgti`    | Comparison | Set DEST to one if A is greater than a sign-extended immediate value          | `sgti RD, RS1, #Imm`                              |
| `sgtui`   | Comparison | Set DEST to one if A is greater than a unsigned immediate value               | `sgtui RD, RS1, #Imm`                             |
| `sgei`    | Comparison | Set DEST to one if A is greater or equal than a sign-extended immediate value | `sgei RD, RS1, #Imm`                              |
| `sgeui`   | Comparison | Set DEST to one if A is greater or equal than an unsigned immediate value     | `sgeui RD, RS1, #Imm`                             |
| `seqi`    | Comparison | Set DEST to one if A is equal to a sign-extended immediate value              | `seqi RD, RS1, #Imm`                              |
| `snei`    | Comparison | Set DEST to one if A is not equal to a sign-extended immediate value          | `snei RD, RS1, #Imm`                              |
| `slti`    | Comparison | Set DEST to one if A is lower than a sign-extended immediate value            | `slti RD, RS1, #Imm`                              |
| `sltui`   | Comparison | Set DEST to one if A is lower than an unsigned immediate value                | `sltui RD, RS1, #Imm`                             |
| `slei`    | Comparison | Set DEST to one if A is lower or equal than a sign-extended immediate value   | `slei RD, RS1, #Imm`                              |
| `sleui`   | Comparison | Set DEST to one if A is lower or equal than an unsigned immediate value       | `sleui RD, RS1, #Imm`                             |
| `beqz`    | Branch     | Branch to target instruction if operand is equal to 0                         | `beqz RD, #Target`                                |
| `bnez`    | Branch     | Branch to target instruction if operand is not equal to 0                     | `bnez RD, #Target`                                |


### J-type instructions
| Operation | Type   | Description                                                                            | <div style="width: 200px">Example of usage </div> |
|-----------|--------|----------------------------------------------------------------------------------------|---------------------------------------------------|
| `j`       | Branch | Branch to target instruction                                                           | `j #Target`                                       |
| `jal`     | Branch | Branch to target instruction while saving the address of the next instruction in `r31` | `jal #Target`                                     |