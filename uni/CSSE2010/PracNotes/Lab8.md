# Lab 8

Draw state diagram - make most simple. For sequence detection, check transitions based on the previous numbers - don't go back to starting state if the sequence breaks, go back to the most relevant state

Then, turn into 2D state table:

| Current State | Next if 0 | Next if 1 | Output |
| ------------- | --------- | --------- | ------ |
| Start         | '0'       | Start     | 0      |

etc..

Then, turn 2D state table into 1D state table using state encoding. Need to assign a state to a binary number which is stored in some amount of flip flops.

Unsigned - just store as Q1, Q0 etc. as usual
1-hot - one bit is HIGH for each state, e.g. 0001 0010 0100 1000
Gray - 1-bit transitions between each state, 00 01 11 10

Then, want to create the table:

| State | Q1   | Q0   | S    | D1   | D0   | X    |
| ----- | ---- | ---- | ---- | ---- | ---- | ---- |
| start | 0    | 0    | 0    | 0    | 1    | 0    |
| start | 0    | 0    | 1    | 0    | 0    | 0    |

etc. Easy way to do this is just replace 2D state table with Q and D.

From here, can get boolean expression for D1, D0, X from Q1, Q0, S. Then, ready to draw logic diagram and cct schematic. 