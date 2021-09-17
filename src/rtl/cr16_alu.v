//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu
// Description: The CR16 ALU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_alu #(parameter integer P_WIDTH = 16)
       (input wire I_ENABLE,
        input wire [3 : 0] I_OPCODE,
        input wire [P_WIDTH - 1 : 0] I_A,
        input wire [P_WIDTH - 1 : 0] I_B,
        output reg [P_WIDTH - 1 : 0] O_C,
        output reg [4 : 0] O_STATUS);

// Parameterized Opcodes
localparam integer
           ADD = 0,   // Signed addition
           ADDU = 1,  // Unsigned addition
           ADDC = 2,  // Signed addition with carry
           ADDCU = 3, // Unsigned addition with carry
           SUB = 4,   // Signed subtraction
           SUBU = 5,  // Unsigned subtraction
           AND = 6,   // Bitwise AND
           OR = 7,    // Bitwise OR
           XOR = 8,   // Bitwise XOR
           NOT = 9,   // Bitwise NOT
           LSH = 10,  // Logical left shift
           RSH = 11,  // Logical right shift
           ALSH = 12, // Arithmetic (sign-extending) left shift
           ARSH = 13; // Arithmetic (sign-extending) right shift

// Status register indicies for one-hot encoding
localparam integer
           STATUS_INDEX_CARRY = 0,    // MSB carry out for unsigned addition
           STATUS_INDEX_LOW = 1,      // 'I_B' < 'I_A' for unsigned subtraction
           STATUS_INDEX_FLAG = 2,     // MSB carry out for signed addition
           STATUS_INDEX_ZERO = 3,     // 'O_C' == 0
           STATUS_INDEX_NEGATIVE = 4; // 'I_B' < 'I_A' for signed subtraction

// Combinational logic case block
always @(*) begin
    if (I_ENABLE) begin
        case (I_OPCODE)
            ADD: begin
                O_C = I_A + I_B;
                // Do not set the Carry status bit for signed arithmetic
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                // Do not set the Low status bit for signed arithmetic
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                // Set the Flag status bit for signed carry overflow (this occurs when the MSB
                // of the result is flipped compared to the MSB of the operands)
                O_STATUS[STATUS_INDEX_FLAG] =
                (~I_A[P_WIDTH - 1] & ~I_B[P_WIDTH - 1] & O_C[P_WIDTH - 1]) |
                (I_A[P_WIDTH - 1] & I_B[P_WIDTH - 1] & ~O_C[P_WIDTH - 1]);
                // Set the Zero status bit if sum is 0
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                // Set the Negative status bit if result is negative (sign bit is 1)
                O_STATUS[STATUS_INDEX_NEGATIVE] = O_C[P_WIDTH - 1] == 1'b1;
            end
            ADDU: begin
                // Add 'I_A' and 'I_B' and set to 'O_C' with carry status bit specified
                {O_STATUS[STATUS_INDEX_CARRY], O_C} = I_A + I_B;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            ADDC: begin
                // Add 'I_A' and 'I_B' and 1 and set to 'O_C'
                // This instruction is needed due to adding 'immediate high' numbers
                // in the event that an 'immediate low' addition instruction caused a carry.
                O_C = I_A + I_B + 1'b1;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] =
                (~I_A[P_WIDTH - 1] & ~I_B[P_WIDTH - 1] & O_C[P_WIDTH - 1]) |
                (I_A[P_WIDTH - 1] & I_B[P_WIDTH - 1] & ~O_C[P_WIDTH - 1]);
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = O_C[P_WIDTH - 1] == 1'b1;
            end
            ADDCU: begin
                // Add 'I_A' and 'I_B' and 1 and set to 'O_C' with carry status bit specified
                {O_STATUS[STATUS_INDEX_CARRY], O_C} = I_A + I_B + 1'b1;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            SUB: begin
                O_C = I_B - I_A;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] =
                (I_A[P_WIDTH - 1] != I_B[P_WIDTH - 1]) &
                (I_A[P_WIDTH - 1] == O_C[P_WIDTH - 1]);
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                // Only set the negative bit for signed subtraction
                if ($signed(I_B) < $signed(I_A))
                    O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b1;
                else
                    O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            SUBU: begin
                O_C = I_B - I_A;
                // Only set the low bit (and carry bit) for unsigned subtraction
                if (I_B > I_A) begin
                    O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                    O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                end
                else begin
                    O_STATUS[STATUS_INDEX_CARRY] = 1'b1;
                    O_STATUS[STATUS_INDEX_LOW] = 1'b1;
                end
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
            NOT: begin
                O_C = ~I_A;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            LSH: begin
                O_C = I_A << I_B;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            RSH: begin
                O_C = I_A >> I_B;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            ALSH: begin
                O_C = I_A <<< I_B;
                O_STATUS[STATUS_INDEX_CARRY] = 1'b0;
                O_STATUS[STATUS_INDEX_LOW] = 1'b0;
                O_STATUS[STATUS_INDEX_FLAG] = 1'b0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 1'b0;
            end
            ARSH: begin
                O_C = I_A >>> I_B;
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
    else begin
        O_C = 0;
        O_STATUS = 0;
    end

end
endmodule
