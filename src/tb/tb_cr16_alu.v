`timescale 1ps/1ps
//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu_tb
// Description: The CR16 ALU testbench
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module tb_cr16_alu();

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
integer k, l;
// Instantiate the Unit Under Test (UUT)
cr16_alu uut (
        .I_CLK(I_CLK),
        .I_ENABLE(I_ENABLE),
        .I_A(I_A),
        .I_B(I_B),
        .O_C(O_C),
        .I_OPCODE(I_OPCODE),
        .O_STATUS(O_STATUS)
    );

initial begin
    //   $monitor("I_op1 %0d, I_op2: %0d, O_dest: %0d, flags[4:0]:%b, time:%0d", I_op1, I_op2, O_dest, flags[4:0], $time);
    //Instead of the $display stmt in the loop, you could use just this
    //monitor statement which is executed everytime there is an event on any
    //signal in the argument list.

    // Initialize Inputs
    I_A  = 0;
    I_B  = 0;
    I_ENABLE = 1'b1;
	 I_CLK = 0;

    // Wait 100 ns for global reset to finish
    /*****
     // One vector-by-vector case simulation
     #10;
     Opcode = 2'b11;
     I_op1  = 4'b0010; I_op2  = 4'b0011;
     #10
     I_op1 = 4'b1111; I_op2 = 4'b 1110;
     //$display("I_op1: %b, I_op2: %b, O_dest:%b, flags[4:0]: %b, time:%d", I_op1, I_op2, O_dest, flags[4:0], $time);
     ****/


    //Simulate ADD, Opcode = 0
	 /*
    I_OPCODE = 4'b0000;

    for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if ($signed(O_C) != $signed(I_A) + $signed(I_B))
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
				
            if ((~I_A[15] & ~I_B[15] & O_C[15]) | (I_A[15] & I_B[15] & ~O_C[15]) && (O_STATUS[2] != 1'b1))
                $display("Signed Overflow not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C[15] == 1 && O_STATUS[4] != 1)
                $display("Neg bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
				//// Decide here if we really want to set the low bit or not.
            if ($signed(I_B) < $signed(I_A) && O_STATUS[1] != 1);
                //$display("Low bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[0] == 1)
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end
	 */
	 //Simulate ADDU, Opcode = 1
    I_OPCODE = 4'b0001;

    for(k = 0; k < 65_535; k = k + 1) begin
        I_A = k;

        for(l = 0; l < 65_535; l = l + 1) begin
            I_B = l;
            #2;

            if (O_C != I_A + I_B)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
				
            if (O_STATUS[2] == 1'b1)
                $display("Signed Overflow set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            //if ( O_C[15] == 1 && O_STATUS[4] == 1)
                //$display("Neg bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
				//// Decide here if we really want to set the low bit or not.
            if ($signed(I_B) < $signed(I_A) && O_STATUS[1] != 1);
                //$display("Low bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[1] == 0);
                //$display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end
    //$finish(2);

    // Add stimulus here

end

endmodule
