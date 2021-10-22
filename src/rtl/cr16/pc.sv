//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/7/2021
// Module Name: pc
// Description: Program counter to drive the FSM of the CR16 ALU.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param P_ADDRESS_WIDTH            the width of the input/output address
// @param I_ENABLE                   the enable signal
// @param I_NRESET                   the active-low reset signal
// @param I_ADDRESS                  the address input value
// @param I_ADDRESS_SELECT           assert to output 'I_ADDRESS' on 'O_ADDRESS' or reset to
//                                   increment and output 'O_ADDRESS'
// @param I_ADDRESS_SELECT_INCREMENT assert to output 'I_ADDRESS' + 1 on 'O_ADDRESS' if
//                                   'I_ADDRESS_SELECT' is asserted, reset to not increment
//                                   'I_ADDRESS' by 1
// @param O_ADDRESS                  the address output value
module pc #(parameter integer P_ADDRESS_WIDTH = 16)
       (input wire I_ENABLE,
        input wire I_NRESET,
        input wire [P_ADDRESS_WIDTH - 1 : 0] I_ADDRESS,
        input wire I_ADDRESS_SELECT,
        input wire I_ADDRESS_SELECT_INCREMENT,
        output reg [P_ADDRESS_WIDTH - 1 : 0] O_ADDRESS);

always @(posedge I_ENABLE) begin
    if (I_ENABLE) begin
        if(!I_NRESET)
            O_ADDRESS = 1'd0;
        else begin
            if (I_ADDRESS_SELECT)
                if (I_ADDRESS_SELECT_INCREMENT)
                    O_ADDRESS = I_ADDRESS + 1'd1;
                else
                    O_ADDRESS = I_ADDRESS;
            else
                O_ADDRESS += 1'd1;
        end
    end
    else
        O_ADDRESS = O_ADDRESS;
end
endmodule
