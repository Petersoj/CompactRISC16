//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: datapath
// Description: Instantiates and connects the regfile, ALU, and flag register and allows for immediate inputs.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_CLK              the clock signal
// @param I_ENABLE           the enable signal
// @param I_NRESET           the active-low reset signal
// @param I_REG_WRITE_ENABLE one-hot encoded vector to specify which register to write result data to
// @param I_REG_A_SELECT     decimal value of regfile register for the 'A' ALU input
// @param I_REG_B_SELECT     decimal value of regfile register for the 'B' ALU input
// @param I_IMMEDIATE_SELECT 1 to use the 'I_IMMEDIATE' value as the 'A' ALU input, 0 to use the regfile 'I_REG_A_SELECT'
// @param I_IMMEDIATE        the immediate value as the 'A' ALU input
// @param I_OPCODE           the ALU opcode
// @param I_REG_DATA         the input data that is muxed with the ALU output that is an input to the regfile
// @param I_REG_DATA_SELECT  1 to use the 'I_REG_DATA' as an input to the regfile, 0 to use the ALU output to the regfile
// @param O_A                the ALU 'A' input
// @param O_B                the ALU 'B' input
// @param O_RESULT_BUS       the output of the ALU and the input value to the regfile
// @param O_STATUS_FLAGS     the status flags of the ALU
module datapath
       (input wire I_CLK,
        input wire I_ENABLE,
        input wire I_NRESET,
        input wire [15:0] I_REG_WRITE_ENABLE,
        input wire [3:0] I_REG_A_SELECT,
        input wire [3:0] I_REG_B_SELECT,
        input wire I_IMMEDIATE_SELECT,
        input wire [15:0] I_IMMEDIATE,
        input wire [3:0] I_OPCODE,
        input wire [15:0] I_REG_DATA,
        input wire I_REG_DATA_SELECT,
        output wire [15:0] O_A,
        output wire [15:0] O_B,
        output reg [15:0] O_RESULT_BUS,
        output reg [4:0] O_STATUS_FLAGS);

wire [15:0][15:0] regfile_data; // Output wire array of the register file
wire [15:0] regfile_a;          // 'I_REG_A_SELECT' muxed output of regfile
wire [15:0] regfile_b;          // 'I_REG_B_SELECT' muxed output of regfile
wire [15:0] alu_input_a;        // 'A' input to ALU
wire [15:0] alu_input_b;        // 'B' input to ALU
wire [15:0] alu_output;         // Output of ALU
wire [15:0] result_bus;         // Output of input data mux and ALU to regfile
wire [4:0] alu_status_flags;    // Output of ALU flags which are connected to flag register

assign O_A = alu_input_a;
assign O_B = alu_input_b;
assign O_RESULT_BUS = result_bus;
assign alu_input_b = regfile_b; // This assigment determines which ALU input is not muxed with the 'I_IMMEDIATE'

// Instantiate two 16-to-1 16-bit muxes (one for register 'A' and register 'B')
mux #(.P_WIDTH(16),
      .P_DEPTH(16))
    i_mux_regfile_reg_a_select
    (.I_INPUT(regfile_data),
     .I_SELECT(I_REG_A_SELECT),
     .O_OUTPUT(regfile_a));
mux #(.P_WIDTH(16),
      .P_DEPTH(16))
    i_mux_regfile_reg_b_select
    (.I_INPUT(regfile_data),
     .I_SELECT(I_REG_B_SELECT),
     .O_OUTPUT(regfile_b));

// Instantiate a mux to select between the 'A' register of the regfile or the immediate value
mux #(.P_WIDTH(2),
      .P_DEPTH(16))
    i_mux_immediate_select
    (.I_INPUT({I_IMMEDIATE, regfile_a}),
     .I_SELECT(I_IMMEDIATE_SELECT),
     .O_OUTPUT(alu_input_a));

// Instantiate the regfile
regfile i_regfile
        (.I_CLK(I_CLK),
         .I_NRESET(I_NRESET),
         .I_REG_BUS(result_bus),
         .I_REG_ENABLE(I_REG_WRITE_ENABLE & {'d16{I_ENABLE}}),
         .O_REG_DATA(regfile_data));

// Instantiate the ALU
alu i_alu
    (.I_ENABLE(I_ENABLE),
     .I_OPCODE(I_OPCODE),
     .I_A(alu_input_a),
     .I_B(alu_input_b),
     .O_C(alu_output),
     .O_STATUS(alu_status_flags));

// Instantiate the ALU status flags register to hold status flags every clock cycle
register #(.P_WIDTH(5))
         i_status_flags_register
         (.I_CLK(I_CLK),
          .I_ENABLE(I_ENABLE),
          .I_NRESET(I_NRESET),
          .I_DATA(alu_status_flags),
          .O_DATA(O_STATUS_FLAGS));

// Instantiate a mux to select between the 'I_REG_DATA' input and ALU output
mux #(.P_WIDTH(2),
      .P_DEPTH(16))
    i_mux_data_select
    (.I_INPUT({I_REG_DATA, alu_output}),
     .I_SELECT(I_REG_DATA_SELECT),
     .O_OUTPUT(result_bus));

endmodule
