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

// establish the clock signal to sync the test
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

    /*
     Flag encoding is as follows:
     STATUS_INDEX_CARRY = 0
     STATUS_INDEX_LOW = 1
     STATUS_INDEX_FLAG = 2
     STATUS_INDEX_ZERO = 3
     STATUS_INDEX_NEGATIVE = 4
    */

    // Initialize Inputs
    I_A  = 0;
    I_B  = 0;
    // Enable will be permanently high.
    I_ENABLE = 1'b1;
    I_CLK = 0;

    //Simulate ADD, Opcode = 0
    I_OPCODE = 4'b0000;
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


    //Simulate ADDU, Opcode = 1
    I_OPCODE = 4'b0001;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if ADDU failed
            if ((O_C != I_A + I_B) && O_STATUS[0] != 1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if the overflow bit is ever set. Overflow is reserved for signed operations.
            if (O_STATUS[2] == 1'b1)
                $display("Signed Overflow set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Negative bit should never be set on unsigned operation.
            if (O_STATUS[4] == 1)
                $display("1 Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if carry bit is not set when a carry occurs out of the MSB
            if ((O_STATUS[0] != 1) && ((i + j)  > 65_535))
                $display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b, i+j:%0d", I_A, I_B, O_C, O_STATUS[4:0], i+j);
        end
    end

    //Simulate ADDC, Opcode = 2
    I_OPCODE = 4'b0010;
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

    //Simulate ADDCU, Opcode = 3
    I_OPCODE = 3;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if ADDC produces incorrect result without implicit carry bit.
            if ((O_C != I_A + I_B + 1) && O_STATUS[0] != 1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if the overflow bit is ever set. Overflow is reserved for signed operations.
            if (O_STATUS[2] == 1)
                $display("Signed Overflow set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if negative bit is set on unsigned op.
            if (O_STATUS[4] == 1)
                $display("3 Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if carry occurs out of MSB and the Carry flag is not set.
            if ((O_STATUS[0] != 1) && ((i + j + 1) > 65_535))
                $display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate SUB, Opcode = 4
    I_OPCODE = 4;
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

    //Simulate SUBU, Opcode = 5
    I_OPCODE = 5;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            // Error if SUBU failed.
            if ((O_C != I_B - I_A) && (O_STATUS[0] != 1))
                $display("SUB Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            // Error if there was a borrow from the bit above the MSB and the Carry flag was not set.
            if ((I_B < I_A) && (O_STATUS[0] != 1))
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if result is 0 and flag not set.
            if ((O_C == 0) && (O_STATUS[3] != 1))
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Negative bit should never be set because answer is regarded as an unsigned number.
            if (O_STATUS[4] == 1)
                $display("Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            // Error if the low flag is not set when B is less than A.
            if ((I_B < I_A) && (O_STATUS[1] != 1))
                $display("Low bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate AND, Opcode = 6
    I_OPCODE = 6;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A & I_B))
                $display("AND failed: I_A: %b, I_B: %b, O_C: %b, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate OR, Opcode = 7
    I_OPCODE = 7;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A | I_B))
                $display("OR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate XOR, Opcode = 8
    I_OPCODE = 8;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A ^ I_B))
                $display("XOR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate NOT, Opcode = 9
    // NOTE: Only one loop is necessary because NOT doesn't involve the I_B register.
    I_OPCODE = 9;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        I_A = i;
        #2;
        if (O_C != ~I_A)
            $display("NOT failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
    end

    //Simulate LSH, Opcode = 10
    I_OPCODE = 10;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A << I_B))
                $display("LSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate RSH, Opcode = 11
    I_OPCODE = 11;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A >> I_B))
                $display("RSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate ALSH, Opcode = 12
    I_OPCODE = 12;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        I_A = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            I_B = j;
            #2;
            if (O_C != (I_A <<< I_B))
                $display("ALSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end

    //Simulate ARSH, Opcode = 13
    I_OPCODE = 13;
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
