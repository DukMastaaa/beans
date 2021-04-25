# AVR Instruction Set

## Arithmetic, Logical

`ADD rd, rr`, `AND rd, rr`, `OR rd, rr`, `EOR rd, rr` - just like ALU operations, results go into `rd`.

| syntax           | description                                                  |
| ---------------- | ------------------------------------------------------------ |
| `ADD rd, rr`     | adds without carry                                           |
| `AND rd, rr`     | bitwise and                                                  |
| `ASR rd`         | similar to `LSR`. shifts everything to right, original right is carry, but left bit is repeated. implements signed division by 2. compare `LSR`. there is no `ASL` for some reason. |
| `BREQ  label`    | jumps to `label` if `Z = 1`.                                 |
| `BRNE label`     | jumps to `label` if `Z = 0`.                                 |
| `CALL label`     | calls new procedure at memory address `label`, 32 bit instruction. |
| `CLR rd`         | sets all bits in `rd` to 0. equivalent `LDI rd, 0x00`. compare `SER` |
| `COM rd`         | flip all bits in register, 1's complement negation           |
| `CP rd, rr`      | basically subtracts `rd` and `rr` and sees if they're the same. result not stored, but status flags are changed. used with `BRXX` instructions. |
| `EOR rd, rr`     | bitwise exclusive or                                         |
| `ICALL`          | calls procedure stored in `Z` register, 16 bit.              |
| `IJMP`           | jumps to address stored in `Z` register, 16 bit.             |
| `IN rd, P`       | load I/O register value into general purpose register, rd no restriction, P is I/O register 0 - 63 |
| `JMP label`      | jumps to a label, just like goto. label syntax just like batch goto. |
| `LD rd X`        | indirect address. load value in register pointed by register `X` into rd. the `X` needs to be an `XYZ` register storing the address of another register. see `LDS` |
| `LDI rd, number` | load immediate; put the number in the given register. for r16-r31 only. can specify number in different base, e.g. `255, -1, 0xFF, 0337, 0b11111111`. |
| `LDS rd, s`      | direct address. load value at address `s` into `rd`. this is 32-bit wide instruction. see `LD` |
| `LSL rd`         | logical shift left. just moves everything to left and writes a 0 on right side, original left goes to carry. implements multiplication by 2. compare `LSR`, `ASR` |
| `LSR rd`         | logical shift right. just moves everything to right and writes a 0 on left side, original right goes to carry. implements unsigned division by 2. compare `LSL, ASR` |
| `MOV rd, rr`     | copy contents of register rr to register rd.                 |
| `NEG rd`         | 2's complement negation                                      |
| `OR rd, rr`      | bitwise or                                                   |
| `ORI rd, number` | or immediate into register, 16 <= rd <= 31                   |
| `RCALL label`    | relative call, compare with `CALL`. 16 bit.                  |
| `RET`            | what                                                         |
| `RJMP offset`    | Moves instruction pointer by `offset` amount (relative jump). -2048 <= `offset` <= 2047. |
| `ROL rd`         | rotate left through carry, useful for * by 2 with more than 8 bits. compare `ROR` |
| `ROR rd`         | rotate right through carry, useful for / by 2 with more than 8 bits. compare `ROL` |
| `OUT P, rr`      | store value from gp register to I/O, rr no restriction, P 0 - 63 |
| `SER rd`         | sets all bits in `rd` to 1, equivalent `LDI rd, 0xFF`. rd [16, 31]. compare `CLR` |
| `ST X, rr`       | indirect address, write value in `rr` into address pointed by register `X`. compare `LD` |
| `STS d, rr`      | direct address, write value in `rr` into address`d`. compare `LDS` |
|                  |                                                              |
|                  |                                                              |
|                  |                                                              |