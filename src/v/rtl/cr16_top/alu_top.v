//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/16/2021
// Module Name: alu_top
// Description: The CR16 ALU top module
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module alu_top
       (input I_CLK,
        input I_NRESET,
        input wire[7:0] I_INPUT,
        output wire [6:0] O_7_SEGMENT_DISPLAY_0,
        output wire [6:0] O_7_SEGMENT_DISPLAY_1,
        output wire [6:0] O_7_SEGMENT_DISPLAY_2,
        output wire [6:0] O_7_SEGMENT_DISPLAY_3,
        output wire [4:0] O_STATUS_LED);

// Parameterized states for FSM
localparam [2:0]
           S_HIGH_A = 3'd0,
           S_LOW_A  = 3'd1,
           S_HIGH_B = 3'd2,
           S_LOW_B  = 3'd3,
           S_OPCODE = 3'd4;

reg [2:0] state  = 0;
reg [4:0] opcode = 0;
reg [15:0] a     = 0;
reg [15:0] b     = 0;
wire [15:0] c;

alu #(.P_WIDTH(16))
    i_alu
    (.I_OPCODE(opcode),
     .I_A(a),
     .I_B(b),
     .O_C(c),
     .O_STATUS(O_STATUS_LED));

seven_segment_hex_mapping i_display_0
                          (.I_VALUE(c[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_0));
seven_segment_hex_mapping i_display_1
                          (.I_VALUE(c[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_1));
seven_segment_hex_mapping i_display_2
                          (.I_VALUE(c[11:8]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_2));
seven_segment_hex_mapping i_display_3
                          (.I_VALUE(c[15:12]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY_3));

always@(negedge I_CLK or negedge I_NRESET) begin
    if (!I_NRESET) begin
        state  <= S_HIGH_A;
        opcode <= 0;
        a      <= 0;
        b      <= 0;
    end
    else begin
        case (state)
            S_HIGH_A: begin
                a[15:8] <= I_INPUT;
                state   <= S_LOW_A;
            end
            S_LOW_A: begin
                a[7:0] <= I_INPUT;
                state  <= S_HIGH_B;
            end
            S_HIGH_B: begin
                b[15:8] <= I_INPUT;
                state   <= S_LOW_B;
            end
            S_LOW_B: begin
                b[7:0] <= I_INPUT;
                state  <= S_OPCODE;
            end
            S_OPCODE: begin
                opcode <= I_INPUT[4:0];
                state  <= S_HIGH_A;
            end
            default: begin
                state <= S_HIGH_A;
            end
        endcase
    end
end
endmodule
