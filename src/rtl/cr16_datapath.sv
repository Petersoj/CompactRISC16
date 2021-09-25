//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: cr16_datapath
// Description: Instantiates and connects the regfile, ALU, and flag register and allows for immediate inputs.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_CLK              the clock signal
// @param I_ENABLE           the enable signal
// @param I_NRESET           the active-low reset signal
// @param I_REG_WRITE_ENABLE one-hot encoded vector to specify which register to write result data to
// @param I_REG_A_SELECT     decimal value of regfile register for the 'A' ALU input
// @param I_REG_B_SELECT     decimal value of regfile register for the 'B' ALU input
// @param I_IMMEDIATE_SELECT 1 to select use the 'I_IMMEDIATE' value as the 'A' ALU input, 0 to use the regfile 'I_REG_A_SELECT'
// @param I_IMMEDIATE        the immediate value as the 'A' ALU input
// @param I_OPCODE           the ALU opcode
// @param O_RESULT_BUS       the output of the ALU and the input value to the regfile
// @param O_STATUS_FLAGS     the status flags of the ALU
module cr16_datapath(input wire I_CLK,
                     input wire I_ENABLE,
                     input wire I_NRESET,
                     input wire [15:0] I_REG_WRITE_ENABLE,
                     input wire [3:0] I_REG_A_SELECT,
                     input wire [3:0] I_REG_B_SELECT,
                     input wire I_IMMEDIATE_SELECT,
                     input wire [15:0] I_IMMEDIATE,
                     input wire [3:0] I_OPCODE,
                     output reg [15:0] O_RESULT_BUS,
                     output reg [4:0] O_STATUS_FLAGS);

wire [15:0] regfile_data [15:0];            // Output wire matrix of the register file
wire [15:0] regfile_data_transposed [15:0]; // Transposed output wire matrix of the register file
wire [15:0] regfile_a;                      // 'I_REG_A_SELECT' muxed output of regfile
wire [15:0] regfile_b;                      // 'I_REG_B_SELECT' muxed output of regfile
wire [15:0] alu_input_a;                    // 'A' input to ALU
wire [15:0] alu_input_b;                    // 'B' input to ALU
wire [15:0] result_bus;                     // Output of ALU and input data to regfile
wire [4:0] alu_status_flags;                // Output of ALU flags which are connected to flag register

assign O_RESULT_BUS = result_bus;
assign alu_input_b = regfile_b; // This assigment determines which ALU input is not muxed with the 'I_IMMEDIATE'

// Instantiate a mux to select between the 'A' register of the regfile or the immediate value
mux_array i_mux_array(.sel(I_IMMEDIATE_SELECT),
                      .a(regfile_a),
                      .b(I_IMMEDIATE),
                      .o(alu_input_a));

// Instantiate the regfile
cr16_regfile i_cr16_regfile(.I_NRESET(I_NRESET),
                            .I_CLK(I_CLK),
                            .I_REG_BUS(result_bus),
                            .I_REG_ENABLE(I_REG_WRITE_ENABLE),
                            .O_REG_DATA(regfile_data));

// Instantiate the ALU
cr16_alu i_cr16_alu(.I_ENABLE(I_ENABLE),
                    .I_OPCODE(I_OPCODE),
                    .I_A(alu_input_a),
                    .I_B(alu_input_b),
                    .O_C(result_bus),
                    .O_STATUS(alu_status_flags));

// Instantiate the ALU status flag register to hold status flags every clock cycle
cr16_flags i_cr16_flags(.I_ENABLE(I_ENABLE),
                        .I_NRESET(I_NRESET),
                        .I_CLK(I_CLK),
                        .I_FLAGS(alu_status_flags),
                        .O_FLAGS(O_STATUS_FLAGS));

// The following generate block will transpose the 'regfile_data' wire matrix and assigns the 'regfile_data_transposed'
// wire matrix so that the the nth bits of every register are in a single row.
genvar reg_reg_idx;
genvar reg_bit_idx;
generate
    for (reg_reg_idx = 0; reg_reg_idx < 16; reg_reg_idx++) begin: gen_reg_reg_idx
        for (reg_bit_idx = 0; reg_bit_idx < 16; reg_bit_idx++) begin: gen_reg_bit_idx
            assign regfile_data_transposed[reg_bit_idx][reg_reg_idx] = regfile_data[reg_reg_idx][reg_bit_idx];
        end
    end
endgenerate

// The following two generate blocks will multiplex the 'regfile_data_transposed' wire matrix with the
// corresponding 'A' or 'B' register selectors.
genvar a_bit_idx;
generate
    for (a_bit_idx = 0; a_bit_idx < 16; a_bit_idx++) begin:gen_a_bit_muxes
        mux16_1 i_mux16_1(.INPUT(regfile_data_transposed[a_bit_idx]),
                          .s(I_REG_A_SELECT),
                          .OUT(regfile_a[a_bit_idx]));
    end
endgenerate
genvar b_bit_idx;
generate
    for (b_bit_idx = 0; b_bit_idx < 16; b_bit_idx++) begin:gen_b_bit_muxes
        mux16_1 i_mux16_1(.INPUT(regfile_data_transposed[b_bit_idx]),
                          .s(I_REG_B_SELECT),
                          .OUT(regfile_b[b_bit_idx]));
    end
endgenerate
endmodule
