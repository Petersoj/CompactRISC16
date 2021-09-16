//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu_top
// Description: The CR16 ALU Top module
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_alu_top(input wire[7:0] INPUT, input RST, input CLK, output wire [6:0] O_7_SEG_DISPLAY0, output wire [6:0] O_7_SEG_DISPLAY1, output wire [6:0] O_7_SEG_DISPLAY2, output wire [6:0] O_7_SEG_DISPLAY3, output wire [4:0] O_STATUS_LED);


wire [15:0] OUTPUT;
reg [4:0] OPCODE = 0;
wire [4:0] O_STATUS;
reg [2:0] state = 0;
reg [15:0] A = 0;
reg [15:0] B = 0;

cr16_alu alu
         (.I_CLK(CLK),
          .I_ENABLE(1),
          .I_OPCODE(OPCODE),
          .I_A(A),
          .I_B(B),
          .O_C(OUTPUT),
          .O_STATUS(O_STATUS));

bcd_seven_segment_mapping bcd_7_0
                          (.I_BCD(OUTPUT[3:0]),
                           .O_SEVEN_SEGMENT(O_7_SEG_DISPLAY0));

bcd_seven_segment_mapping bcd_7_1
                          (.I_BCD(OUTPUT[7:4]),
                           .O_SEVEN_SEGMENT(O_7_SEG_DISPLAY1));

bcd_seven_segment_mapping bcd_7_2
                          (.I_BCD(OUTPUT[11:8]),
                           .O_SEVEN_SEGMENT(O_7_SEG_DISPLAY2));

bcd_seven_segment_mapping bcd_7_3
                          (.I_BCD(OUTPUT[15:12]),
                           .O_SEVEN_SEGMENT(O_7_SEG_DISPLAY3));

assign O_STATUS_LED = O_STATUS;

always@(posedge CLK or negedge RST) begin
    if (!RST) begin
        state <= 3'b000;
    end
    else begin
        case (state)
            // Set high of A
            3'b000: begin
                A[15:8] <= INPUT;
                state <= 3'b001;
            end
            // Set low of A
            3'b001: begin
                A[7:0] <= INPUT;
                state <= 3'b010;
            end
            // Set high of B
            3'b010: begin
                B[15:8] <= INPUT;
                state <= 3'b011;
            end
            // Set low of B
            3'b011: begin
                B[7:0] <= INPUT;
                state <= 3'b100;
            end
            // Set opcode
            3'b100: begin
                OPCODE <= INPUT[4:0];
                state <= 3'b000;
            end
            default: begin
                state <= 3'b000;
            end
        endcase
    end
end
endmodule
