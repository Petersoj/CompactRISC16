#
# University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
#
# Create Date: 12/01/2021
# Name: all
# Description: An assembly code file meant to exhaustively test the capabilities of the CR16
# processor (according to the CR16 ISA) and the accompanying assembler.
# Authors: Nate Hansen, Jacob Peterson
#

# The following is an example of `define (macro) syntax
`define STACK_PTR_LOWER 0xFF
`define STACK_PTR_UPPER 0x03

##
# The program initialization.
#
# @return void
##
.init
    # Initialize stack pointer to 1023
    MOVIL   rsp STACK_PTR_LOWER
    MOVIU   rsp STACK_PTR_UPPER

##
# The main function.
#
# @return void
##
.main
    MOVIL   r0  0      # i
    MOVIU   r0  0
    MOVIL   r1  3      # x
    MOVIU   r1  0
    MOVIL   r2  4      # y
    MOVIU   r2  0
    MOV     r11 r1
    MOV     r12 r2
    CALL    .max
    PUSH    r10        # Return value should be 4
    ADDI    r0  1
    MOVIL   r4  0
    MOVIU   r4  0      # j
    .main:l2           # Nested labels should be be prepended with the function label and a ':' and
    LSHI    r0  1      # they should be indented.
    ADDI    r4  1
    CMPI    r4  3
    JLT     .main:l2
    PUSH    r0
    CMPI    r0  8
    JNE     .main:l1
    MOVIL   r1  20
    MOVIU   r1  0
    .main:l1
    SUBI    r1  10     # r1 = 10
    MULI    r2  2      # r2 = 8
    PUSH    r1
    STORE   rsp r2
    SUBI    rsp 1
    # Call .test_random_raw_data
    CALL    .test_random_raw_data
    # Call .end to spin indefinitely
    MOVIL   r11 0
    MOVIU   r11 0
    CALL    .end

# Below gives a good example of the format of "assembly docs"

##
# Returns the greater of two given numbers.
#
# @param r11 - the first number
# @param r12 - the second number
#
# @return r10 - the greater number
##
.max
    CMP    r11   r12
    JGE    .max:l3$r9   # This label requires a label-loading register to load the absolute address
    MOV    r10   r12    # of the desired label into a register.
    RET
    NOP                 # The long list of NOPs here is used to confirm that the assembler uses
    NOP                 # absolute jumping and not displacement jumping with instructions containing
    NOP                 # a label reference that lies outside the equivalent displacement-immediate
    NOP                 # instruction range.
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    .max:l3
    MOV    r10   r11
    RET

##
# Defines random raw data that gets directly transcoded into the final machine code file and can be
# referenced via the '.random_raw_data' label.
##
.random_raw_data
0xABF2      # Hexadecimal numbers are prefixed with '0x'
042         # Octal numbers are prefixed with '0'
2048        # Decimal numbers are prefixed with nothing
-0x1        # Hex, octal, and decimal numbers can be negative
-01
-1
0b0101      # Binary numbers are prefixed with a '0b'
0b1001_1001 # Underscores are ignored in numbers

##
# Loads '.random_raw_data' and performs some arithmetic and then stores it back in main memory.
#
# @return void
##
.test_random_raw_data
    # Load '.random_raw_data' address into 'r0'. This will always compile to 'MOVIL' and 'MOVIU'
    # instructions with address of the label as the lower and upper immediate values respectively.
    MOV     r0  .random_raw_data

    ADDI    r0  3                   # Get the -0x1 data address from '.random_raw_data'
    LOAD    r1  r0                  # Load -0x1 into r1
    ADDI    r1  1                   # Add 1 to -1 to get 0 in r1
    STORE   r0  r1                  # Store 0 back where -0x1 was in '.random_raw_data'

    RET

##
# Does nothing or spins the processor indefinitely.
#
# @param r11 - '0' to spin indefinitely, '1' to do nothing
#
# @return void
##
.end
    CMPI    r11 1
    JEQ     .end:nop
    .end:spin
    BUC     -1
    .end:nop
    NOP
