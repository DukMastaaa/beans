# Lecture 20

## Assembler Directives

Usual syntax

```
label: opcode operand1, operand2 ; comments
```

- Label is so you can jump to statements and you can reference data. 

- The opcode is a symbolic abbreviation of the actual instruction opcode, e.g. LDS: Load Direct from data Space.

- Operand fields specify addresses and registers used for the instruction. AVR just uses `r0-r31` as register names, but Pentium and others have different names.

However, this isn't enough. We need to provide other information to the assembler (program which creates our program), which we do via *pseudo-instructions* (or *directives*, compare with preprocessor directives). 
Prefix is `.` character.

### Memory Segments

Different types of memory are known as segments to the assembler. We can use the directives to place data in different segments. 

- Use `.dseg` for the data segment (RAM). You can't place values here, but you can reserve space for variables.
- Use `.cseg` for the code segment (flash). You can place either program code or constant data. This is default.
- Use `.eseg` for the EEPROM segment. You can only place constants here - not using it in this course.

- `.byte n` reserves `n` bytes of space. This must be in `.dseg`. In example below, `variable` has been allocated 2 bytes in data memory. 

  ```
  .dseg
  variable: .byte 2
  ```

* Alternatively, you can use `.db` or `.dw` to define a byte or word (word = 16-bit in AVR). This works in `.cseg` or `.eseg`.
* `.def` makes a definition or alias for registers, e.g. `.def temp=r16`
* `.device` specifies the exact processor the program is designed for, e.g. `.device ATmega324A`. This prohibits use of non-implemented instructions
* `.include` includes a file, e.g. `.include "m324Adef.inc"` to get aliases for specific IO register bits.
* `.exit` tells assembler to stop processing the file
* `.equ` is like `.def` but can be for things other than registers, e.g. `.equ sreg = 0x3f`. This is not mutable.
* `.set` is like `.equ` but changeable.
* `.org` sets the location counter for the current segment to the supplied value. See below for what location counters are. e.g. `.org 0x10`.

## Assembly Process

We can not always just read each statement and then immediately generate the machine code. An example is not knowing the address of a label for the `jmp` instruction. This is called the *forward reference problem*, and we solve this with a two pass assembly process.

1. Define all the symbols (labels, `.def`, etc)
2. Now that the values of the symbols are known, we can assemble each instruction to produce the actual machine code.

To do this, the assembler generates a *symbol table* and *location counters* for `.dseg`, `.cseg` and `.eseg`. 

- Location counters store the address to put the next item. `cseg` starts from 0 and `dseg` starts from 256 because we already have CPU/IO/extended IO registers taking up the first 255 spots.

- The symbol table stores the name of the symbol, what segment it is (or none if it's just from an `.equ` or `.def` etc) and its value. This is text replacement.

  - If we're just given an `.equ` or `.def`, do something like the `RAMEND` in the example.

  - If we're given an address (e.g. `jmp RESET`), this consists of an instruction, so since `jmp` is 32-bit instruction and takes up 2 cells in memory (1 cell = 16 bits), we *increment* `cseg` counter by 2. Then, put `RESET` into the table with unknown value.

  - For cases like 

    ```
    .dseg
    .var1: .byte 2
    ```

    this indicates that we have a new *label* `var1` in `dseg` and its *value* will be the current `dseg` counter value. The label actually refers to the address stored in `dseg` counter. We then increment `dseg` counter by 2 because of `.byte 2`.

  - Let's say we have some

    ```
    .cseg
    mesg: .db 72, 101, 108, 108, 111
    ```

    and suppose the current value of `cseg` counter is 2. Then, the label `mesg` will refer to cell `2` as that's the current `cseg` counter value. Since each cell is 16 bits in `cseg`, we will take each pair of two values and place them at the memory location. For the last one, since we only have `111`, we zero-pad it from the right (equivalent `111, 0`). This brings the `cseg` counter to 5. 

| Symbol | Segment | Value   |
| ------ | ------- | ------- |
| RAMEND | -       | `0x8FF` |
| RESET  | cseg    | ?       |
|        |         |         |

Note that for every actual instruction, we need to increment the `cseg` counter.



