// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: cr16_datapath
// Description: Top level module for the combination of the datapath with the alu.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_datapath(input wire [15:0] I_REG_ENABLE,
							input wire I_NRESET,
							input wire [3:0] I_OPCODE,
							input wire I_CLK,
							input wire I_ENABLE,
							input wire [3:0] I_READ_PORT_A_SEL,
							input wire [3:0] I_READ_PORT_B_SEL,
							input wire [15:0] I_IMMEDIATE,
							input wire I_IMM_SEL,
							output reg [15:0] O_WRITE_PORT,
							output reg [4:0] O_FLAGS);

	// Instantiate necessary wires and busses

	wire [4:0] flags;
	wire [15:0] bus_A;
	wire [15:0] bus_B;
	wire [15:0] reg_bus_B;
	wire [15:0] reg_data [15:0];
	wire [15:0] read_port_A [15:0];
	wire [15:0] read_port_B [15:0];
	wire [15:0] write_port;
	
	// Instantiate compatibility for immediates to be loaded onto bus B.
	mux_array imm_arr (reg_bus_B, I_IMMEDIATE, I_IMM_SEL, bus_B);

	assign O_WRITE_PORT = write_port;
		
	// Instantiate the regfile, flags register, alu, and muxes
	cr16_regfile REGFILE( 	.I_NRESET(I_NRESET),
									.I_CLK(I_CLK),
									.I_REG_BUS(write_port),
									.I_REG_ENABLE(I_REG_ENABLE),
									.O_REG_DATA(reg_data));

	cr16_flags FLAGS(	.I_ENABLE(I_ENABLE),
							.I_NRESET(I_NRESET),
							.I_CLK(I_CLK),
							.I_FLAGS(flags),
							.O_FLAGS(O_FLAGS));

	cr16_alu ALU(	.I_ENABLE(I_ENABLE),
						.I_OPCODE(I_OPCODE),
						.I_A(bus_A),
						.I_B(bus_B),
						.O_C(write_port),
						.O_STATUS(flags));
						
	// Instantiate decoders to convert REG_ENABLE to a pair of sequential decimal numbers
	// to be used as selectors for the mux arrays.



	// Generate statement to connect the nth bit of each register to the nth row of the 
	// read ports A and B. 
	genvar reg_bit_idx;
	genvar reg_reg_idx;

	generate
		for (reg_reg_idx = 0; reg_reg_idx < 16; reg_reg_idx++) begin:make_read_ports
			for (reg_bit_idx = 0; reg_bit_idx < 16; reg_bit_idx++) begin:make_read_ports_2
				assign read_port_A[reg_bit_idx][reg_reg_idx] = reg_data[reg_reg_idx][reg_bit_idx];
				assign read_port_B[reg_bit_idx][reg_reg_idx] = reg_data[reg_reg_idx][reg_bit_idx];
			end
		end
	endgenerate

	// Generate statement to connect the register data to the arrays of muxes. Mux n has 16
	// inputs that are the same bit of each register r0-r15. The 16x16 structure is used to 
	// pass only 1 register value at a time to each port of the ALU.
	genvar mux_A_idx;

	generate
		for (mux_A_idx = 0; mux_A_idx < 16; mux_A_idx++) begin:make_muxes_A
			mux16_1 
			i_mux16_1
				(	.INPUT(read_port_A[mux_A_idx][15:0]),
					.s(I_READ_PORT_A_SEL),
					.OUT(bus_A[mux_A_idx]));
		end
	endgenerate
	
	// Same behavior as above for bus B. This assignment will be ignored if 
	// the immediate selector is active.
	genvar mux_B_idx;

	generate
		for (mux_B_idx = 0; mux_B_idx < 16; mux_B_idx++) begin:make_muxes_B
			mux16_1 
			i_mux16_1
				(	.INPUT(read_port_B[mux_B_idx][15:0]),
					.s(I_READ_PORT_B_SEL),
					.OUT(reg_bus_B[mux_B_idx]));
		end
	endgenerate
		
		
		
		
endmodule
			
			
			
			