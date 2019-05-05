# Simple-Assembly-Program


Due Dates for SAP:

Item                                   Due Date                Points
Partial VM                             4/1/19                  10
Full VM                                4/10/19                 10
Turing Machine                         4/24/19                 10
Assembler                              5/13/19                 30
Debugger with Disassembler             6/3/19                  20

new due date: 5/21 but not checked until 5/29


Hints:
memory is 10000 spaces, when binary files are read in, fill in left over memory with 0s.
2 special values length and start address are not part of memory.
errors to check for:
  out of bounds map, instruction call, register
  divide by zero
  stack errors: pop empty, push full.
VM should have error checking, when find an error crash the virtual program and display appropriate error message.
use generic stack of size 200 separate from memory for storing previous values of r5-r9 before sr calls.
break up turing machine into subroutines






