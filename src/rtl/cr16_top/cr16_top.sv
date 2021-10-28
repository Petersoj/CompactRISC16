//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/27/2021
// Module Name: cr16
// Description: The top-level module for synthesizing the CompactRISC16 (CR16) processor with 
// an integrated FSM and instruction decoder along with an instantiated datapath (containing
// the ALU and regfile), and program counter. This processor is integrated with the BRAM 
// memory module, which allows for the execution of preloaded machine code files according to
// our custom ISA.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_top #( parameter P_BRAM_INIT_FILE = "",
                   parameter integer P_DATA_WIDTH = 16)
                 ( input I_CLK,
                   input I_NRESET,
						 input I_ENABLE,
						 input I_BRAM_WRITE_ENABLE_B,
						 input [9:0] I_BRAM_ADDRESS_B,
						 input [P_DATA_WIDTH - 1:0] I_BRAM_DATA_B,
						 output [P_DATA_WIDTH - 1:0] O_BRAM_DATA_B,
						 output wire [4:0] O_LED_FLAGS,
                   output wire [6:0] O_7_SEGMENT_DISPLAY [3:0]);
						
						
	wire [P_DATA_WIDTH - 1:0] data_to_mem_A;
	wire [P_DATA_WIDTH - 1:0] mem_to_data_A;
	wire [9:0] address_A;
	wire write_enable_A;
	
						
	bram #(.P_BRAM_INIT_FILE(P_BRAM_INIT_FILE),
	       .P_BRAM_INIT_FILE_START_ADDRESS(-1),
          .P_BRAM_INIT_FILE_END_ADDRESS(-1),
          .P_DATA_WIDTH(16),
          .P_ADDRESS_WIDTH(10))
	      (.I_CLK(I_CLK),
          .I_DATA_A(data_to_mem_A), 
			 .I_DATA_B(I_BRAM_DATA_B),
          .I_ADDRESS_A(address_A),
			 .I_ADDRESS_B(I_BRAM_ADDRESS_B),
          .I_WRITE_ENABLE_A(write_enable_A),
			 .I_WRITE_ENABLE_B(I_BRAM_WRITE_ENABLE_B),
          .O_DATA_A(mem_to_data_A), 
			 .O_DATA_B(O_BRAM_DATA_B));
			
	cr16 ();
		
   // 7-seg integration for the output of the write port.
   seven_segment_hex_mapping i_display_0(.I_VALUE(write_port[3:0]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
   seven_segment_hex_mapping i_display_1(.I_VALUE(write_port[7:4]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
   seven_segment_hex_mapping i_display_2(.I_VALUE(write_port[11:8]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
   seven_segment_hex_mapping i_display_3(.I_VALUE(write_port[15:12]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));

	// We can possibly add a clock divider here so we can test 
	// execution of the program slowly...				


endmodule
