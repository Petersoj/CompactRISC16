//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/25/2021
// Module Name: mux
// Description: A parameterized multiplexer (mux).
// Authors: Jacob Peterson
//

// @param P_WIDTH  the width parameter of this mux. e.g. for a '4-to-1' mux, this number would be 4.
// @param P_DEPTH  the bit depth of each mux input/output. This defines how many bits each mux input contains
//                 so that multiple bits can be multiplexed through this mux.
// @param I_INPUT  a 2-dimensional packed array where the first dimension (with a width of 'P_WIDTH') is the
//                 multiplexed dimension and the second dimension (with a width of 'P_DEPTH') contains the depth bits
//                 for the multiplexed dimension. The second dimension is optional.
// @param I_SELECT a decimal value input to determine which 'I_INPUT' value is selected/multiplexed. The width of this
//                 vector is always the $clog2 of 'P_WIDTH'.
// @param O_OUTPUT the output/multiplexed value of this mux. The width of this vector is always 'P_DEPTH'.
module mux
       #(parameter integer P_WIDTH = 'd2,
         parameter integer P_DEPTH = 'd1)
       (input wire [P_WIDTH - 1 : 0][P_DEPTH - 1 : 0] I_INPUT,
        input wire [$clog2(P_WIDTH) - 1 : 0] I_SELECT,
        output wire [P_DEPTH - 1 : 0] O_OUTPUT);

// The following generate block will loop through and make the 'layers' consisting of parallel muxes that make up a
// standard 'n-to-1' mux. Each layer corresponds to a 'I_SELECT' bit, with the LSB of the 'I_SELECT' bit being the
// left-most first layer and the MSB bit being the right-most last layer. Each mux in a layer uses the corresponding
// output wires of the muxes in the previous layer, then those values are multiplexed and passed to an output wire
// to be used for the next layer, and so on.
genvar layer_index, mux_index;
generate
    for (layer_index = 0; layer_index < $clog2(P_WIDTH); layer_index++) begin: g_layer
        for (mux_index = 0; mux_index < 2 ** ($clog2(P_WIDTH) - 1 - layer_index); mux_index++) begin: g_mux
            wire [1:0][P_DEPTH - 1 : 0] mux_input;
            wire [P_DEPTH - 1 : 0] mux_output;

            // If this is the first layer, use the 'I_INPUT' bits as the inputs to this mux instance, otherwise,
            // use the corresponding output bits of the previous layer
            if (layer_index == 0)
                assign mux_input = {I_INPUT[mux_index * 2 + 1],
                                    I_INPUT[mux_index * 2]};
            else
                assign mux_input = {g_layer[layer_index - 1].g_mux[mux_index * 2 + 1].mux_output,
                                    g_layer[layer_index - 1].g_mux[mux_index * 2].mux_output};

            // If this is the last layer, assign 'O_OUTPUT' to be the output of this last mux instance
            if (layer_index == $clog2(P_WIDTH) - 1)
                assign O_OUTPUT = mux_output;

            // Assign this mux instance output using combinational logic with appropriate 'select' and 'input' vectors
            wire [P_DEPTH - 1 : 0] repeated_i_select = {P_DEPTH{I_SELECT[layer_index]}};
            assign mux_output = (~repeated_i_select & mux_input[0]) | (repeated_i_select & mux_input[1]);
        end
    end
endgenerate
endmodule
