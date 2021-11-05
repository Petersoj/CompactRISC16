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

reg clk;

// Inputs
reg [3:0] opcode;
reg [15:0] a;
reg [15:0] b;

// Outputs
wire [15:0] c;
wire [4:0] status;

// Parameterized Opcodes from 'rtl/cr16/alu.v'
localparam [3:0]
           ADD  = 4'd0,
           ADDC = 4'd1,
           MUL  = 4'd2,
           SUB  = 4'd3,
           NOT  = 4'd4,
           AND  = 4'd5,
           OR   = 4'd6,
           XOR  = 4'd7,
           LSH  = 4'd8,
           RSH  = 4'd9,
           ALSH = 4'd10,
           ARSH = 4'd11;

// Establish the clock signal to sync the test
always #1 clk = ~clk;

integer i, j, expected;

// Instantiate the Unit Under Test (UUT)
alu uut
    (.I_OPCODE(opcode),
     .I_A(a),
     .I_B(b),
     .O_C(c),
     .O_STATUS(status));

initial begin
    $display("\n================================================================");
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
    a  = 0;
    b  = 0;
    clk = 0;

    $display("\n================================================================");
    $display("Testing ADD");
    $display("================================================================");

    // Simulate ADD
    opcode = ADD;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            // Error if ADD failed
            if ($signed(c) != $signed(a) + $signed(b))
                $display("Test Failed: a: %0d, b: %0d, i:%0d, j%0d, c: %0d, flags[4:0]: %b", a, b, i, j, c, status[4:0]);
            // Error if signed overflow occured but flag "O" was not set.
            if ((~a[15] & ~b[15] & c[15]) | (a[15] & b[15] & ~c[15]) && (status[2] != 1'b1))
                $display("Signed Overflow not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if result is 0 and flag not set.
            if (c == 0 && status[3] != 1)
                $display("Zero bit not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if the answer is negative and the negative bit was not set.
            if (status[4] != (((a[15] != b[15]) & (c[15] == 1'b1)) | ((a[15] == 1'b1) & (b[15] == 1'b1))))
                $display("0 Neg bit not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            expected = (b + a) >> 16;
            if (status[0] != expected)
                $display("Carry bit set incorrectly: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing ADDC");
    $display("================================================================");

    // Simulate ADDC
    opcode = ADDC;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            // Error if ADDC fails to produce correct result.
            if ($signed(c) != $signed(a) + $signed(b) + 1'b1)
                $display("Test Failed: a: %0d, b: %0d, i:%0d, j%0d, c: %0d, flags[4:0]: %b", a, b, i, j, c, status[4:0]);
            // Error if signed overflow occurs and Overflow flag not set.
            if ((~a[15] & ~b[15] & c[15]) | (a[15] & b[15] & ~c[15]) && (status[2] != 1'b1))
                $display("Signed Overflow not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if result is 0 and flag not set.
            if (c == 0 && status[3] != 1)
                $display("Zero bit not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            if (status[4] != ((a[15] != b[15] & c[15] == 1'b1) | (a[15] == 1'b1 & b[15] == 1'b1)))
                $display("2 Neg bit not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if the carry bit is ever set. Carry is reserved for unsigned operations.
            expected = (b + a + 1'b1) >> 16;
            if (status[0] != expected)
                $display("Carry bit set incorrectly: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing MUL");
    $display("================================================================");

    // Simulate MUL
    opcode = MUL;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            // Error if MUL failed
            if ($signed(c) != $signed(a) * $signed(b))
                $display("Test Failed: a: %0d, b: %0d, i:%0d, j%0d, c: %0d, flags[4:0]: %b", a, b, i, j, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing SUB");
    $display("================================================================");

    // Simulate SUB
    opcode = SUB;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            // Error if SUB failed.
            if ($signed(c) != $signed(b) - $signed(a))
                $display("SUB Failed: a: %0d, b: %0d, i:%0d, j%0d, c: %0d, flags[4:0]: %b", a, b, i, j, c, status[4:0]);
            // Error if signed overflow ocurred and the Overflow bit was not set.
            if ((a[15] != b[15]) && (c[15] != b[15]) && (status[2] != 1))
                $display("Signed Overflow set incorrectly: a: %b, b: %b, i: %0d, j: %0d, c: %b, j-i: %0d, flags[4:0]: %b", a, b, i, j, c, j-i, status[4:0]);
            // Error if result is 0 and flag not set.
            if (c == 0 && status[3] != 1)
                $display("Zero bit not set: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if A greater than B and Negative flag not set.
            if (($signed(b) > $signed(a)) && status[4] != 1)
                $display("4 Neg bit set incorrectly: a: %0d, b: %0d, c: %b, flags[4:0]: %b", a, b, c, status[4:0]);
            // Error if the carry bit is ever set. Carry is reserved for unsigned operations.
            if (b > a != status[1])
                $display("Carry bit set incorrectly: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", $signed(a), $signed(b), $signed(c), status[4:0]);

        end
    end

    $display("\n================================================================");
    $display("Testing AND");
    $display("================================================================");

    // Simulate AND
    opcode = AND;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        a = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            b = j;
            #2;
            if (c != (a & b))
                $display("AND failed: a: %b, b: %b, c: %b, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing OR");
    $display("================================================================");

    // Simulate OR
    opcode = OR;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        a = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            b = j;
            #2;
            if (c != (a | b))
                $display("OR failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing XOR");
    $display("================================================================");

    // Simulate XOR
    opcode = XOR;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        a = i;
        for(j = 0; j < 65_535; j = j + 1_024) begin
            b = j;
            #2;
            if (c != (a ^ b))
                $display("XOR failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing NOT");
    $display("================================================================");

    // Simulate NOT
    // Note: Only one loop is necessary because NOT doesn't involve the b register.
    opcode = NOT;
    for(i = 0; i < 65_535; i = i + 1_024) begin
        a = i;
        #2;
        if (c != ~a)
            $display("NOT failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
    end

    $display("\n================================================================");
    $display("Testing LSH");
    $display("================================================================");

    // Simulate LSH
    opcode = LSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            a = a & 'hF;
            expected = b << a;
            if (c != expected)
                $display("LSH failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing RSH");
    $display("================================================================");

    // Simulate RSH
    opcode = RSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            a = a & 'hF;
            expected = b >> a;
            if (c != expected)
                $display("RSH failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing ALSH");
    $display("================================================================");

    // Simulate ALSH
    opcode = ALSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            a = a & 'hF;
            expected = b <<< a;
            if (c != expected)
                $display("ALSH failed: a: %0d, b: %0d, c: %0d, flags[4:0]: %b", a, b, c, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("Testing ARSH");
    $display("================================================================");

    // Simulate ARSH
    opcode = ARSH;
    for(i = -32_768; i < 32_767; i = i + 1_024) begin
        a = i;
        for(j = -32_768; j < 32_767; j = j + 1_024) begin
            b = j;
            #2;
            a = a & 'hF;
            expected = b >>> a;
            if (c != expected)
                $display("ARSH failed: a: %0d, b: %0d, c: %0d, expected: %0d, flags[4:0]: %b", a, b, c, expected, status[4:0]);
        end
    end

    $display("\n================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
