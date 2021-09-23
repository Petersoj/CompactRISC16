//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: cr16_datapath_test_controller
// Description: Test controller for the datapath integrated with the ALU. Integrates
// the FSM-Hard-Coded program.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_datapath_test_controller (	input wire I_CLK,
													input wire I_NRST,
													input wire I_ENABLE,
													output [4:0] led_flags,
													output wire [6:0] O_7_SEGMENT_DISPLAY_0,
												   output wire [6:0] O_7_SEGMENT_DISPLAY_1,
												   output wire [6:0] O_7_SEGMENT_DISPLAY_2,
												   output wire [6:0] O_7_SEGMENT_DISPLAY_3);
													

													
	// Instantiate wires to connect the FSM to the datapath and the 7seg.
	wire [15:0]reg_enable;
	wire [3:0] read_a_sel;
	wire [3:0] read_b_sel;
	wire [3:0] opcode;
	wire [15:0] write_port;

													
	// Hard-Coded programs in FSM									
	cr16_test1_fsm FSM( 	.I_CLK(I_CLK), 
							.I_NRESET(I_NRESET),
							.I_ENABLE(I_ENABLE),
							.O_OPCODE(opcode),
							.O_READ_PORT_A_SEL(read_a_sel),
							.O_READ_PORT_B_SEL(read_b_sel),
							.O_REG_ENABLE(reg_enable),
							.O_PRELOAD_IMM(write_port));	

	// Datapath module
	cr16_datapath DATAPATH(	.I_REG_ENABLE(reg_enable),
									.I_NRESET(I_NRESET),
									.I_OPCODE(opcode),
									.I_CLK(I_CLK),
									.I_ENABLE(I_ENABLE),
									.I_READ_PORT_A_SEL(read_a_sel),
									.I_READ_PORT_B_SEL(read_b_sel),
									.O_WRITE_PORT(write_port),
									.O_FLAGS(led_flags));
		
	// 7-seg integration for the output of the write port.
	
	seven_segment_hex_mapping seg1(.I_VALUE(write_port[3:0]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_0));
	seven_segment_hex_mapping seg2(.I_VALUE(write_port[7:4]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_1));
	seven_segment_hex_mapping seg3(.I_VALUE(write_port[11:8]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_2));
	seven_segment_hex_mapping seg4(.I_VALUE(write_port[15:12]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_3));

													
													
endmodule
