//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: mux
// Description: A generic multiplexer (mux)
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module mux(
           input [1:0] i,
           input sel,
           output reg o
       );

always @(*) begin
    if(sel)
        o <= i[1];

    else
        o <= i[0];
end

endmodule
