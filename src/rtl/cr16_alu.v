//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu
// Description: The CR16 ALU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module alu #(parameter integer P_WIDTH = 16)
            (input wire I_CLK,
             input wire I_ENABLE,
             input wire [3 : 0] I_OPCODE,
             input wire [P_WIDTH - 1 : 0] I_A,
             input wire [P_WIDTH - 1 : 0] I_B,
             output reg [P_WIDTH - 1 : 0] O_C,
             output reg [4 : 0] O_STATUS);
 
    // Parameterized opcodes
    parameter integer
    ADD = 0,
    ADDU = 1,
    ADDC = 2,
    ADDCU = 3,
    SUB = 4,
    CMP = 5,
    CMPU = 6,
    AND = 7,
    OR = 8,
    XOR = 9,
    NOT = 10,
    LSH = 11,
    RSH = 12,
    ALSH = 13,
    ARSH = 14,
    NOP = 15;
    
    // Parameterized status outputs
    parameter integer
    STATUS_CARRY = 5'b00001,
    STATUS_LOW = 5'b00010,
    STATUS_FLAG = 5'b00100,
    STATUS_ZERO = 5'b01000,
    STATUS_NEGATIVE = 5'b10000;

endmodule
