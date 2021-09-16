//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/16/2021
// Module Name: bcd_seven_segment_mapping
// Description: A BCD (binary coded decimal) to Seven Segment Display mapping
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param O_SEVEN_SEGMENT the mapping from MSB to LSB is 'abcdefg' for the LEDs
// of the 7-segment display
module bcd_seven_segment_mapping
       (input [3:0] I_BCD,
        output reg [6:0] O_SEVEN_SEGMENT);

always @(*) begin
    case (digit_in)
        4'b0000:
            display_digit = 7'b1111110; // 0
        4'b0001:
            display_digit = 7'b0110000; // 1
        4'b0010:
            display_digit = 7'b1101101; // 2
        4'b0011:
            display_digit = 7'b1111001; // 3
        4'b0100:
            display_digit = 7'b0110011; // 4
        4'b0101:
            display_digit = 7'b1011011; // 5
        4'b0110:
            display_digit = 7'b1011111; // 6
        4'b0111:
            display_digit = 7'b1110000; // 7
        4'b1000:
            display_digit = 7'b1111111; // 8
        4'b1001:
            display_digit = 7'b1111011; // 9
        4'b1010:
            display_digit = 7'b1110111; // A
        4'b1011:
            display_digit = 7'b0011111; // B
        4'b1100:
            display_digit = 7'b0001101; // C
        4'b1101:
            display_digit = 7'b0111101; // D
        4'b1110:
            display_digit = 7'b1001111; // E
        4'b1111:
            display_digit = 7'b1000111; // F
        default:
            display_digit = 7'b0000000;
    endcase
end
endmodule

