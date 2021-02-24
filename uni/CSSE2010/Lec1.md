# Lecture 1

Levels of abstraction:

0. Digital logic level
1. Microarchitecture level
2. Instruction set architecture level
3. Operating system machine level
4. Assembly language level
5. Problem-oriented language level

## Binary

Binary - number system whose base is 2.
Bit = binary digit, either 0 or 1
Byte = 8 bits

Modern computers deal with *words* which are power-of-2 number of bytes - this is word length.

### Representing Numbers in Binary

Each bit position has a value:

| 5     | 4     | 3     | 2     | 1     | 0     | bit position     |
| ----- | ----- | ----- | ----- | ----- | ----- | ---------------- |
| $2^5$ | $2^4$ | $2^3$ | $2^2$ | $2^1$ | $2^0$ | power-of-2 value |
| 32    | 16    | 8     | 4     | 2     | 1     | base-10 value    |

#### Binary -> Decimal

Add place values.

#### Decimal -> Binary

**Method 1**:

1. rewrite `n` as sum of powers of `2` (by repeatedly subtracting largest power of 2 not greater than `n`)
2. assemble binary number from `1`s in bit positions corresponding to powers of `2`.

Example: convert $53_{10}$ to binary:

- $53 = 32 + 16 + 4 + 1 = 2^5 + 2^4 + 2^2 + 2^0 = 00110101_{10}$

**Method 2**:

1. divide `n` by 2
2. remainder of division (0 or 1) is next bit
3. repeat with `n` = quotient.
4. write binary as remainders from bottom to top.

Example: convert $53_{10}$ to binary:

```
53
26 + 1
13 + 0
6 + 1
3 + 0
1 + 1
0 + 1
```

Reading from bottom to top, we get `110101`.

This method works with any base - just change number you divide by.

#### Most/Least Significant Bit

MSB - bit that's worth the most, e.g. $2^7 = 128$. For an `n-bit` unsigned word, MSB = $2^{n-1}$.

LSB - bit that's worth the least, $2^0 = 1$.

#### Number Range of Unsigned Numbers

Assuming whole, unsigned numbers,

- smallest number = all 0s, $0$
- largest number = all 1s, $2^n - 1$.

## Other Radices

Radix = base of the number system.

For a radix-$k$ number system, 

- there are $k$ different symbols to represent digits 0 .. $k-1$
- value of each digit (from the right) is $k^0$, $k^1$, $k^2$, ...
- the base $k$ is written as $10_{k}$ (for all $k$)

Sometimes, octal (base 8) and hexadecimal (base 16) are used to shorten notation
Octal: symbols 0 .. 7
Hexadecimal: symbols 0 .. 9, A .. F

### How to tell what radix?

Most common notation (which is used in the course):

| Base        | Notation                   |
| ----------- | -------------------------- |
| Hexadecimal | Leading `0x`, like `0x101` |
| Octal       | Leading `0`, like `0101`   |
| Binary      | Leading `0b`, like `0b101` |

 
