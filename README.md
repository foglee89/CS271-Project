# CS271-Project
Computer Arch. &amp; Assembly language - x86/IA-32

**Program prompt:**
Program Description

Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):

·         Implement and test two macros for string processing. These macros may use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.

o    mGetString:  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.

o    mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).

·         Implement and test two procedures for signed integers which use string primitive instructions

o    ReadVal: 

1.      Invoke the mGetString macro (see parameter requirements above) to get user input in the form of a string of digits.

2.      Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).

3.      Store this one value in a memory variable (output parameter, by reference). 

o    WriteVal: 

1.      Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits

2.      Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.

·         Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:

1.      Get 10 valid integers from the user. Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.

2.      Stores these numeric values in an array.

3.      Display the integers, their sum, and their average.

·         Your ReadVal will be called within the loop in main. Do not put your counted loop within ReadVal.

Program Requirements

1.      User’s numeric input must be validated the hard way:

a.      Read the user's input as a string and convert the string to numeric form.

b.      If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.

c.       If the user enters nothing (empty input), display an error and re-prompt.

2.      ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.

3.      Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.

4.      All procedure parameters must be passed on the runtime stack. Strings must be passed by reference

5.      Prompts, identifying strings, and other memory locations must be passed by address to the macros.

6.      Used registers must be saved and restored by the called procedures and macros.

7.      The stack frame must be cleaned up by the called procedure.

8.      Procedures (except main) must not reference data segment variables by name. There is a significant penalty attached to violations of this rule.  Some global constants (properly defined using EQU, =, or TEXTEQU and not redefined) are allowed. These must fit the proper role of a constant in a program (master values used throughout a program which, similar to HI and LO in Project 5)

9.      The program must use Register Indirect addressing for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.

10. Procedures may use local variables when appropriate.

11. The program must be fully documented and laid out according to the CS271 Style Guide  D
