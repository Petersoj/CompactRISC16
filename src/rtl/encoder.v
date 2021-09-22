// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: encoder
// Description: Top level module for the combination of the datapath with the alu.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module ( input wire [15:0] REG_ENABLE,
         input wire I_ENABLE,
         output reg [3:0] O_S
       );

always@(I_ENABLE) begin
    case(REG_ENABLE)



        endmodule

