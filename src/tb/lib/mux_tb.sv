//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/25/2021
// Module Name: mux_tb
// Description: A testbench for a parameterized multiplexer (mux).
// Authors: Jacob Peterson
//

`timescale 1ps/1ps

module mux_tb();

// Instantiate single-bit-depth 16-to-1 mux
reg [15:0] input_16_1;
reg [3:0] select_16_1;
wire output_16_1;
mux #(.P_WIDTH(16),
      .P_DEPTH(1))
    i_uut_16_1
    (.I_INPUT(input_16_1),
     .I_SELECT(select_16_1),
     .O_OUTPUT(output_16_1));

// Instantiate 4-to-1 mux with a depth of 2 bits
reg [3:0][1:0] input_4_1;
reg [1:0] select_4_1;
wire [1:0] output_4_1;
mux #(.P_WIDTH(4),
      .P_DEPTH(2))
    i_uut_4_1
    (.I_INPUT(input_4_1),
     .I_SELECT(select_4_1),
     .O_OUTPUT(output_4_1));

integer select, input_value, input_4_1_index;
initial begin
    $display("================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    $display("================================================================");
    $display("BEGIN Testing single-bit-depth 16-to-1 Mux");
    $display("================================================================");

    for (select = 0; select < 1; select++) begin
        select_16_1 = select;
        for (input_value = 0; input_value < 2 ** 16; input_value += 15) begin
            input_16_1 = input_value;
            #1;

            if (output_16_1 != input_16_1[select])
                $display("16-to-1 mux test failed with select: %0d, input_value: %0b, output_16_1: %0b", select, input_value, output_16_1);
        end
    end

    $display("================================================================");
    $display("END Testing single-bit-depth 16-to-1 Mux");
    $display("================================================================\n");

    $display("================================================================");
    $display("BEGIN Testing 4-to-1 mux with a depth of 2 bits");
    $display("================================================================");

    for (select = 0; select < 4; select++) begin
        select_4_1 = select;

        for (input_4_1_index = 0; input_4_1_index < $size(input_4_1); input_4_1_index++) begin
            input_4_1[input_4_1_index] = input_4_1_index[1:0];
        end

        #1;

        if (output_4_1 != input_4_1[select])
            $display("4-to-1 mux test failed with select: %0d, input_value: %0b, output_16_1: %0b", select, input_4_1, output_4_1);
    end

    $display("================================================================");
    $display("END Testing 4-to-1 mux with a depth of 2 bits");
    $display("================================================================\n");

    $display("================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end

/*
// TODO Verilog doesn't support variable-width packed arrays in for-loops (although it does support it when
// surrounded by generate blocks) so this makes an automated parameterized testbench not possible so perhaps
// find a work-around for the following code rather than doing a testbench with manual instantiations like above.
 
module mux_tb();
 
localparam integer mux_tb_widths [0:5] = '{2, 4, 8, 16, 32, 64};
localparam integer mux_tb_depths [0:4] = '{1, 2, 3, 4, 5};
 
genvar g_mux_width_index, g_mux_depth_index;
generate
    for (g_mux_width_index = 0; g_mux_width_index < $size(mux_tb_widths); g_mux_width_index++) begin: g_mux_width
        for (g_mux_depth_index = 0; g_mux_depth_index < $size(mux_tb_depths); g_mux_depth_index++) begin: g_mux_depth
            localparam integer width = mux_tb_widths[g_mux_width_index];
            localparam integer depth = mux_tb_depths[g_mux_depth_index];
 
            reg [0 : width - 1][depth - 1 : 0] i_input;
            reg [$clog2(width) - 1 : 0] select;
            wire [depth - 1 : 0] o_output;
 
            mux #(.P_WIDTH(width),
                  .P_DEPTH(depth))
                i_uut
                (.I_INPUT(i_input),
                 .I_SELECT(select),
                 .O_OUTPUT(o_output));
        end
    end
endgenerate
 
integer mux_width_index, mux_depth_index, select_index, input_index;
initial begin
    $display("================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");
 
    for (integer mux_width_index = 0; mux_width_index < $size(mux_tb_widths); mux_width_index++) begin
        for (integer mux_depth_index = 0; mux_depth_index < $size(mux_tb_depths); mux_depth_index++) begin
            automatic integer mux_width = mux_tb_widths[mux_width_index];
            automatic integer mux_depth = mux_tb_depths[mux_depth_index];
 
            reg [0 : mux_width - 1][mux_depth - 1 : 0] i_input; // TODO variable-width packed arrays aren't supported...
            for (integer i_input_assign = 0; i_input_assign < mux_width; i_input_assign++)
                // Set the inputs bit to its index decimal value at its width index (with possible truncating)
                // since testing all possible depth bit combinations is computationally infeasible
                i_input[i_input_assign] = i_input_assign[mux_depth - 1 : 0];
            g_mux_width[mux_width_index].g_mux_depth[mux_depth_index].i_input = i_input;
 
            for (integer select = 0; select < mux_width; select++) begin
                g_mux_width[mux_width_index].g_mux_depth[mux_depth_index].select = select;
                #1;
 
                if (g_mux_width[mux_width_index].g_mux_depth[mux_depth_index].o_output != i_input)
                    $display("Failed mux test with width: %d and depth: %d with select: %d", mux_width, mux_depth, select);
            end
        end
    end
 
    $display("================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
*/

endmodule
