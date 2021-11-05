//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: datapath_top
// Description: FSM for the datapath of the CR16 CPU. Demonstrates read, write, and update
// functionality for registers 0-7 using the Fibonacci sequence.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module datapath_top
       (input wire I_CLK,
        input wire I_NRESET,
        output wire [6:0] O_7_SEGMENT_DISPLAY [3:0],
        output wire [4:0] O_LED_FLAGS);

// Instantiate wires to connect the FSM to the datapath and the 7-seg.
reg [15:0] reg_enable;
reg nreset;
reg [3:0] read_a_sel;
reg [3:0] read_b_sel;
reg [15:0] immediate;
reg imm_sel;
reg [3:0] opcode;
wire [15:0] a, b;
wire [15:0] write_port;

datapath i_datapath
         (.I_CLK(I_CLK),
          .I_ENABLE(1'b1),
          .I_NRESET(nreset),
          .I_REG_WRITE_ENABLE(reg_enable),
          .I_REG_A_SELECT(read_a_sel),
          .I_REG_B_SELECT(read_b_sel),
          .I_IMMEDIATE(immediate),
          .I_IMMEDIATE_SELECT(imm_sel),
          .I_OPCODE(opcode),
          .I_REGFILE_DATA({16{1'b0}}),
          .I_REGFILE_DATA_SELECT(1'b0),
          .O_A(a),
          .O_B(b),
          .O_RESULT_BUS(write_port),
          .O_STATUS_FLAGS(O_LED_FLAGS));

// 7-seg integration for the output of the write port.
seven_segment_hex_mapping i_display_0
                          (.I_VALUE(write_port[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
seven_segment_hex_mapping i_display_1
                          (.I_VALUE(write_port[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
seven_segment_hex_mapping i_display_2
                          (.I_VALUE(write_port[11:8]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
seven_segment_hex_mapping i_display_3
                          (.I_VALUE(write_port[15:12]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));

// Declare the next state.
reg [3:0] state;

// Parameter aliases for states.
parameter [3:0]
          S0 = 4'd0,
          S1 = 4'd1,
          S2 = 4'd2,
          S3 = 4'd3,
          S4 = 4'd4,
          S5 = 4'd5,
          S6 = 4'd6,
          S7 = 4'd7,
          S8 = 4'd8;

// Next state and sequential logic.
always @(posedge I_CLK or negedge I_NRESET) begin
    if (!I_NRESET)
        state = S0;
    else
    case (state)
        S0:
            state = S1;
        S1:
            state = S2;
        S2:
            state = S3;
        S3:
            state = S4;
        S4:
            state = S5;
        S5:
            state = S6;
        S6:
            state = S7;
        S7:
            state = S8;
        S8:
            state = S0;
        default:
            state = S0;
    endcase
end

// Successively write to and read from registers 0-7 to compute and store the first 8 elements of
// the Fibonacci sequence. After states 0-7, the values in the registers should appear as:
//  1   1   2   3   5   8  13  21
// r0  r1  r2  r3  r4  r5  r6  r7
always @(state) begin
    case (state)
        // Reset.
        S0: begin
            reg_enable = 'd0;
            nreset     = 'b0;
            read_a_sel = 'd0;
            read_b_sel = 'd0;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
        // Load 1 into r0.
        S1: begin
            reg_enable = 'h0001; // reg_enable is 1-hot encoded.
            nreset     = 'b1;    // Return nreset to the high (OFF) state.
            read_a_sel = 'b0000; // Read selectors are binary encoded.
            read_b_sel = 'b0000;
            immediate  = 'd1;    // Use immediate value 1.
            imm_sel    = 'b1;    // Enable the immediate value.
            opcode     = 'd0;    // Use addition ALU opcode.
        end
        // Load 1 into r1.
        S2: begin
            reg_enable = 'h0002;
            nreset     = 'b1;
            read_a_sel = 'b0000;
            read_b_sel = 'b0000;
            immediate  = 'd1;
            imm_sel    = 'b1;
            opcode     = 'd0;
        end
        // Add r0 + r1 and store into r2.
        S3: begin
            reg_enable = 'h0004;
            nreset     = 'b1;
            read_a_sel = 'b0000;
            read_b_sel = 'b0001;
            immediate  = 'd0; // Use immediate value 0, since it is unused by this point.
            imm_sel    = 'b0; // Disable the immediate value.
            opcode     = 'd0;
        end
        // Add r1 + r2 and store into r3.
        S4: begin
            reg_enable = 'h0008;
            nreset     = 'b1;
            read_a_sel = 'b0001;
            read_b_sel = 'b0010;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
        // Add r2 + r3 and store into r4.
        S5: begin
            reg_enable = 'h0010;
            nreset     = 'b1;
            read_a_sel = 'b0010;
            read_b_sel = 'b0011;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
        // Add r3 + r4 and store into r5.
        S6: begin
            reg_enable = 'h0020;
            nreset     = 'b1;
            read_a_sel = 'b0011;
            read_b_sel = 'b0100;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
        // Add r4 + r5 and store into r6.
        S7: begin
            reg_enable = 'h0040;
            nreset     = 'b1;
            read_a_sel = 'b0100;
            read_b_sel = 'b0101;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
        // Add r5 + r6 and store into r7.
        S8: begin
            reg_enable = 'h0080;
            nreset     = 'b1;
            read_a_sel = 'b0101;
            read_b_sel = 'b0110;
            immediate  = 'd0;
            imm_sel    = 'b0;
            opcode     = 'd0;
        end
    endcase
end
endmodule
