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
        0:
            O_7_SEGMENT = 7'b1000000;
        1:
            O_7_SEGMENT = 7'b1111001;
        2:
            O_7_SEGMENT = 7'b0100100;
        3:
            O_7_SEGMENT = 7'b0110000;
        4:
            O_7_SEGMENT = 7'b0011001;
        5:
            O_7_SEGMENT = 7'b0010010;
        6:
            O_7_SEGMENT = 7'b0000010;
        7:
            O_7_SEGMENT = 7'b1111000;
        8:
            O_7_SEGMENT = 7'b0000000;
        9:
            O_7_SEGMENT = 7'b0011000;
        10:
            O_7_SEGMENT = 7'b0001000;
        11:
            O_7_SEGMENT = 7'b0000011;
        12:
            O_7_SEGMENT = 7'b1000110;
        13:
            O_7_SEGMENT = 7'b0100001;
        14:
            O_7_SEGMENT = 7'b0000110;
        15:
            O_7_SEGMENT = 7'b0001110;
    endcase
end
endmodule

