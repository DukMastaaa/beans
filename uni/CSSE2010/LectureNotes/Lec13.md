# Lecture 13

`LD`, `LDS`, `ST`, `STS`

Data is usually copied, not moved. 

- Register -> register: MOV
- Memory -> register: LD
- Register -> memory: ST
- I/O register -> register: IN
- Register -> I/O register: OUT

Dyadic - 2 operands, monadic - 1 operand.

`SET`, `CLR`, `LSL`, `LSR`, `ASR`, `ROL`, `ROR`

Subtleties to `LSL`, `LSR` and `ASR`

### Comparison

Comparison is essentially the same as subtraction, using `CP`. Results of the subtraction are not saved, but status flags (Z, N, C, V) are set. 

`BRXX label` instructions check whether some status flag is set, and jumps to the provided label.

### Addressing Modes

*Immediate*: value is in the instruction, e.g. `ANDI r17, 0xBA`

*Register*: only register numbers in instruction, e.g. `AND r18, r19`

*Direct*: memory address in instruction, e.g. `LDS r15, $1234` where `lds` is load direct from SRAM. Requires 32-bit instruction.

*Indirect*: memory address in register, register number in instruction, e.g. `LD r5, X` where `X` is some register holding location in memory.

## Data Types

ISAs also have data types, such as:

- (numeric) integers of different lengths, floats, many others
- (non-numeric) bool, bitmap, chars, pointers

Different machines provide hardware support for different data types. Adding other data types is possible through software, e.g. 16-bit int operations can be built from 8-bit int operations. For addition, use `ADD` and `ADC` for carry between bits.