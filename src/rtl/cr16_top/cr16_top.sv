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
        output wire [6:0] O_7_SEGMENT_DISPLAY [3:0],
        output wire [4:0] O_LED_FLAGS);

// This value specifies the maximum number of clock positive edges before the CR16 processor is
// disabled. Since ALU instructions take 3 clock cycles, this number should be
// 3 * <number of instructions>.
localparam integer P_MAX_CLK_COUNT = 8 * 3;

wire [15:0] i_mem_data_a;
wire [15:0] i_mem_address_a;
wire i_mem_write_enable_a;
wire [15:0] o_mem_data_a;
wire [15:0] o_mem_data_b;

wire [15:0] cr16_ext_mem_data;
wire [15:0] cr16_ext_mem_address;
wire cr16_ext_mem_write_enable;
wire [15:0] result_bus;

reg cr16_enable = 1'b1;
reg [15:0] clk_count = 16'b0;

// Instantiate BRAM module with given init file
bram #(.P_BRAM_INIT_FILE("resources/bram_init/cr16_top_init_test_add_fibonacci.dat"),
       .P_BRAM_INIT_FILE_START_ADDRESS('d0),
       .P_DATA_WIDTH('d16),
       .P_ADDRESS_WIDTH('d16))
     i_bram
     (.I_CLK(I_CLK),
      .I_DATA_A(i_mem_data_a),
      .I_DATA_B(16'd0),
      .I_ADDRESS_A(i_mem_address_a),
      .I_ADDRESS_B({6'b0, I_MEM_ADDRESS_B}),
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
      .O_STATUS_FLAGS(O_LED_FLAGS));


// Instantiate 7-segment hex mappings to display 'o_mem_data_b'
seven_segment_hex_mapping i_display_0
                          (.I_VALUE(o_mem_data_b[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[0]));
seven_segment_hex_mapping i_display_1
                          (.I_VALUE(o_mem_data_b[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[1]));
// seven_segment_hex_mapping i_display_2
//                           (.I_VALUE(o_mem_data_b[11:8]),
//                            .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
// seven_segment_hex_mapping i_display_3
//                           (.I_VALUE(o_mem_data_b[15:12]),
//                            .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));
seven_segment_hex_mapping i_display_2
                          (.I_VALUE(result_bus[3:0]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[2]));
seven_segment_hex_mapping i_display_3
                          (.I_VALUE(result_bus[7:4]),
                           .O_7_SEGMENT(O_7_SEGMENT_DISPLAY[3]));

// Enable CR16 until 'P_MAX_CLK_COUNT' is reached
always @(posedge I_CLK or negedge I_NRESET) begin
    if (!I_NRESET)
        clk_count = 'b0;
    else
        if (clk_count >= P_MAX_CLK_COUNT) begin
            clk_count = clk_count;
            cr16_enable = 1'b0;
        end
        else begin
            clk_count++;
            cr16_enable = 1'b1;
        end
end
endmodule
