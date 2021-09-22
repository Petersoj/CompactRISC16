//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: register
// Description: A generic register
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_ENABLE enable bit
// @param I_NRESET inverted reset bit
// @param I_CLK    clock
// @param I_DATA   input data
// @param O_DATA   output data
module register #(parameter integer P_WIDTH = 16)
       (input wire I_ENABLE,
        input wire I_NRESET,
        input wire I_CLK,
        input wire [P_WIDTH - 1 : 0] I_DATA,
        output reg [P_WIDTH - 1 : 0] O_DATA);

always @(posedge I_CLK) begin
    if (!I_NRESET)
        O_DATA <= 0;
    else begin
        if (I_ENABLE)
            O_DATA <= I_DATA;
        else
            O_DATA <= O_DATA;
    end
end
endmodule
