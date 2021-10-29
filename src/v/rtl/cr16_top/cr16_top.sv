//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/27/2021
// Module Name: cr16_top
// Description: This is the top-level module for the CompactRISC16 (CR16) processor. This
// processor is integrated with the BRAM memory module, which allows for the execution of preloaded
// machine code files according to our custom ISA.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module cr16_top
       (input I_CLK,
        input I_NRESET,
        input [9:0] I_MEM_ADDRESS_B,
        output wire [6:0] O_7_SEGMENT_DISPLAY [5:0],
        output wire [4:0] O_LED_FLAGS);

// This value specifies the max program count (instruction address) that the CR16 processor
// should advance to until it is disabled.
localparam [15:0] P_MAX_PC = 16'h0008;

wire [15:0] i_mem_data_a;
wire [15:0] i_mem_address_a;
wire i_mem_write_enable_a;
wire [15:0] o_mem_data_a;
wire [15:0] o_mem_data_b;

reg cr16_enable = 1'b1;
wire [15:0] cr16_ext_mem_data;
wire [15:0] cr16_ext_mem_address;
wire cr16_ext_mem_write_enable;
wire [15:0] result_bus;
wire [15:0] pc;

// Reg bits for 7-segment display input
localparam integer P_DISPLAY_BIT_WIDTH = 4 * 6;
reg [P_DISPLAY_BIT_WIDTH - 1 : 0] display_bits = {P_DISPLAY_BIT_WIDTH{1'd0}};

// Instantiate BRAM module with given init file
bram #(.P_BRAM_INIT_FILE("resources/bram_init/cr16_top/cr16_top_init_test_add_fibonacci.dat"),
       .P_BRAM_INIT_FILE_START_ADDRESS('d0),
       .P_DATA_WIDTH('d16),
       .P_ADDRESS_WIDTH('d10)) // Synthesis takes a long time with 16 bits, use 10 bits for testing
     i_bram
     (.I_CLK(I_CLK),
      .I_DATA_A(i_mem_data_a),
      .I_DATA_B(16'd0),
      .I_ADDRESS_A(i_mem_address_a[9:0]),
      .I_ADDRESS_B(I_MEM_ADDRESS_B),
      .I_WRITE_ENABLE_A(i_mem_write_enable_a),
      .I_WRITE_ENABLE_B(1'b0),
      .O_DATA_A(o_mem_data_a),
      .O_DATA_B(o_mem_data_b));

// Instantiate CR16 module
cr16 i_cr16
     (.I_CLK(I_CLK),
      .I_ENABLE(cr16_enable),
      .I_NRESET(I_NRESET),
      .I_MEM_DATA(o_mem_data_a),
      .I_EXT_MEM_DATA(16'b0),
      .O_MEM_DATA(i_mem_data_a),
      .O_MEM_ADDRESS(i_mem_address_a),
      .O_MEM_WRITE_ENABLE(i_mem_write_enable_a),
      .O_EXT_MEM_DATA(cr16_ext_mem_data),
      .O_EXT_MEM_ADDRESS(cr16_ext_mem_address),
      .O_EXT_MEM_WRITE_ENABLE(cr16_ext_mem_write_enable),
      .O_RESULT_BUS(result_bus),
      .O_STATUS_FLAGS(O_LED_FLAGS),
      .O_PC(pc));


// Instantiate 7-segment hex mappings to display 'display_bits'
seven_segment_hex_mapping i_display_0
                          (.I_VALUE(display_bits[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
seven_segment_hex_mapping i_display_1
                          (.I_VALUE(display_bits[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
seven_segment_hex_mapping i_display_2
                          (.I_VALUE(display_bits[11:8]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
seven_segment_hex_mapping i_display_3
                          (.I_VALUE(display_bits[15:12]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));
seven_segment_hex_mapping i_display_4
                          (.I_VALUE(display_bits[19:16]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[4]));
seven_segment_hex_mapping i_display_5
                          (.I_VALUE(display_bits[23:20]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[5]));

// Enable CR16 until 'P_MAX_CLK_COUNT' is reached
always @(posedge I_CLK) begin
    if (pc > P_MAX_PC) begin
        display_bits = {8'b0, o_mem_data_b};
        cr16_enable = 1'b0;
    end
    else begin
        display_bits = {result_bus, o_mem_data_b[7:0]};
        cr16_enable = 1'b1;
    end
end
endmodule
