//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: regfile
// Description: Register file for CR16 CPU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param P_REG_WIDTH  the width of each register in this register file (bit depth of each register)
// @param P_FILE_WIDTH the width of this register file (number of registers)
// @param I_CLK        the clock signal
// @param I_NRESET     the active-low asynchronous reset signal
// @param I_REG_BUS    the input data bus that is connected to all the registers in this register file
// @param I_REG_ENABLE the one-hot encoded enable signal to enable a specified register for writing data
//                     to it from the 'I_REG_BUS'
// @param O_REG_DATA   a 2-dimensional packed array with the first dimension as the regfile register and
//                     the second dimension as the register data
module regfile
       #(parameter integer P_REG_WIDTH = 16,
         parameter integer P_FILE_WIDTH = 16)
       (input wire I_CLK,
        input wire I_NRESET,
        input wire [P_REG_WIDTH - 1 : 0] I_REG_BUS,
        input wire [P_FILE_WIDTH - 1 : 0] I_REG_ENABLE,
        output wire [P_FILE_WIDTH - 1 : 0][P_REG_WIDTH - 1 : 0] O_REG_DATA);

// The following with generate 'P_FILE_WIDTH' number of registers
genvar reg_idx;
generate
    for (reg_idx = 0; reg_idx < P_FILE_WIDTH; reg_idx++) begin: g_registers
        register #(.P_WIDTH(P_REG_WIDTH))
                 i_register
                 (.I_CLK(I_CLK),
                  .I_ENABLE(I_REG_ENABLE[reg_idx]),
                  .I_NRESET(I_NRESET),
                  .I_DATA(I_REG_BUS),
                  .O_DATA(O_REG_DATA[reg_idx]));
    end
endgenerate
endmodule
