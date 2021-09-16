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
    case (I_BCD)
        0: O_SEVEN_SEGMENT = 7'b1000000;
			1: O_SEVEN_SEGMENT = 7'b1111001;
			2: O_SEVEN_SEGMENT = 7'b0100100;
			3: O_SEVEN_SEGMENT = 7'b0110000;
			4: O_SEVEN_SEGMENT = 7'b0011001;
			5: O_SEVEN_SEGMENT = 7'b0010010;
			6: O_SEVEN_SEGMENT = 7'b0000010;
			7: O_SEVEN_SEGMENT = 7'b1111000;
			8: O_SEVEN_SEGMENT = 7'b0000000;
			9: O_SEVEN_SEGMENT = 7'b0011000;
			10: O_SEVEN_SEGMENT = 7'b0001000;
			11: O_SEVEN_SEGMENT = 7'b0000011;
			12: O_SEVEN_SEGMENT = 7'b1000110;
			13: O_SEVEN_SEGMENT = 7'b0100001;
			14: O_SEVEN_SEGMENT = 7'b0000110;
			15: O_SEVEN_SEGMENT = 7'b0001110;
    endcase
end
endmodule

