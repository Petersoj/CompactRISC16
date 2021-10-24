//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/23/2021
// Module Name: decoder4_16
// Description: A generic 4-to-16 decoder module.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_DATA   the 4-bit decoder input data
// @param I_ENABLE the enable bit
// @param O_DATA   the 16-bit decoder output data
module decoder4_16
       (input wire [3:0] I_DATA,
        input wire I_ENABLE,
        output reg [15:0] O_DATA);

always @(*) begin
    if (I_ENABLE) begin
        case (I_DATA)
            4'd0:
                O_DATA = 16'h0001;
            4'd1:
                O_DATA = 16'h0002;
            4'd2:
                O_DATA = 16'h0004;
            4'd3:
                O_DATA = 16'h0008;
            4'd4:
                O_DATA = 16'h0010;
            4'd5:
                O_DATA = 16'h0020;
            4'd6:
                O_DATA = 16'h0040;
            4'd7:
                O_DATA = 16'h0080;
            4'd8:
                O_DATA = 16'h0100;
            4'd9:
                O_DATA = 16'h0200;
            4'd10:
                O_DATA = 16'h0400;
            4'd11:
                O_DATA = 16'h0800;
            4'd12:
                O_DATA = 16'h1000;
            4'd13:
                O_DATA = 16'h2000;
            4'd14:
                O_DATA = 16'h4000;
            4'd15:
                O_DATA = 16'h8000;
            default:
                O_DATA = 16'h0;
        endcase
    end
    else
        O_DATA = 16'h0;
end
endmodule
