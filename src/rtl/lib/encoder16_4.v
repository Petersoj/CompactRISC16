// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: encoder16_4
// Description: A generic 16-to-4 encoder module
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module encoder16_4
       (input wire [15:0] I_DATA,
        input wire I_ENABLE,
        output reg [3:0] O_DATA);

always @(I_DATA or I_ENABLE) begin
    if (I_ENABLE) begin
        case (I_DATA)
            16'h0001:
                O_DATA <= 4'd0;
            16'h0002:
                O_DATA <= 4'd1;
            16'h0004:
                O_DATA <= 4'd2;
            16'h0008:
                O_DATA <= 4'd3;
            16'h0010:
                O_DATA <= 4'd4;
            16'h0020:
                O_DATA <= 4'd5;
            16'h0040:
                O_DATA <= 4'd6;
            16'h0080:
                O_DATA <= 4'd7;
            16'h0100:
                O_DATA <= 4'd8;
            16'h0200:
                O_DATA <= 4'd9;
            16'h0400:
                O_DATA <= 4'd10;
            16'h0800:
                O_DATA <= 4'd11;
            16'h1000:
                O_DATA <= 4'd12;
            16'h2000:
                O_DATA <= 4'd13;
            16'h4000:
                O_DATA <= 4'd14;
            16'h8000:
                O_DATA <= 4'd15;
            default:
                O_DATA <= 4'd0;
        endcase
    end
    else
        O_DATA <= 'd0;
end
endmodule
