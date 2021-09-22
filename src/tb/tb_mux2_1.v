`timescale 1ps/1ps

module tb_mux2_1();

// Inputs
reg [1:0] I_X;
reg s;

// Outputs
wire O_Y;

integer i, j;
// Instantiate the Unit Under Test (UUT)
mux2_1 uut(
				 .INPUT(I_X),
             .s(s),
             .OUT(O_Y)
         );
			
	initial begin
		
		#20;
		for( j = 0; j < 2; j = j + 1) begin	
		s = j;
			for( i = 0; i < 4; i = i + 1) begin
				#1;
				I_X = i;
				#2;
				if ( O_Y != I_X[j])
					$display("Test Failed: I_X: %b, s: %b, O_Y: %b, i: %b, j:%b", I_X, s, O_Y, i, j);
				
			end
		end
	end
endmodule
