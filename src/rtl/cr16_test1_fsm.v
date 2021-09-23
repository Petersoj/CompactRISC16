// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: cr16_test1_fsm
// Description: FSM for the datapath and ALU of the CR16 CPU. Demonstrates read, write, and update
// functionality for registers 0-7 using the Fibonacci sequence.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_test1_fsm (input wire I_CLK,
					   input wire I_NRESET,
					   input wire I_ENABLE,
					   output reg [3:0] O_OPCODE,
					   output reg [3:0] O_READ_PORT_A_SEL,
					   output reg [3:0] O_READ_PORT_B_SEL,
					   output reg [15:0] O_REG_ENABLE,
					   output reg [15:0] O_PRELOAD_IMM);
								
	// Declare the next state.
	reg [3:0] NS;
	
	// Parameter aliases for states.
	parameter [3:0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, S5 = 4'b0101,
						 S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001;

	// Next state and sequential logic.
	always @ (negedge I_NRESET or posedge I_CLK) begin
	
		if(~I_NRESET)
			NS <= S0;
			
		else 
			case (NS)
				S0: NS <= S1;
				S1: NS <= S2;
				/*S2: NS <= S3;
				S3: NS <= S4;
				S4: NS <= S5;
				S5: NS <= S6;
				S6: NS <= S7;
				S7: NS <= S8;
				S8: NS <= S9;
				S9: NS <= S9;*/
				default: NS <= S0;
			endcase
	end
	
	// The FSM forms a program in two parts:
	//
	// 1) Successively write to and read from registers 0-7 to compute and store the first 8
	//    elements of the Fibonacci sequence. After states 0-7, the values in the registers should
	//    appear as:
	//
	//     1   1   2   3   5   8  13  21
	//    r0  r1  r2  r3  r4  r5  r6  r7
	//
	// 2) Add 1 to registers 0-7. After states 8-15, the values in the registers should appear as:
	//
	//     2   2   3   4   6   9  14  22
	//    r0  r1  r2  r3  r4  r5  r6  r7
	//
	always @ (NS) begin
		case (NS)
			S0:
			// Load 1 into r0.
			S0: begin
				O_OPCODE = 4'b0001;          // Use unsigned addition.
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0000; // READ_PORTs are binary encoded.
				O_REG_ENABLE = 4'h0001;      // REG_ENABLE is 1-hot encoded.
				O_PRELOAD_IMM = 4'h0001;     // Use immediate value 1.
			end
			// Load 1 into r1.
			S1: begin
				O_OPCODE = 4'b0001;
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0000;
				O_REG_ENABLE = 4'h0002;
				O_PRELOAD_IMM = 4'h0001;
			end
			// Add r0 + r1 and store into r2.
			S2: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0001;
				O_REG_ENABLE = 4'h0002;
				O_PRELOAD_IMM = 4'h0000; // Use immediate value 0, since it is unused by this point.
			end
			// Add r1 + r2 and store into r3.
			S3: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0001;
				O_READ_PORT_B_SEL = 4'b0010;
				O_REG_ENABLE = 4'h0004;
				O_PRELOAD_IMM = 4'h0000;
			end
			// Add r2 + r3 and store into r4.
			S4: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0010;
				O_READ_PORT_B_SEL = 4'b0011;
				O_REG_ENABLE = 4'h0008;
				O_PRELOAD_IMM = 4'h0000;
			end
			// Add r3 + r4 and store into r5.
			S5: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0011;
				O_READ_PORT_B_SEL = 4'b0100;
				O_REG_ENABLE = 4'h0010;
				O_PRELOAD_IMM = 4'h0000;
			end
			// Add r4 + r5 and store into r6.
			S6: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0100;
				O_READ_PORT_B_SEL = 4'b0101;
				O_REG_ENABLE = 4'h0020;
				O_PRELOAD_IMM = 4'h0000;
			end
			// Add r5 + r6 and store into r7.
			S7: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0101;
				O_READ_PORT_B_SEL = 4'b0110;
				O_REG_ENABLE = 4'h0040;
				O_PRELOAD_IMM = 4'h0000;
			end
			// Add 1 to r0.
			S8: begin
				O_OPCODE = 0'b0001
				O_READ_PORT_A_SEL = 4'b0000;
				O_READ_PORT_B_SEL = 4'b0000;
				O_REG_ENABLE = 4'h0000;
				O_PRELOAD_IMM = 4'h0001;
			end
		endcase
	end
	
endmodule
