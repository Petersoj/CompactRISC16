//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: cr16_flags
// Description: A register for the 5 bit ALU flag value
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_ENABLE enable bit
// @param I_NRESET inverted reset bit
// @param I_CLK    clock
// @param I_FLAGS  flag inputs
// @param O_FLAGS  flags outputs
module cr16_flags #(parameter integer P_FLAG_WIDTH = 5)
       (input wire I_ENABLE,
        input wire I_NRESET,
        input wire I_CLK,
        input wire [P_FLAG_WIDTH - 1 : 0] I_FLAGS,
        output wire [P_FLAG_WIDTH - 1 : 0] O_FLAGS);

register #(.P_WIDTH(P_FLAG_WIDTH))
         i_flag_register
         (.I_ENABLE(I_ENABLE),
          .I_NRESET(I_NRESET),
          .I_CLK(I_CLK),
          .I_DATA(I_FLAGS),
          .O_DATA(O_FLAGS));

endmodule
