//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/30/2021
// Module Name: bram_tb
// Description: Testbench for BRAM memory, must use a file to initialize the first 8 memory
//              addresses to numbers 1-8.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

`timescale 1ps / 1ps

module bram_tb();

reg clk;
reg [15:0] i_data_a, i_data_b;
reg [9:0] address_a, address_b;
reg write_enable_a, write_enable_b;
reg [15:0] o_data_a, o_data_b;

always #1 clk = ~clk;

// Note: if you're running this tb from Modelsim via Quartus Prime, the 'P_BRAM_INIT_FILE'
// directory structure must exist in the 'simulation/modelsim' directory, so simply copy the
// 'resources' folder at the root of this Git project into the 'simulation/modelsim' directory.
bram #(.P_BRAM_INIT_FILE("resources/bram_init/lib/bram_tb_init.dat"),
       .P_BRAM_INIT_FILE_START_ADDRESS('d0),
       .P_DATA_WIDTH('d16),
       .P_ADDRESS_WIDTH('d10))
     uut
     (.I_CLK(clk),
      .I_DATA_A(i_data_a),
      .I_DATA_B(i_data_b),
      .I_ADDRESS_A(address_a),
      .I_ADDRESS_B(address_b),
      .I_WRITE_ENABLE_A(write_enable_a),
      .I_WRITE_ENABLE_B(write_enable_b),
      .O_DATA_A(o_data_a),
      .O_DATA_B(o_data_b));

integer i;
initial begin
    $display("================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    // Initialize enable and address pointers.
    clk = 0;
    address_a = 10'b0000000000;
    address_b = 10'b0000000000;
    write_enable_a = 1'b0;
    write_enable_b = 1'b0;
    i_data_a = 16'h0000;
    i_data_b = 16'h0000;

    $display("\n================================================================");
    $display("Test 1: Read sequential values addresses 0-7 on port A.");
    $display("================================================================");

    // Read data on one port.
    for (i = 0; i < 8; i++) begin
        address_a = i[9:0];
        #2;
        if (o_data_a != (i + 1))
            $display("Initial read failed. Got: %b, Expected: %b.", o_data_a, i);
    end

    $display("\n================================================================");
    $display("Test 2: Read sequential values addresses 0-5 on port A and");
    $display("simultaneously read 2-7 on port B.");
    $display("================================================================");

    // Read data on two ports at once.
    address_a = 10'b0000000000; // Start at index 0
    address_b = 10'b0000000001; // Start at index 2

    for (i = 0; i < 6; i++) begin
        address_a = i[9:0];
        address_b = address_b + 1'b1;
        #2;
        if (o_data_a != (i + 1))
            $display("Initial read A failed. Got: %b, Expected: %b.", o_data_a, i);
        if (o_data_b != (i + 3))
            $display("Initial read B failed. Got: %b, Expected: %b.", o_data_b, i);
    end

    $display("\n================================================================");
    $display("Test 3: Write incrementing i * 2 into data addresses 0-7 using");
    $display("port A, read them on port B to verify correctness.");
    $display("================================================================");

    address_a = 10'b0000000000;
    address_b = 10'b0000000000;
    write_enable_b = 1'b0;

    // Write i * 2 into bram
    for (i = 0; i < 8; i++) begin
        write_enable_a = 1'b0;
        i_data_a = i[15:0] * 2;
        address_a = i[9:0];
        #2;
        write_enable_a = 1'b1;
        #2;
    end

    write_enable_a = 1'b0;

    // Check if bram was wrote into correctly
    for (i = 0; i < 8; i++) begin
        address_b = i[9:0];
        #2;
        if (o_data_b != (i * 2))
            $display("Bram write failed. Got: %b, Expected: %b.", o_data_b, i * 2);
    end

    $display("\n================================================================");
    $display("Test 4: Write incrementing i * 3 into data addresses 0-7 using");
    $display("port B, read them on port A to verify correctness.");
    $display("================================================================");

    address_a = 10'b0000000000;
    address_b = 10'b0000000000;
    write_enable_a = 1'b0;

    // Write i * 3 into bram
    for (i = 0; i < 8; i++) begin
        write_enable_b = 1'b0;
        i_data_b = i[15:0] * 3;
        address_b = i[9:0];
        #2;
        write_enable_b = 1'b1;
        #2;
    end

    write_enable_b = 1'b0;

    // Check if bram was written into correctly
    for (i = 0; i < 8; i++) begin
        address_a = i[9:0];
        #2;
        if (o_data_a != (i * 3))
            $display("Bram write failed. Got: %b, Expected: %b.", o_data_a, i * 3);
    end

    $display("\n================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop();
end
endmodule
