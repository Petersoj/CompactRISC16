#
# University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
#
# Create Date: 12/01/2021
# Name: all
# Description: An assembly code file meant to exhaustively test the capabilities of the CR16
# processor (according to the CR16 ISA) and the accompanying assembler.
# Authors: Nate Hansen, Jacob Peterson
#

    MOVIL   rsp 0xFF
    MOVIU   rsp 0x03   # Initialize stack pointer to 1023

##
# The main function.
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
.L2
    LSHI    r0  1
    ADDI    r4  1
    CMPI    r4  3
    JLT     .L2
    PUSH    r0
    CMPI    r0  8
    JNE     .L1
    MOVIL   r1  20
    MOVIU   r1  0
.L1
    SUBI    r1  10     # r1 = 10
    MULI    r2  2      # r2 = 8
    PUSH    r1
    STORE   rsp r2
    SUBI    rsp 1
    # Call .end
    MOVIL   r11 1
    MOVIU   r11 0
    CALL    .end

# Below gives a good example of the format of "assembly docs"

##
# Returns the greater of two given numbers.
#
# @param r11  the first number
# @param r12  the second number
#
# @return r10  the greater number
##
.max
    CMP    r11   r12
    JGE    .L3$r9
    MOV    r10   r12
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
.L3
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
# Does nothing or spins the processor indefinitely.
#
# @param r11  '0' to spin indefinitely, '1' to do nothing
##
.end
    CMPI    r11 1
    JEQ     .nop
.spin
    BUC     -1
.nop
    NOP
