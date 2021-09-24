//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/23/2021
// Module Name: mux_array
// Description: A generic mux array
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module mux_array
       #(parameter SIZE = 16)
       (input sel,
        input [SIZE-1:0] a, b,
        output [SIZE-1:0] o);

genvar i;
generate
    for (i = 0; i < SIZE; i = i + 1) begin: make_muxes
        mux2_1 i_mux2_1(.INPUT({a[i], b[i]}),
                        .s(sel),
                        .OUT(o[i]));
    end
endgenerate
endmodule
