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
	 
    I_OPCODE = 4'b0000;
/*
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
            if (O_STATUS[0] == 1)
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end
	 
	 */
	 /*
	 //Simulate ADDU, Opcode = 1
    I_OPCODE = 4'b0001;

    for(i = 0; i < 65_535; i = i + 1) begin
        I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;

            if ((O_C != I_A + I_B) && O_STATUS[0] != 1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
				
            if (O_STATUS[2] == 1'b1)
                $display("Signed Overflow set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[4] == 1)
                $display("Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ((O_STATUS[0] != 1) && ((i + j)  > 65_535))
                $display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b, i+j:%0d", I_A, I_B, O_C, O_STATUS[4:0], i+j);
        end
    end
	 */
	 /*
	 //Simulate ADDC, Opcode = 2	 
    I_OPCODE = 4'b0010;

    for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if ($signed(O_C) != $signed(I_A) + $signed(I_B) + 1'b1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
				
            if ((~I_A[15] & ~I_B[15] & O_C[15]) | (I_A[15] & I_B[15] & ~O_C[15]) && (O_STATUS[2] != 1'b1))
                $display("Signed Overflow not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C[15] == 1 && O_STATUS[4] != 1)
                $display("Neg bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[0] == 1)
                $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end
	 */ 
	 
	 //Simulate ADDCU, Opcode = 3
 /*   I_OPCODE = 3;

    for(i = 0; i < 65_535; i = i + 1) begin
        I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;

            if ((O_C != I_A + I_B + 1) && O_STATUS[0] != 1)
                $display("Test Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
				if (O_STATUS[2] == 1)
                $display("Signed Overflow set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1)
                $display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[4] == 1)
                $display("Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ((O_STATUS[0] != 1) && ((i + j + 1) > 65_535))
                $display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
        end
    end
	 
  */
/*
	  //Simulate SUB, Opcode = 4
	  I_OPCODE = 4;
	  for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != $signed(I_B) - $signed(I_A))
					 $display("SUB Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            if ((I_A[15] != I_B[15]) && (O_C[15] != I_B[15]) && (O_STATUS[2] != 1))
                $display("Signed Overflow set incorrectly: I_A: %b, I_B: %b, i: %0d, j: %0d, O_C: %b, j-i: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, j-i, O_STATUS[4:0]);
            if ( O_C == 0 && O_STATUS[3] != 1) 
					$display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[4] == 1  && O_C[15] != 1)
					$display("Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[1] == 1)
					$display("Carry bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            
        end
    end
*/
	
	  //Simulate SUBU, Opcode = 5
	  I_OPCODE = 5;
	  for(i = 0; i < 65_535; i = i + 1) begin
        I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;

            if ((O_C != I_B - I_A) && (O_STATUS[0] != 1))
					$display("SUB Failed: I_A: %0d, I_B: %0d, i:%0d, j%0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, i, j, O_C, O_STATUS[4:0]);
            if ((I_B < I_A) && (O_STATUS[0] != 1))
               $display("Carry bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if ((O_C == 0) && (O_STATUS[3] != 1))
					$display("Zero bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
            if (O_STATUS[4] == 1)
					$display("Neg bit set incorrectly: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
				if ((I_B < I_A) && (O_STATUS[1] != 1))
               $display("Low bit not set: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	  
	  
	  /*
	  //Simulate AND, Opcode = 6
	  I_OPCODE = 6;
	  for(i = 0; i < 65_535; i = i + 1) begin
         I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;
            if (O_C != (I_A & I_B))
					$display("AND failed: I_A: %b, I_B: %b, O_C: %b, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 */
	  /*
	  //Simulate OR, Opcode = 7
	  I_OPCODE = 7;
	  for(i = 0; i < 65_535; i = i + 1) begin
        I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A | I_B))
					$display("OR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 */
	  /*
	  //Simulate XOR, Opcode = 8
	  I_OPCODE = 8;
	  for(i = 0; i < 65_535; i = i + 1) begin
        I_A = i;

        for(j = 0; j < 65_535; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A ^ I_B))
					$display("XOR failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 */
	  /*
	  //Simulate NOT, Opcode = 9
	  I_OPCODE = 9;
	  for(i = 0; i < 65_535; i = i + 1) begin
       I_A = i;

        if (O_C != ~I_A)
					$display("NOT failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
    end
	 
	  
	  //Simulate LSH, Opcode = 10
	  I_OPCODE = 10;
	 for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A << I_B))
					$display("LSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 
	  
	  //Simulate RSH, Opcode = 11
	  I_OPCODE = 11;
	  for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A >> I_B))
					$display("RSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 
	  
	  //Simulate ALSH, Opcode = 12
	  I_OPCODE = 12;
	  for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A <<< I_B))
					$display("ALSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	 */
	  
	  //Simulate ARSH, Opcode = 13
	  I_OPCODE = 13;
	  for(i = -32_768; i < 32_767; i = i + 1) begin
        I_A = i;

        for(j = -32_768; j < 32_767; j = j + 1) begin
            I_B = j;
            #2;

            if (O_C != (I_A >>> I_B))
					$display("ARSH failed: I_A: %0d, I_B: %0d, O_C: %0d, flags[4:0]: %b", I_A, I_B, O_C, O_STATUS[4:0]);
					
        end
    end
	  
 //$finish(2);

    // Add stimulus here

end

endmodule
