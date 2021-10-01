`timescale 1ps/1ps
//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/30/2021
// Module Name: bram_tb
// Description: Testbench for BRAM memory, must use a file to initialize the first 8 memory
// addresses to numbers 1-8.
//

module bram_tb();
 
   reg I_CLK;
   reg [15:0] I_DATA_A, I_DATA_B;
   reg [9:0] I_ADDRESS_A, I_ADDRESS_B;
   reg I_WRITE_ENABLE_A, I_WRITE_ENABLE_B;
   reg [15:0] O_DATA_A, O_DATA_B;
 
	// establish the clock signal to sync the test
   always #1 I_CLK = ~I_CLK;
 
   bram uut(.I_CLK(I_CLK), 
	         .I_DATA_A(I_DATA_A), 
				.I_DATA_B(I_DATA_B),
				.I_ADDRESS_A(I_ADDRESS_A),
				.I_ADDRESS_B(I_ADDRESS_B),
				.I_WRITE_ENABLE_A(I_WRITE_ENABLE_A), 
				.I_WRITE_ENABLE_B(I_WRITE_ENABLE_B), 
				.O_DATA_A(O_DATA_A), 
				.O_DATA_B(O_DATA_B));
 
 
	integer i, j;
	
   initial begin

	   // Initialize enables and address pointers.
		I_CLK = 0;
		I_ADDRESS_A = 10'b0000000000;
		I_ADDRESS_B = 10'b0000000000;
		I_WRITE_ENABLE_A = 1'b0;
		I_WRITE_ENABLE_B = 1'b0;
		I_DATA_A = 16'h0000;
		I_DATA_B = 16'h0000;
		
		
		$display("================================================================");
      $display("Test 1: Read sequential values addresses 0-7 on port A.");
      $display("================================================================\n");
		// Read data on one port.
		for( i = 0; i < 8; i = i + 1) begin
			I_ADDRESS_A = i;
			#2;
			if ( O_DATA_A != (i+1))
				$display("Initial read failed. Got: %b, Expected: %b.", O_DATA_A, i);
			
		end
		
		// Read data on two ports at once.
		I_ADDRESS_A = 10'b0000000000; // Start at index 0
		I_ADDRESS_B = 10'b0000000001; // Start at index 2
		
		$display("================================================================");
      $display("Test 2: Read sequential values addresses 0-5 on port A and simultaneously read 2-7 on port B.");
      $display("================================================================\n");
		for( i = 0; i < 6; i = i + 1) begin
			I_ADDRESS_A = i;
			I_ADDRESS_B = I_ADDRESS_B + 1;
			#2;
			if ( O_DATA_A != (i+1))
				$display("Initial read A failed. Got: %b, Expected: %b.", O_DATA_A, i);
		   if ( O_DATA_B != (i+3))
				$display("Initial read B failed. Got: %b, Expected: %b.", O_DATA_B, i);
			
		end
			
		I_ADDRESS_A = 10'b0000000000;
		I_ADDRESS_B = 10'b0000000000;
		I_WRITE_ENABLE_B = 1'b0;
		
		$display("================================================================");
      $display("Test 3: Write incrementing i*2 into data addresses 0-7 using port A, read them on port B to verify correctness.");
      $display("================================================================\n");
		// Write 2*i into bram
		for( i = 0; i < 8; i = i + 1) begin
			I_WRITE_ENABLE_A = 1'b0;
			I_DATA_A = i * 2;
			I_ADDRESS_A = i;
			#2;
			I_WRITE_ENABLE_A = 1'b1;
			#2;
		end
		I_WRITE_ENABLE_A = 1'b0;
		
		// Check if bram was wrote into correctly
		for( i = 0; i < 8; i = i + 1) begin
			I_ADDRESS_B = i;
			#2;
		   if ( O_DATA_B != (i*2))
				$display("Bram write failed. Got: %b, Expected: %b.", O_DATA_B, i*2);
			
		end
		
		I_ADDRESS_A = 10'b0000000000;
		I_ADDRESS_B = 10'b0000000000;
		I_WRITE_ENABLE_A = 1'b0;
		
		$display("================================================================");
      $display("Test 4: Write incrementing i*2 into data addresses 0-7 using port B, read them on port A to verify correctness.");
      $display("================================================================\n");
		// Write 3*i into bram
		for( i = 0; i < 8; i = i + 1) begin
			I_WRITE_ENABLE_B = 1'b0;
			I_DATA_B = i * 3;
			I_ADDRESS_B = i;
			#2;
			I_WRITE_ENABLE_B = 1'b1;
			#2;
		end
		I_WRITE_ENABLE_B = 1'b0;
		
		// Check if bram was wrote into correctly
		for( i = 0; i < 8; i = i + 1) begin
			I_ADDRESS_A = i;
			#2;
		   if ( O_DATA_A != (i*3))
				$display("Bram write failed. Got: %b, Expected: %b.", O_DATA_A, i*3);
			
		end
			
	 
		$stop();

	end

endmodule
	
 
 
 
 
 