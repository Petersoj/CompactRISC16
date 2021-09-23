// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: tb_cr16_datapath_1
// Description: testbench to run the hard-coded program from the test FSM on
// the datapath and ALU integrated module.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//
module tb_cr16_datapath_1;

	reg tb_clk, tb_nrst, tb_enable;
	
	
	
	
	
	
	//////WIP/////////////
	
	always #100 tb_fsm_clk = ~tb_fsm_clk;
	
	integer i;
	
	initial begin
		//Setup clock and initial values.
		tb_fsm_clk = 0; #20;
		tb_fsm_rst = 1; #25;
		
		
		// Start the clock and check the output.
		for (i = 0; i < 16; i = i + 1)begin
			tb_S = i;
			tb_fsm_rst = 0; #20;
			tb_fsm_rst = 1; #2200;
		end
		
		$stop;		
	
	end

endmodule