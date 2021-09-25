//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/21/2021
// Module Name: regfile_tb
// Description: A testbench for the CR16 register file.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

`timescale 1ps/1ps

module regfile_tb();

// Inputs
reg [15:0] reg_bus;
reg [15:0] reg_enable;
reg clk;

// Outputs
wire [15:0] reg_data [15:0];

// Establish the clock signal to sync the test.
always #5 clk = ~clk;

// Instantiate the Unit Under Test (UUT).
regfile uut(.I_NRESET(1'b1), // Inverted reset will be permanently high.
            .I_CLK(clk),
            .I_REG_BUS(reg_bus),
            .I_REG_ENABLE(reg_enable),
            .O_REG_DATA(reg_data));

integer i, j;

initial begin
    $display("================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    clk = 0;

    #20;
    // Loop through all registers in the register file.
    for (i = 0; i < 16; i++) begin
        // Reset reg_enable so that it may be used for one-hot encoding.
        reg_enable = 0;

        // Enable the next register.
        reg_enable[i] = 1'b1;

        // Loop through a sample series to store in the register.
        for (j = 0; j < 65_535; j += 1_024) begin
            reg_bus = j;
            #10;
            if (reg_data[i] != j)
                $display("Register [%d] data incorrect: expected %d, got %d.", i, j, reg_data[i]);
        end
    end

    $display("================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
