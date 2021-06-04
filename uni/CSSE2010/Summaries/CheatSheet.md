# Number Representations

## Integers

### Basic Conversion

Decimal to unsigned:

```
53 = 26  13  6   3   1   0
     1   0   1   0   1   1
Read right to left: 110101
```

Unsigned to decimal:

```
110101
= 1 + 4 + 16 + 32
= 53
```

### Comparison

| Representation   | Range                       | Description                        | Conversion                                         |
| ---------------- | --------------------------- | ---------------------------------- | -------------------------------------------------- |
| Unsigned         | $[0, 2^n - 1]$              | No negatives                       | As above                                           |
| Signed magnitude | $[-(2^{n-1}-1), 2^{n-1}-1]$ | Top bit is sign of everything      | Unsigned, indicate sign                            |
| 1's complement   | Same as signed mag.         | Top bit is $-(2^{n-1}-1)$          | From unsigned to negative, flip all bits           |
| 2's complement   | $[-2^{n-1}, 2^{n-1}-1]$     | Top bit is $-2^{n-1}$              | From unsigned to negative, flip all bits and add 1 |
| Excess-128       | Same as 2's comp.           | Number stored as true number + 128 | 2's complement but with sign bit flipped           |

Alternate method for unsigned -> negative 2's complement: start from LSB, copy all 0s and first 1, then flip all bits past the first 1.

### Arithmetic

Addition is just normal addition.
For subtraction, add the negative 2's complement of the number ($a - b = a + (-b)$).

### Overflow

Unsigned: MSB carry out is 1
2's comp: MSB carry in and MSB carry out are different

## Real Numbers

### Fixed-Point

Example: for 4-4 unsigned fixed-point notation (4 integer bits, 4 fractional bits), 4.375 is represented as `01000110`.

| 8    | 4    | 2    | 1    | d.p. | 1/2  | 1/4  | 1/8  | 1/16 |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| 0    | 1    | 0    | 0    | d.p. | 0    | 1    | 1    | 0    |

For 2's complement fixed-point, MSB is still $-2^{n-1}$, but remember that the rest is positive, so need to *add* the fractions, not subtract.

### IEEE Floating-Point

| Single Precision               | Double Precision                 |
| ------------------------------ | -------------------------------- |
| MSB is sign bit                | MSB is sign bit                  |
| 8 bits of exponent, excess-127 | 11 bits of exponent, excess-1023 |
| 23 bits of mantissa            | 52 bits of mantissa              |

| Case               | Exponent       | Mantissa |
| ------------------ | -------------- | -------- |
| Normalised         | Not all 0 or 1 | Anything |
| Denormalised       | All 0          | Not 0    |
| Zero               | All 0          | All 0    |
| Infinity (for x/0) | All 1          | All 0    |
| NaN (for 0/0)      | All 1          | Not 0    |

Example: single-precision representation of -23.25:

```
-23.25
= -(16 + 4 + 2 + 1 + 0.25)
= -( 1 0 1 1 1 . 0 1 )
= -( 1.0 1 1 1   0 1 * 2^4) (normalised)
4 + 127 = 131 = 1000 0011 (biased exponent)
So, representation is
1     1000 0111  0111 0100 0000 000
sign  exponent        mantissa
Or, 0xC1BA0000.
Note we don't encode leading 1 in mantissa.
```

# Boolean Algebra

## Useful Identities

- $AA = A$, $A + A = A$
- $0A = 0$, $A + 1 = 1$
- $(A+B)(A+C) = A + BC$
- $A(B+C) = AB + AC$
- $A(A+B) = A$
- $\overline{AB} = \bar A + \bar B$
- $\overline{A + B} = \bar A \bar B$
- $A\bar B + \bar A B = A \oplus B$
- $AB + \bar A \bar B = \overline{A \oplus B}$
- $\overline{A \oplus B} = \bar A \oplus B = A \oplus \bar B$

## NAND/NOR Equivalents

![image-20210301162216940](file://D:\GitHub\beans\uni\CSSE2010\LectureNotes\images\image-20210301162216940.png?lastModify=1622788589)

# Combinational Logic

Half adder just adds two bits together with no cin; $S = A \oplus B$, $C_{out} = AB$.
Full adder adapts this for cin: $S = A \oplus B \oplus C_{in}$, $C_{out} = AB + C_{in}(A \oplus B)$ .

Cascade more full adders to make a ripple carry adder, where we chain previous cout to next cin.

