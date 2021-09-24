//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: cr16_regfile
// Description: Register file for CR16 CPU
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_regfile
       #(parameter integer P_REG_WIDTH = 16,
         parameter integer P_FILE_WIDTH = 16)
       (input wire I_NRESET,
        input wire I_CLK,
        input wire [P_REG_WIDTH - 1 : 0] I_REG_BUS,
        input wire [P_FILE_WIDTH - 1 : 0] I_REG_ENABLE,
        output wire [P_REG_WIDTH - 1 : 0] O_REG_DATA [P_FILE_WIDTH - 1 : 0]);

genvar reg_idx;
generate
    for (reg_idx = 0; reg_idx < P_FILE_WIDTH; reg_idx++) begin: make_registers
        register #(.P_WIDTH(P_REG_WIDTH))
                 i_register
                 (.I_ENABLE(I_REG_ENABLE[reg_idx]),
                  .I_NRESET(I_NRESET),
                  .I_CLK(I_CLK),
                  .I_DATA(I_REG_BUS),
                  .O_DATA(O_REG_DATA[reg_idx]));
    end
endgenerate
endmodule
