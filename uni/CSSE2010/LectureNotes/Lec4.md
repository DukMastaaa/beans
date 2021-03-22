# Lecture 4

## More adders

![image-20210303110729462](C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210303110729462.png)

This is ripple-carry adder or parallel adder for 4 bits. You chain full adders together, and their carry in.

## Binary Subtraction

$A - B$ usually implemented as $A + (-B)$. $-B$ is just the 2's complement of $B$ (i.e. flip bits, add 1).

Example: do 5 - 3 for 4-bit. Obviously, answer is 2.

**Conventional Subtraction**

```
 0101
-0011
-----
 0010
Need to borrow 1 from 4s place, turn 2s place into 2.
```

**Using 2's Complement**

-3: normal 3 is 0011, 2's complement of negative is flip bits add one : `1101`.
Now, add `0101` and `1101` which gives `0010` with carry-out bit `1`. Since MSB carryout is the same as msb of 

### Subtraction Circuit

Want some control signal M where if M is high, we subtract; if M is low, we add. Subtracting involves inverting bits of B and adding 1. How to make this conditional?

We accomplish this using XOR on M and B, $X = M \oplus B$. If M is 0, you just get B itself, if M is 1, you get $\bar B$.

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210303112406814.png" alt="image-20210303112406814" style="zoom:67%;" />

Here, each bit of B is XORed with M to flip all of the bits depending on value of M. Note M is connected to carry in, so if M is high, then we also add 1 to complete the process of calculating 2's complement.

Inside the + circuit, you would have 4 cascaded full adders, with carryin of the first connected to carryin of the circuit, and carryout connected to circuit carryout.

## Combinatorial Circuits

$n$ inputs, $m$ outputs. Circuit contains combination of logic gates; output depends on inputs only. Can also write truth table: $n$ input columns, $m$ output columns, $2^n$ rows.

### Multiplexer or Mux

$2^n$ data inputs, 1 output, $n$ control (or select) inputs which select 1 of the inputs to be sent to the output.

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210303113509614.png" alt="image-20210303113509614" style="zoom:33%;" />

Function table example for 4-to-1 multiplexer (with n = 2):

| $S_1$ | $S_0$ | F     |
| ----- | ----- | ----- |
| 0     | 0     | $D_0$ |
| 0     | 1     | $D_1$ |
| 1     | 0     | $D_2$ |
| 1     | 1     | $D_3$ |

Simplify $F$ to be in terms of $D_n$ - the truth table will actually have $2^6 = 64$ lines. This is called a function table.

In general, for an $2^n$-to-1 multiplexer, we have the amt of inputs/control/output as above.

Logic eqn: 

From function table, can still use sum of products, but need to AND, like so:
$$
F = D_0 \bar S_1 \bar S_0 + D_1 \bar S_1 S_0 + D_2 S_1 \bar S_0 + D_3 S_1 S_0
$$
Can actually use a multiplexer to implement arbitrary logic function based on select inputs, and use data inputs as result of each combiantion of selection inputs.

### Decoder

Converts $n$-bit input to a logic HIGH of the $n$th output.

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210303115201702.png" alt="image-20210303115201702" style="zoom: 50%;" />

This can be used as an address decoder - given a memory address, it outputs to one cell.

To implement this, literally just use sum of products, because each output is a min term.
e.g. $D_0 = \bar A \bar B \bar C$, $D_1 = \bar A \bar B C$, etc.

### Demultiplexer , Encoder

These are reverse operations of the previous 2 circuits.

## Timing Diagram

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210303115523806.png" alt="image-20210303115523806" style="zoom:50%;" />

Timing diagram is like a truth table but graphical. Input waveforms show all possible combinations.

We don't consider the following effects, but there are:

- propagation delay: time for change in input to be reflected in output
- fall time - time taken for output to change 1 -> 0
- rise time - time taken for output to change 0 -> 1