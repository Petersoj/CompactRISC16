//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: alu_tb
// Description: A testbench for the CR16 ALU.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

`timescale 1ps/1ps

module alu_tb();

// Inputs
reg [15:0] I_A;
reg [15:0] I_B;
reg [3:0] I_OPCODE;
reg I_ENABLE;
reg I_CLK;

// Outputs
wire [15:0] O_C;
wire [4:0] O_STATUS;

// Parameterized Opcodes from 'rtl/cr16/alu.v'
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

// Establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

integer i, j;

// Instantiate the Unit Under Test (UUT)
alu uut
    (.I_ENABLE(I_ENABLE),
     .I_A(I_A),
     .I_B(I_B),
     .O_C(O_C),
     .I_OPCODE(I_OPCODE),
     .O_STATUS(O_STATUS));

initial begin
    $display("================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    // The testbench will use a series of nested "for" loops to work through a fairly exhaustive set
    // of numbers for each opcode. Operations that support signed operations will loop from the maximum
    // negative to positive value that can be represented with 16-bit numbers. Each iteration of the
    // loop tests the correct behavior of the operation and the correct setting of the status flags.

    // Flag encoding is as follows:
    // STATUS_INDEX_CARRY = 0
    // STATUS_INDEX_LOW = 1
    // STATUS_INDEX_FLAG = 2
    // STATUS_INDEX_ZERO = 3
    // STATUS_INDEX_NEGATIVE = 4

    // Initialize Inputs
    I_A  = 0;
    I_B  = 0;
    I_ENABLE = 1'b1; // Enable will be permanently high.
    I_CLK = 0;

    // Simulate ADD
    I_OPCODE = ADD;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if ADD failed
            if ($signed(O_C) != $signed(I_A) + $signed(I_B))
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if signed overflow occured but flag "O" was not set.
            if ((~I_A[15] & ~I_B[15] & O_C[15]) | (I_A[15] & I_B[15] & ~O_C[15]) && (O_STATUS[2] != 1'b1))
                $display("Signed Overflow not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if the answer is negative and the negative bit was not set.
            if ( O_C[15] == 1 && O_STATUS[4] != 1)
                $display("0 Neg bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if the carry bit is ever set. Carry is reserved for unsigned operations.
            if (O_STATUS[0] == 1)
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate ADDC
    I_OPCODE = ADDC;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if ADDC fails to produce correct result.
            if ($signed(O_C) != $signed(I_A) + $signed(I_B) + 1'b1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if signed overflow occurs and Overflow flag not set.
            if ((~I_A[15] & ~I_B[15] & O_C[15]) | (I_A[15] & I_B[15] & ~O_C[15]) && (O_STATUS[2] != 1'b1))
                $display("Signed Overflow not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C[15] == 1 && O_STATUS[4] != 1)
                $display("2 Neg bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if the carry bit is ever set. Carry is reserved for unsigned operations.
            if (O_STATUS[0] == 1)
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate SUB
    I_OPCODE = SUB;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if SUB failed.
            if (O_C != $signed(I_B) - $signed(I_A))
                $display("SUB Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if signed overflow ocurred and the Overflow bit was not set.
            if ((I_A[15] != I_B[15]) && (O_C[15] != I_B[15]) && (O_STATUS[2] != 1))
                $display("Signed Overflow set incorrectly: I_A: %b, I_B: %b, i: %0d, j: %0d, O_C: %b, j-i: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, j-i, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if A greater than B and Negative flag not set.
            if (($signed(I_B) < $signed(I_A)) && O_STATUS[4] != 1)
                $display("4 Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %b, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if the carry bit is ever set. Carry is reserved for unsigned operations.
            if (O_STATUS[1] == 1)
                $display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);

        end
    end

    // Simulate MUL
    I_OPCODE = MUL;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if MUL failed
            if ($signed(O_C) != $signed(I_A) * $signed(I_B))
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate AND
    I_OPCODE = AND;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A & I_B))
                $display("AND failed: I_A: %b, I_B: %b, O_C: %b, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate OR
    I_OPCODE = OR;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A | I_B))
                $display("OR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate XOR
    I_OPCODE = XOR;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A ^ I_B))
                $display("XOR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate NOT
    // Note: Only one loop is necessary because NOT doesn't involve the I_B register.
    I_OPCODE = NOT;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        #2;
        if (O_C != ~I_A)
            $display("NOT failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
    end

    // Simulate LSH
    I_OPCODE = LSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A << I_B))
                $display("LSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate RSH
    I_OPCODE = RSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A >> I_B))
                $display("RSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate ALSH
    I_OPCODE = ALSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A <<< I_B))
                $display("ALSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    // Simulate ARSH
    I_OPCODE = ARSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A >>> I_B))
                $display("ARSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    $display("================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
