# Lecture 7

## Counters

Multi-bit register that goes through predetermined seq of states when clock pulses

Counter which follows binary number seq is a *binary counter*. n-bit binary counter has n flip-flops, and counts e.g. 00 -> 01 -> 10 -> 11 

### 1-bit counter

Here is simple 1-bit counter. We usually call Q the *present state* and D the *next state*, because Q <- D after one clock pulse.

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210315162133226.png" alt="image-20210315162133226" style="zoom:33%;" />

### 2-bit counter

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210322103517843.png" alt="image-20210322103517843" style="zoom:30%;" />

This is calculated by drawing table with current state and next states, and trying to find logic expression for $D_i$ in terms of all $Q_i$.