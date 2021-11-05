//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/24/2021
// Module Name: datapath_tb
// Description: A testbench for the CR16 datapath.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

`timescale 1ps/1ps

module datapath_tb();

// Inputs
reg [15:0] reg_write_enable; // Enables write to register
reg nreset;
reg [3:0] opcode;
reg clk;
reg [3:0] reg_a_select; // 4 bit selectors for register values to ALU
reg [3:0] reg_b_select;
reg [15:0] immediate;
reg immediate_select; // 1 if loading immediate, 0 otherwise
reg [15:0] regfile_data;
reg regfile_data_select;

// Outputs
wire [15:0] result_bus;
wire [4:0] status_flags;
wire [15:0] a;
wire [15:0] b;

// Parameterized Opcodes from 'rtl/cr16/alu.v'
localparam [3:0]
           ADD  = 4'd0,
           ADDC = 4'd1,
           MUL  = 4'd2,
           SUB  = 4'd3,
           NOT  = 4'd4,
           AND  = 4'd5,
           OR   = 4'd6,
           XOR  = 4'd7,
           LSH  = 4'd8,
           RSH  = 4'd9,
           ALSH = 4'd10,
           ARSH = 4'd11;

// Establish the clock signal to sync the test
always #1 clk = ~clk;

datapath uut
         (.I_CLK(clk),
          .I_ENABLE(1'b1),
          .I_NRESET(nreset),
          .I_REG_WRITE_ENABLE(reg_write_enable),
          .I_REG_A_SELECT(reg_a_select),
          .I_REG_B_SELECT(reg_b_select),
          .I_IMMEDIATE(immediate),
          .I_IMMEDIATE_SELECT(immediate_select),
          .I_OPCODE(opcode),
          .I_REGFILE_DATA(regfile_data),
          .I_REGFILE_DATA_SELECT(regfile_data_select),
          .O_A(a),
          .O_B(b),
          .O_RESULT_BUS(result_bus),
          .O_STATUS_FLAGS(status_flags));

integer i, num, prevNum, temp;

initial begin
    $display("\n================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    clk = 'b1;

    // Set initial register values to 0
    #2;
    nreset = 'b0;
    #2;
    nreset              = 'b1;
    reg_write_enable    = 'b0;
    reg_a_select        = 'b0;
    reg_b_select        = 'b0;
    immediate           = 'd0;
    immediate_select    = 'd0;
    opcode              = ADD;
    regfile_data        = 'd0;
    regfile_data_select = 'b0;
    #2;

    $display("================================================================");
    $display("Testing Fibbonacci Sequence");
    $display("================================================================");

    // Load 1 into registers 1 and 2
    immediate        = 1;
    immediate_select = 'd1;
    reg_write_enable = 'b0000_0000_0000_0001;
    #2;
    reg_write_enable = 'b0000_0000_0000_0010;
    #2;
    reg_write_enable = 'b0;

    // Begin test
    reg_a_select     = 'b0000;
    reg_b_select     = 'b0001;
    immediate_select = 0;
    #2;

    num              = 1;
    prevNum          = 0;
    reg_write_enable = 'b0000_0000_0000_0100;
    for(i = 0; i < 15; i = i + 1) begin
        #5;

        if ((num + prevNum) != result_bus)
            $display("Fibbonacci test failed: Expected: %0d, Actual: %0d", num + prevNum, result_bus);

        temp    = num;
        num     = temp + prevNum;
        prevNum = temp;

        reg_a_select     = reg_a_select + 'b0001;
        reg_b_select     = reg_b_select + 'b0001;
        reg_write_enable <<= 1;
        #2;
    end

    $display("\n================================================================");
    $display("Testing Signed Operations");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    nreset = 'b0;
    #2;
    nreset              = 'b1;
    reg_write_enable    = 'b0;
    reg_a_select        = 'b0;
    reg_b_select        = 'b0;
    immediate           = 'd0;
    immediate_select    = 'd0;
    opcode              = SUB;
    regfile_data        = 'd0;
    regfile_data_select = 'b0;
    #2;

    // Load 1 into register 2
    immediate        = 1;
    immediate_select = 1;
    reg_write_enable = 'b0000_0000_0000_0010;
    #2;
    immediate_select = 0;

    // Begin test
    reg_a_select     = 0;
    reg_b_select     = 1;
    reg_write_enable = 'b0000_0000_0000_0100;
    #2;

    if (result_bus != 'b1111_1111_1111_1111)
        $display("Test Failed in signed operations: Expected: %b, Actual: %b", 16'b1111_1111_1111_1111, result_bus);

    $display("\n================================================================");
    $display("Testing Boolean Operations");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    nreset = 'b0;
    #2;
    nreset              = 'b1;
    reg_write_enable    = 'b0;
    reg_a_select        = 'b0;
    reg_b_select        = 'd5;
    immediate           = 'd0;
    immediate_select    = 'd0;
    opcode              = 'd0;
    regfile_data        = 'd0;
    regfile_data_select = 'b0;
    #2;

    // Load 7 (0111) into register 0
    immediate        = 'd7;
    immediate_select = 1;
    reg_write_enable = 'b0000_0000_0000_0001;
    #2;
    // Load 4 (0100) into register 1
    immediate        = 'd4;
    reg_write_enable = 'b0000_0000_0000_0010;
    #2;
    immediate_select = 0;

    // Begin test
    reg_a_select     = 0;
    reg_b_select     = 1;
    reg_write_enable = 'b0000_0000_0000_0100;

    // Test AND
    opcode = AND;
    #2;
    if (result_bus != 4)
        $display("Boolean test failed in AND Expected: %b, Actual: %b", 16'd4, result_bus);

    reg_write_enable <<= 1;
    #2;

    // Test OR
    opcode = OR;
    #2;
    if (result_bus != 7)
        $display("Boolean test failed in OR Expected: %b, Actual: %b", 16'd7, result_bus);

    reg_write_enable <<= 1;
    #2;

    // Test XOR
    opcode = XOR;
    #2;
    if (result_bus != 3)
        $display("Boolean test failed in XOR Expected: %b, Actual: %b", 16'd3, result_bus);

    reg_write_enable <<= 1;
    #2;

    // Test NOT
    opcode = NOT;
    #2;
    if (result_bus != ~16'd7)
        $display("Boolean test failed in NOT Expected: %b, Actual: %b", ~16'd7, result_bus);

    reg_write_enable <<= 1;
    #2;

    $display("\n================================================================");
    $display("Testing Reg Data Select");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    nreset = 'b0;
    #2;
    nreset              = 'b1;
    reg_write_enable    = 'b0;
    reg_a_select        = 'b0;
    reg_b_select        = 'b0;
    immediate           = 'd0;
    immediate_select    = 'd0;
    opcode              = 'd10;
    regfile_data        = 'd0;
    regfile_data_select = 'b0;
    #2;

    // Begin Test
    // Load 5 into first register
    regfile_data        = 'd5;
    regfile_data_select = 'b1;
    reg_write_enable    = 'b0000_0000_0000_0001;
    #2;

    if (result_bus != 5)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd5, result_bus);

    // Load 6 into second register
    regfile_data        = 'd6;
    regfile_data_select = 'b1;
    reg_write_enable    = 'b0000_0000_0000_0010;
    #2;

    if (result_bus != 6)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd6, result_bus);

    // Add first and second registers into third register
    reg_a_select        = 0;
    reg_b_select        = 1;
    regfile_data_select = 'b0;
    reg_write_enable    = 'b0000_0000_0000_0100;
    opcode              = 'b0000;
    #2;
    if (result_bus != 11)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd11, result_bus);

    $display("\n================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
