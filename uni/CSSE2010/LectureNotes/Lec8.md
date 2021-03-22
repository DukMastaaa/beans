# Lecture 8

## Finite State Machines

Sequential circuits can be thought of as a finite state machine (or state machine for short):

- finite number of possible states
- only *one* current state
- can *transition* between one state to the next based on inputs and current state

2 types:

1. **Mealy** machine: outputs depend on current state **and** inputs
2. **Moore** machine: outputs depend **only** on current state (and outputs only change when state changes)

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210322134953628.png" alt="image-20210322134953628" style="zoom:50%;" />

State machines contain **state/transition logic** (the combinational cct on the left) and **output logic** (cct on right). Here, we only study Moore machines where output logic does not depend on inputs.

## State Diagrams

Notation for states:

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210322135222317.png" alt="image-20210322135222317" style="zoom: 33%;" />

Transitions indicate how one state changes to the next. This is illustrated by drawing an arrow from one state bubble to the next one. Put logic expression next to arrow - if expression true, state changes to new state pointed to by arrow.

No label on arrow means `true` - always transition.

Completeness: transitions coming from one state must encompass all possibilities of inputs exactly once.

### Example

Here is state diagram of 2-bit binary up counter

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210322135827691.png" alt="image-20210322135827691" style="zoom:50%;" />

Here is state diagram of 2-bit binary up/down counter

<img src="C:\Users\JB\AppData\Roaming\Typora\typora-user-images\image-20210322135855537.png" alt="image-20210322135855537" style="zoom:50%;" />

Note that some arrows lead to the same state - this indicates that having those inputs will not change the state.

## State Tables

Can represent state diagrams as a *state table* like so. Here is 2-bit binary up counter example

| Current State | U    | Next State | Q1   | Q0   |
| ------------- | ---- | ---------- | ---- | ---- |
| S0            | 0    | S3         | 0    | 0    |
| S0            | 1    | S1         | 0    | 0    |
| S1            | 0    | S0         | 0    | 1    |
| S1            | 1    | S2         | 0    | 1    |

etc. On the left of Next State, we have *every combination* of state and inputs. This is a *1-dimensional* state table.

For a *2-dimensional* state table, we split the next state column into one column for each input.

## State Encoding

We need to *encode* each state into flip-flop values; need to choose number of flip-flops and the bit patterns which represent each state. Ideally, we choose the encoding st. it makes the combinational logic simple.

### Unsigned

what it says on the tin. just assign unsigned int to each state in order.

### 1-hot Encoding

Use 1 flip-flop per state, so that only 1 flip-flop is high at a time. This means that state transition logic is simpler, and acts as a decoder. Note that with 1-hot, there will always be a 2-bit transition between each state.

### Gray Encoding

Basically, set up bits such that there is only 1 bit transition between each state. This is to avoid race conditions.

## Sequence Detection

See Lab 8 for steps on how to construct circuit from state diagram.

