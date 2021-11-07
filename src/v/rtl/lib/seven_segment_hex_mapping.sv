//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/16/2021
// Module Name: seven_segment_hex_mapping
// Description: A decimal number to a 7-segment hex value display mapping.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_VALUE     a 4-bit decimal number
// @param O_7_SEGMENT a 7-bit output with a mapping using the MSB to LSB as the '0123456'
//                    active-low LEDs of the 7-segment display
module seven_segment_hex_mapping
       (input [3:0] I_VALUE,
        output reg [6:0] O_7_SEGMENT);

always @(*) begin
    case (I_VALUE)
        4'd0:
            O_7_SEGMENT = 7'b1000000;
        4'd1:
            O_7_SEGMENT = 7'b1111001;
        4'd2:
            O_7_SEGMENT = 7'b0100100;
        4'd3:
            O_7_SEGMENT = 7'b0110000;
        4'd4:
            O_7_SEGMENT = 7'b0011001;
        4'd5:
            O_7_SEGMENT = 7'b0010010;
        4'd6:
            O_7_SEGMENT = 7'b0000010;
        4'd7:
            O_7_SEGMENT = 7'b1111000;
        4'd8:
            O_7_SEGMENT = 7'b0000000;
        4'd9:
            O_7_SEGMENT = 7'b0011000;
        4'd10:
            O_7_SEGMENT = 7'b0001000;
        4'd11:
            O_7_SEGMENT = 7'b0000011;
        4'd12:
            O_7_SEGMENT = 7'b1000110;
        4'd13:
            O_7_SEGMENT = 7'b0100001;
        4'd14:
            O_7_SEGMENT = 7'b0000110;
        4'd15:
            O_7_SEGMENT = 7'b0001110;
    endcase
end
endmodule

