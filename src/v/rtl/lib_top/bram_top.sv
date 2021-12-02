//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/28/2021
// Module Name: bram_top
// Description: Tests the following features of using block RAM on the DE1-SoC:
// • Reading the contents of a memory initialization file into block RAM.
// • Editing the memory contents.
// • Verifying writeback.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_CLK               the clock signal
// @param I_NRESET            the active-low asynchronous reset signal
// @param I_STEP              the FSM 'step' signal input
// @param O_7_SEGMENT_DISPLAY output to the 7-segment displays
module bram_top
       (input wire I_CLK,
        input wire I_NRESET,
        input wire I_STEP,
        output wire [6:0] O_7_SEGMENT_DISPLAY [3:0]);

reg [3:0] next_state;
reg [15:0] i_data_a, i_data_b;
reg [9:0] address_a, address_b;
reg write_enable_a, write_enable_b;
wire [15:0] o_data_a, o_data_b;

// Parameters for states
parameter [3:0]
          S0 = 4'b0,
          S1 = 4'd1,
          S2 = 4'd2,
          S3 = 4'd3,
          S4 = 4'd4,
          S5 = 4'd5,
          S6 = 4'd6,
          S7 = 4'd7,
          S8 = 4'd8;

// Instantiate BRAM module with given init file.
bram #(.P_BRAM_INIT_FILE("resources/bram_init/lib_top/bram_top_init.dat"),
       .P_BRAM_INIT_FILE_START_ADDRESS('d0),
       .P_DATA_WIDTH('d16),
       .P_ADDRESS_WIDTH('d10))
     i_bram
     (.I_CLK(I_CLK),
      .I_DATA_A(i_data_a),
      .I_DATA_B(i_data_b),
      .I_ADDRESS_A(address_a),
      .I_ADDRESS_B(address_b),
      .I_WRITE_ENABLE_A(write_enable_a),
      .I_WRITE_ENABLE_B(write_enable_b),
      .O_DATA_A(o_data_a),
      .O_DATA_B(o_data_b));

// Instantiate 7-segment hex mappings to display the lower 8-bits of 'o_data_a' and 'o_data_b'.
seven_segment_hex_mapping i_display_0_data_a
                          (.I_VALUE(o_data_a[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
seven_segment_hex_mapping i_display_1_data_a
                          (.I_VALUE(o_data_a[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
seven_segment_hex_mapping i_display_2_data_b
                          (.I_VALUE(o_data_b[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
seven_segment_hex_mapping i_display_3_data_b
                          (.I_VALUE(o_data_b[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));

// State advancement block.
always @(posedge I_STEP or negedge I_NRESET) begin
    if (!I_NRESET)
        next_state <= S0;
    else
    case (next_state)
        S0:
            next_state <= S1;
        S1:
            next_state <= S2;
        S2:
            next_state <= S3;
        S3:
            next_state <= S4;
        S4:
            next_state <= S5;
        S5:
            next_state <= S6;
        S6:
            next_state <= S7;
        S7:
            next_state <= S8;
        S8:
            next_state <= S0;
        default:
            next_state <= S0;
    endcase
end

// State logic block.
always @(next_state) begin
    case (next_state)
        // Reset state (read 0th memory address on both ports (shows 0303 on 7-segments)).
        S0: begin
            address_a      <= 10'd0;
            address_b      <= 10'd0;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Read 1st memory address on port A (shows 0x02).
        S1: begin
            address_a      <= 10'd1;
            address_b      <= 10'd0;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Read 2nd memory address on port B (shows 0x01).
        S2: begin
            address_a      <= 10'd1;
            address_b      <= 10'd2;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Read 1021st memory address on port A (shows 0x21).
        S3: begin
            address_a      <= 10'd1021;
            address_b      <= 10'd2;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Read 1022nd memory address on port B (shows 0x22).
        S4: begin
            address_a      <= 10'd1021;
            address_b      <= 10'd1022;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Read 1023rd memory address on port A (shows 0x23).
        S5: begin
            address_a      <= 10'd1023;
            address_b      <= 10'd1022;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0000;
            i_data_b       <= 16'h0000;
        end
        // Overwrite 1023rd memory address via port A.
        S6: begin
            address_a      <= 10'd1023;
            address_b      <= 10'd1022;
            write_enable_a <= 1'b1;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h00AA;
            i_data_b       <= 16'h0000;
        end
        // Read overwritten 1023rd memory address on port B while simultaneously writting to 0th
        // memory address via port A (shows AA23 on 7-segments).
        S7: begin
            address_a      <= 10'd0;
            address_b      <= 10'd1023;
            write_enable_a <= 1'b1;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0001;
            i_data_b       <= 16'h0000;
        end
        // Read updated 0th memory address on port A and port B (shows 0101).
        S8: begin
            address_a      <= 10'd0;
            address_b      <= 10'd0;
            write_enable_a <= 1'b0;
            write_enable_b <= 1'b0;
            i_data_a       <= 16'h0001;
            i_data_b       <= 16'h0000;
        end
    endcase
end
endmodule
