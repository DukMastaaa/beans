# Lab 1

## Number Representations

Can convert to any radix-$2^n$ number system from binary by grouping the binary in groups of $n$

To convert between radix-$2^m$ and radix-$2^n$ where $m, n > 1$, convert to binary first then group.

## Negative Numbers

We need to encode information about the sign of a number in the most significant bit - bit 7 of an 8-bit binary number.

### Signed Magnitude

| bit                  | 7      | 6    | 5    | 4    | 3    | 2    | 1    | 0    |
| -------------------- | ------ | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| **unsigned**         | 128    | 64   | 32   | 16   | 8    | 4    | 2    | 1    |
| **signed magnitude** | *sign* | 64   | 32   | 16   | 8    | 4    | 2    | 1    |

Range: $-(2^{n-1} - 1)$ to  $2^{n-1} - 1$

Don't use this:

- +0 and -0 are represented in different ways
- The value of each bit depends on the value of the sign bit, which makes arithmetic very difficult

### One's Complement

| bit                  | 7        | 6    | 5    | 4    | 3    | 2    | 1    | 0    |
| -------------------- | -------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| **unsigned**         | 128      | 64   | 32   | 16   | 8    | 4    | 2    | 1    |
| **one's complement** | -12**7** | 64   | 32   | 16   | 8    | 4    | 2    | 1    |

Leftmost bit is now $-(2^{n-1} - 1)$. You **can** tell whether the number is negative by looking at the sign bit, since the ranges will not overlap.

To find the negative number, *invert all the bits*. This works with unsigned binary.

Range: $-(2^{n-1} -1)$ to $2^{n-1} - 1$.

Advantages:

- You can do arithmetic a bit easier, knowing that each bit's value will always be the same regardless of the MSB value

Disadvantages:

- +0 and -0 issue still remains; +0 represented by `00000000`, -0 represented with `11111111`

### Two's Complement

| bit                  | 7        | 6    | 5    | 4    | 3    | 2    | 1    | 0    |
| -------------------- | -------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| **unsigned**         | 128      | 64   | 32   | 16   | 8    | 4    | 2    | 1    |
| **two's complement** | -12**8** | 64   | 32   | 16   | 8    | 4    | 2    | 1    |

Leftmost bit is now $-2^{n-1}$, **not** $-(2^{n-1} - 1)$.

To find negative number, *invert all the bits and add 1*. This works with unsigned binary.

Range: $-2^{n-1}$ to $2^{n-1} - 1$.

Use this because:

- Arithmetic issue resolved, just like one's complement
- +0 and -0 now have only 1 representation, `00000000`; `11111111` now refers to -1.

### Excess $2^{m-1}$

(commonly excess 128)

Number stored as true value plus 128. For example,

- -3 stored as -3 + 128 = 125
- 3 stored as 3 + 128 = 131

Representation is actually the *same* as two's complement with sign-bit *reversed* (0 in MSB means -128, 1 in MSB means 0). So, to convert between the two, invert the sign bit.

Practical use:

- Hardware becomes simple for comparing magnitude of two signed numbers.

Range: same as two's complement.