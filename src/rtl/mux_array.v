//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: mux_array
// Description: A generic mux array
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module mux_array #(parameter SIZE = 4) (
           input sel,
           input [SIZE-1:0] a, b,
           output [SIZE-1:0] o
       );

genvar i;

generate
    for (i = 0; i < SIZE; i = i + 1) begin: MUXarray
        mux m(.i({a[i], b[i]}), .sel(sel), .o(o[i]));
    end
endgenerate
endmodule
