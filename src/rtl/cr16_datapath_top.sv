// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: cr16_datapath_top
// Description: FSM for the datapath of the CR16 CPU. Demonstrates read, write, and update
// functionality for registers 0-7 using the Fibonacci sequence.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_datapath_top (input wire I_CLK,
                          input wire I_NRESET,
                          output wire [4:0] O_LED_FLAGS,
                          output wire [6:0] O_7_SEGMENT_DISPLAY [3:0]);

// Instantiate wires to connect the FSM to the datapath and the 7-seg.
reg [15:0] reg_enable;
reg nreset;
reg [3:0] read_a_sel;
reg [3:0] read_b_sel;
reg [15:0] immediate;
reg imm_sel;
reg [3:0] opcode;

wire [15:0] write_port;

cr16_datapath i_cr16_datapath (.I_REG_ENABLE(reg_enable),
                               .I_NRESET(nreset),
                               .I_OPCODE(opcode),
                               .I_CLK(I_CLK),
                               .I_ENABLE(1'b1),
                               .I_READ_PORT_A_SEL(read_a_sel),
                               .I_READ_PORT_B_SEL(read_b_sel),
                               .I_IMMEDIATE(immediate),
                               .I_IMM_SEL(imm_sel),
                               .O_WRITE_PORT(write_port),
                               .O_FLAGS(O_LED_FLAGS));

// 7-seg integration for the output of the write port.
seven_segment_hex_mapping i_seg1 (.I_VALUE(write_port[3:0]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
seven_segment_hex_mapping i_seg2 (.I_VALUE(write_port[7:4]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
seven_segment_hex_mapping i_seg3 (.I_VALUE(write_port[11:8]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
seven_segment_hex_mapping i_seg4 (.I_VALUE(write_port[15:12]), .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));

// Declare the next state.
reg [3:0] NS;

// Parameter aliases for states.
parameter [3:0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100,
          S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000;

// Next state and sequential logic.
always @ (negedge I_NRESET or posedge I_CLK) begin
    if (~I_NRESET)
        NS <= S0;
    else
    case (NS)
        S0:
            NS <= S1;
        S1:
            NS <= S2;
        S2:
            NS <= S3;
        S3:
            NS <= S4;
        S4:
            NS <= S5;
        S5:
            NS <= S6;
        S6:
            NS <= S7;
        S7:
            NS <= S8;
        S8:
            NS <= S0;
        default:
            NS <= S0;
    endcase
end

// Successively write to and read from registers 0-7 to compute and store the first 8
// elements of the Fibonacci sequence. After states 0-7, the values in the registers should
// appear as:
//                            1   1   2   3   5   8  13  21
//                           r0  r1  r2  r3  r4  r5  r6  r7
always @ (NS) begin
    case (NS)
        // Reset.
        S0: begin
            reg_enable <= 'd0;
            nreset <= 'b0;
            read_a_sel <= 'd0;
            read_b_sel <= 'd0;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd0;
        end
        // Load 1 into r0.
        S1: begin
            reg_enable <= 'h0001; // reg_enable is 1-hot encoded.
            nreset <= 'b1;        // Return nreset to the high (OFF) state.
            read_a_sel <= 'b0000; // Read selectors are binary encoded.
            read_b_sel <= 'b0000;
            immediate <= 'd1;     // Use immediate value 1.
            imm_sel <= 'b1;       // Enable the immediate value.
            opcode <= 'd1;        // Use unsigned addition.
        end
        // Load 1 into r1.
        S2: begin
            reg_enable <= 'h0002;
            nreset <= 'b1;
            read_a_sel <= 'b0000;
            read_b_sel <= 'b0000;
            immediate <= 'd1;
            imm_sel <= 'b1;
            opcode <= 'd1;
        end
        // Add r0 + r1 and store into r2.
        S3: begin
            reg_enable <= 'h0004;
            nreset <= 'b1;
            read_a_sel <= 'b0000;
            read_b_sel <= 'b0001;
            immediate <= 'd0; // Use immediate value 0, since it is unused by this point.
            imm_sel <= 'b0;   // Disable the immediate value.
            opcode <= 'd1;
        end
        // Add r1 + r2 and store into r3.
        S4: begin
            reg_enable <= 'h0008;
            nreset <= 'b1;
            read_a_sel <= 'b0001;
            read_b_sel <= 'b0010;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd1;
        end
        // Add r2 + r3 and store into r4.
        S5: begin
            reg_enable <= 'h0010;
            nreset <= 'b1;
            read_a_sel <= 'b0010;
            read_b_sel <= 'b0011;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd1;
        end
        // Add r3 + r4 and store into r5.
        S6: begin
            reg_enable <= 'h0020;
            nreset <= 'b1;
            read_a_sel <= 'b0011;
            read_b_sel <= 'b0100;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd1;
        end
        // Add r4 + r5 and store into r6.
        S7: begin
            reg_enable <= 'h0040;
            nreset <= 'b1;
            read_a_sel <= 'b0100;
            read_b_sel <= 'b0101;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd1;
        end
        // Add r5 + r6 and store into r7.
        S8: begin
            reg_enable <= 'h0080;
            nreset <= 'b1;
            read_a_sel <= 'b0101;
            read_b_sel <= 'b0110;
            immediate <= 'd0;
            imm_sel <= 'b0;
            opcode <= 'd1;
        end
    endcase
end

endmodule