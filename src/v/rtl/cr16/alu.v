//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: alu
// Description: The CR16 ALU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param P_WIDTH  the width of 'I_A', 'I_B', and 'O_C'
// @param I_OPCODE the 4-bit opcode number. See the 'Parameterized Opcodes' section.
// @param I_A      the first operand
// @param I_B      the second operand
// @param O_C      the result output
// @param O_STATUS the status flags of the operation executed
module alu #(parameter integer P_WIDTH = 16)
       (input wire [3:0] I_OPCODE,
        input wire [P_WIDTH - 1 : 0] I_A,
        input wire [P_WIDTH - 1 : 0] I_B,
        output reg [P_WIDTH - 1 : 0] O_C,
        output reg [4:0] O_STATUS);

// Parameterized Opcodes
localparam [3:0]
           ADD = 0,   // Unsigned and signed addition
           ADDC = 1,  // Unsigned and signed addition with carry
           MUL = 2,   // Signed multiplication
           SUB = 3,   // Unsigned and signed subtraction
           NOT = 4,   // Bitwise NOT
           AND = 5,   // Bitwise AND
           OR = 6,    // Bitwise OR
           XOR = 7,   // Bitwise XOR
           LSH = 8,   // Logical left shift
           RSH = 9,   // Logical right shift
           ALSH = 10, // Arithmetic (sign-extending) left shift
           ARSH = 11; // Arithmetic (sign-extending) right shift

// Status register indicies for one-hot encoding
localparam integer
           STATUS_INDEX_CARRY = 0,    // Asserted if unsigned addition has carry out,
                                      // reset if unsigned subtraction has borrow
           STATUS_INDEX_LOW = 1,      // Asserted if 'I_B' > 'I_A' in unsigned addition/subtraction
           STATUS_INDEX_FLAG = 2,     // Asserted if signed addition has carry out,
                                      // asserted if signed subtraction has borrow
           STATUS_INDEX_ZERO = 3,     // Always asserted if 'O_C' == 0
           STATUS_INDEX_NEGATIVE = 4; // Asserted if (un)signed addition/subtraction has negative
                                      // result, regardless of overflow/underflow

// Combinational logic case block
always @(*) begin
    case (I_OPCODE)
        ADD,
        ADDC: begin
            {O_STATUS[STATUS_INDEX_CARRY], O_C} = I_OPCODE == ADD ?
            I_B + I_A : I_B + I_A + 1'b1;
            if (I_B > I_A)
                O_STATUS[STATUS_INDEX_LOW] = 1'b1;
            else
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            // Set the Flag status bit for signed carry overflow (this occurs when the MSB
            // of the result is flipped compared to the MSB of the operands)
            O_STATUS[STATUS_INDEX_FLAG] =
            (I_A[P_WIDTH - 1] == I_B[P_WIDTH - 1]) & (I_A[P_WIDTH - 1] != O_C[P_WIDTH - 1]);
            // Set the Zero status bit if sum is 0
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            // Set the Negative status bit if result is negative (sign bit is 1) and
            // the operand sign bits were opposite or both operands are negative
            O_STATUS[STATUS_INDEX_NEGATIVE] =
            (I_A[P_WIDTH - 1] != I_B[P_WIDTH - 1] & O_C[P_WIDTH - 1] == 1'b1) |
            (I_A[P_WIDTH - 1] == 1'b1 & I_B[P_WIDTH - 1] == 1'b1);
        end
        MUL: begin
            O_C = $signed(I_A) * $signed(I_B);
            // Do not set flags for multiply instruction
            O_STATUS = 0;
        end
        SUB: begin
            O_C = I_B - I_A;
            if (I_B > I_A) begin
                O_STATUS[STATUS_INDEX_CARRY] = 1'b1;
                O_STATUS[STATUS_INDEX_LOW] = 1'b1;
            end
            else begin
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            end
            O_STATUS[STATUS_INDEX_FLAG] =
            (I_A[P_WIDTH - 1] != I_B[P_WIDTH - 1]) &
            (I_A[P_WIDTH - 1] == O_C[P_WIDTH - 1]);
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            // Use comparater instead of checking sign bit of 'O_C' so that this negative flag
            // is still set correctly in the event of an overflow/borrow.
            if ($signed(I_B) > $signed(I_A))
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b1;
            else
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        NOT: begin
            O_C = ~I_A;
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        AND: begin
            O_C = I_A & I_B;
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        OR: begin
            O_C = I_A | I_B;
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        XOR: begin
            O_C = I_A ^ I_B;
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        LSH: begin
            O_C = I_B << I_A[3:0];
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        RSH: begin
            O_C = I_B >> I_A[3:0];
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        ALSH: begin
            O_C = I_B <<< I_A[3:0];
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        ARSH: begin
            O_C = I_B >>> I_A[3:0];
            O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
            O_STATUS[STATUS_INDEX_LOW] = 1'b0;
            O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
            O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
            O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
        end
        default: begin
            O_C = 0;
            O_STATUS = 0;
        end
    endcase
end
endmodule
