# DLX test environments
Some of the tests used to try out the DLX microprocessor can be found in this folder. Each one focuses on some kind of instruction, or set of related instructions, to check if the intended behaviour is respected, even when placed inside more generic code.

| Test          | Description                                                                                | Works |
|---------------|--------------------------------------------------------------------------------------------|-------|
| `test_1.asm`  | Simple and generic test for arithmetic instructions                                        | Y     |
| `test_2.asm`  | Signed comparison test using different values                                              | Y     |
| `test_3.asm`  | Branch logic test                                                                          | Y     |
| `test_4.asm`  | Branch logic test                                                                          | Y     |
| `test_5.asm`  | Signed additions and subtractions on different values, ranging from positive to negative   | Y     |
| `test_6.asm`  | Unsigned comparison test using different values                                            | Y     |
| `test_7.asm`  | DRAM instruction tests for load and store behaviours and hazards verification              | Y     |
| `test_8.asm`  | Unsigned additions and subtractions on different values, ranging from positive to negative | Y     |
| `test_9.asm`  | Bitwise operation test                                                                     | Y     |
| `test_10.asm` | Division                                                                                   | Y     |
| `test_11.asm` | Branch logic test (branch after branch)                                                    | Y     |
| `test_12.asm` | Branch logic test (load with forwarding required after branch)                             | Y     |