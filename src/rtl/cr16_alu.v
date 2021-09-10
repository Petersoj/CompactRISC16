//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu
// Description: The CR16 ALU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_alu #(parameter integer P_WIDTH = 16)
       (input wire I_CLK,
        input wire I_ENABLE,
        input wire [3 : 0] I_OPCODE,
        input wire [P_WIDTH - 1 : 0] I_A,
        input wire [P_WIDTH - 1 : 0] I_B,
        output reg [P_WIDTH - 1 : 0] O_C,
        output reg [4 : 0] O_STATUS);

// Parameterized Opcodes
localparam integer
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
           ARSH = 14;

// Status register indicies for one-hot encoding
localparam integer
           STATUS_INDEX_CARRY = 0,
           STATUS_INDEX_LOW = 1,
           STATUS_INDEX_FLAG = 2,
           STATUS_INDEX_ZERO = 3,
           STATUS_INDEX_NEGATIVE = 4;

// Clock block
always @(posedge I_CLK) begin
    if (I_ENABLE) begin
        case (I_OPCODE)
            ADD: begin
                // Add 'I_A' and 'I_B' and set to 'O_C'
                O_C = I_A + I_B;
                // Do not set the Carry status bit for signed arithmetic
                O_STATUS[STATUS_INDEX_CARRY] = 0;
                // Do not set the Low status bit for signed arithmetic
                O_STATUS[STATUS_INDEX_LOW] = 0;
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
                O_STATUS[STATUS_INDEX_LOW] = 0;
                O_STATUS[STATUS_INDEX_FLAG] = 0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 0;
            end
            ADDC: begin
                // Add 'I_A' and 'I_B' and 1 and set to 'O_C'
                // This instruction is needed due to adding 'immediate high' numbers
                // in the event that an 'immediate low' addition instruction caused a carry.
                O_C = I_A + I_B + 1'b1;
                O_STATUS[STATUS_INDEX_CARRY] = 0;
                O_STATUS[STATUS_INDEX_LOW] = 0;
                O_STATUS[STATUS_INDEX_FLAG] =
                (~I_A[P_WIDTH - 1] & ~I_B[P_WIDTH - 1] & O_C[P_WIDTH - 1]) |
                (I_A[P_WIDTH - 1] & I_B[P_WIDTH - 1] & ~O_C[P_WIDTH - 1]);
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = O_C[P_WIDTH - 1] == 1'b1;
            end
            ADDCU: begin
                // Add 'I_A' and 'I_B' and 1 and set to 'O_C' with carry status bit specified
                {O_STATUS[STATUS_INDEX_CARRY], O_C} = I_A + I_B + 1;
                O_STATUS[STATUS_INDEX_LOW] = 0;
                O_STATUS[STATUS_INDEX_FLAG] = 0;
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = 0;
            end
            SUB: begin
                // Subtract 'I_A' from 'I_B' and set to 'O_C'
                O_C = I_B - I_A;
                O_STATUS[STATUS_INDEX_CARRY] = 0;
                O_STATUS[STATUS_INDEX_LOW] = 0;
                O_STATUS[STATUS_INDEX_FLAG] =
                (~I_A[P_WIDTH - 1] & ~I_B[P_WIDTH - 1] & O_C[P_WIDTH - 1]) |
                (I_A[P_WIDTH - 1] & I_B[P_WIDTH - 1] & ~O_C[P_WIDTH - 1]);
                O_STATUS[STATUS_INDEX_ZERO] = O_C == 0;
                O_STATUS[STATUS_INDEX_NEGATIVE] = O_C[P_WIDTH - 1] == 1'b1;
            end
            CMP: begin

            end
            CMPU: begin

            end
            AND: begin

            end
            OR: begin

            end
            XOR: begin

            end
            NOT: begin

            end
            LSH: begin

            end
            RSH: begin

            end
            ALSH: begin

            end
            ARSH: begin

            end
            default: begin

            end
        endcase
    end
end
endmodule
