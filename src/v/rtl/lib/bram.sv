//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/28/2021
// Module Name: bram
// Description: A BRAM (Block Random Access Memory) module (from Quartus Prime Verilog Template).
// Authors: Quartus Prime Template, Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param P_BRAM_INIT_FILE the file path (relative to working directory) of a UTF-encoded file
//                         containing hex digits that BRAM will initilize to. If empty, then
//                         BRAM will initialize with all zeros.
// @param P_DATA_WIDTH     the width of the data
// @param P_ADDRESS_WIDTH  the width of the address line
// @param I_CLK            the clock signal
// @param I_DATA_A         the input data for Port A
// @param I_DATA_B         the input data for Port B
// @param I_ADDRESS_A      the address line for Port A
// @param I_ADDRESS_B      the address line for Port B
// @param I_WRITE_ENABLE_A the write/read enable signal for Port A
// @param I_WRITE_ENABLE_B the write/read enable signal for Port B
// @param O_DATA_A         the output data for Port A
// @param O_DATA_B         the output data for Port B
module bram
       #(parameter P_BRAM_INIT_FILE = "",
         parameter integer P_BRAM_INIT_FILE_START_ADDRESS = -1,
         parameter integer P_BRAM_INIT_FILE_END_ADDRESS = -1,
         parameter integer P_DATA_WIDTH = 16,
         parameter integer P_ADDRESS_WIDTH = 10)
       (input I_CLK,
        input [P_DATA_WIDTH - 1 : 0] I_DATA_A, I_DATA_B,
        input [P_ADDRESS_WIDTH - 1 : 0] I_ADDRESS_A, I_ADDRESS_B,
        input I_WRITE_ENABLE_A, I_WRITE_ENABLE_B,
        output reg [P_DATA_WIDTH - 1 : 0] O_DATA_A, O_DATA_B);

reg [P_DATA_WIDTH - 1 : 0] ram [0 : 2 ** P_ADDRESS_WIDTH - 1]; // 2D register array for RAM

// Initialize entire BRAM to zeros if 'P_BRAM_INIT_FILE' is empty or
// read contents of 'P_BRAM_INIT_FILE' file to BRAM.
integer index;
initial begin
    if (P_BRAM_INIT_FILE == "")
        for (index = 0; index < 2 ** P_ADDRESS_WIDTH; index++)
            ram[index] = {P_DATA_WIDTH{1'd0}};
    else
        // '$readmemh' here is meant to mimic a ROM and works only on FGPAs and in simulations
        if (P_BRAM_INIT_FILE_START_ADDRESS != -1 && P_BRAM_INIT_FILE_END_ADDRESS != -1)
            $readmemh(P_BRAM_INIT_FILE, ram,
                      P_BRAM_INIT_FILE_START_ADDRESS, P_BRAM_INIT_FILE_END_ADDRESS);
        else if (P_BRAM_INIT_FILE_START_ADDRESS != -1)
            $readmemh(P_BRAM_INIT_FILE, ram, P_BRAM_INIT_FILE_START_ADDRESS);
        else
            $readmemh(P_BRAM_INIT_FILE, ram);
end

// Port A
always @(posedge I_CLK) begin
    if (I_WRITE_ENABLE_A) begin
        ram[I_ADDRESS_A] <= I_DATA_A;
        O_DATA_A         <= O_DATA_A;
    end
    else
        O_DATA_A <= ram[I_ADDRESS_A];
end

// Port B
always @(posedge I_CLK) begin
    if (I_WRITE_ENABLE_B) begin
        ram[I_ADDRESS_B] <= I_DATA_B;
        O_DATA_B         <= O_DATA_B;
    end
    else
        O_DATA_B <= ram[I_ADDRESS_B];
end
endmodule
