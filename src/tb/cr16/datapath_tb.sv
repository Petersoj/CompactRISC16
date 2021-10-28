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
reg [15:0] I_REG_WRITE_ENABLE; // Enables write to register
reg I_NRESET;
reg [3:0] I_OPCODE;
reg I_CLK;
reg [3:0] I_REG_A_SELECT; // 4 bit selectors for register values to ALU
reg [3:0] I_REG_B_SELECT;
reg [15:0] I_IMMEDIATE;
reg I_IMM_SELECT; // 1 if loading immediate, 0 otherwise
reg [15:0] I_REGFILE_DATA;
reg I_REGFILE_DATA_SELECT;

// Outputs
wire [15:0] O_RESULT_BUS;
wire [4:0] O_STATUS_FLAGS;
wire [15:0] O_A;
wire [15:0] O_B;

// Parameterized Opcodes from 'rtl/cr16/alu.v'
localparam [3:0]
           ADD = 0,   // Unsigned and signed addition
           ADDC = 1,  // Unsigned and signed addition with carry
           MUL = 2,   // Signed multiplication
           SUB = 3,   // Unsigned and signed subtraction
           NOT = 4,   // Bitwise NOT
           AND = 5,   // Bitwise AND
           OR = 6,    // Bitwise OR
           XOR = 7,   // Bitwise XOR
           LSH = 8,   // Logical left shift
           RSH = 9,   // Logical right shift
           ALSH = 10, // Arithmetic (sign-extending) left shift
           ARSH = 11; // Arithmetic (sign-extending) right shift

// Establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

datapath uut
         (.I_CLK(I_CLK),
          .I_ENABLE(1'b1),
          .I_NRESET(I_NRESET),
          .I_REG_WRITE_ENABLE(I_REG_WRITE_ENABLE),
          .I_REG_A_SELECT(I_REG_A_SELECT),
          .I_REG_B_SELECT(I_REG_B_SELECT),
          .I_IMMEDIATE(I_IMMEDIATE),
          .I_IMMEDIATE_SELECT(I_IMM_SELECT),
          .I_OPCODE(I_OPCODE),
          .I_STATUS_FLAGS({5{1'b0}}),
          .I_STATUS_FLAGS_SELECT(1'b0),
          .I_REGFILE_DATA(I_REGFILE_DATA),
          .I_REGFILE_DATA_SELECT(I_REGFILE_DATA_SELECT),
          .O_A(O_A),
          .O_B(O_B),
          .O_RESULT_BUS(O_RESULT_BUS),
          .O_STATUS_FLAGS(O_STATUS_FLAGS));

integer i, num, prevNum, temp;

initial begin
    $display("\n================================================================");
    $display("========================== BEGIN SIM ===========================");
    $display("================================================================");

    I_CLK = 'b1;

    // Set initial register values to 0
    #2;
    I_NRESET = 'b0;
    #2;
    I_NRESET = 'b1;
    I_REG_WRITE_ENABLE = 'b0;
    I_REG_A_SELECT = 'b0;
    I_REG_B_SELECT = 'b0;
    I_IMMEDIATE = 'd0;
    I_IMM_SELECT = 'd0;
    I_OPCODE = ADD;
    I_REGFILE_DATA = 'd0;
    I_REGFILE_DATA_SELECT = 'b0;
    #2;

    $display("================================================================");
    $display("Testing Fibbonacci Sequence");
    $display("================================================================");

    // Load 1 into registers 1 and 2
    I_IMMEDIATE = 1;
    I_IMM_SELECT = 'd1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0001;
    #2;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0010;
    #2;
    I_REG_WRITE_ENABLE = 'b0;

    // Begin test
    I_REG_A_SELECT = 'b0000;
    I_REG_B_SELECT = 'b0001;
    I_IMM_SELECT = 0;
    #2;

    num = 1;
    prevNum = 0;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0100;
    for(i = 0; i < 15; i = i + 1) begin
        #5;

        if ((num + prevNum) != O_RESULT_BUS)
            $display("Fibbonacci test failed: Expected: %0d, Actual: %0d", num + prevNum, O_RESULT_BUS);

        temp = num;
        num = temp + prevNum;
        prevNum = temp;

        I_REG_A_SELECT = I_REG_A_SELECT + 'b0001;
        I_REG_B_SELECT = I_REG_B_SELECT + 'b0001;
        I_REG_WRITE_ENABLE <<= 1;
        #2;
    end

    $display("\n================================================================");
    $display("Testing Signed Operations");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    I_NRESET = 'b0;
    #2;
    I_NRESET = 'b1;
    I_REG_WRITE_ENABLE = 'b0;
    I_REG_A_SELECT = 'b0;
    I_REG_B_SELECT = 'b0;
    I_IMMEDIATE = 'd0;
    I_IMM_SELECT = 'd0;
    I_OPCODE = SUB;
    I_REGFILE_DATA = 'd0;
    I_REGFILE_DATA_SELECT = 'b0;
    #2;

    // Load 1 into register 2
    I_IMMEDIATE = 1;
    I_IMM_SELECT = 1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0010;
    #2;
    I_IMM_SELECT = 0;

    // Begin test
    I_REG_A_SELECT = 0;
    I_REG_B_SELECT = 1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0100;
    #2;

    if (O_RESULT_BUS != 'b1111_1111_1111_1111)
        $display("Test Failed in signed operations: Expected: %b, Actual: %b", 16'b1111_1111_1111_1111, O_RESULT_BUS);

    $display("\n================================================================");
    $display("Testing Boolean Operations");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    I_NRESET = 'b0;
    #2;
    I_NRESET = 'b1;
    I_REG_WRITE_ENABLE = 'b0;
    I_REG_A_SELECT = 'b0;
    I_REG_B_SELECT = 'd5;
    I_IMMEDIATE = 'd0;
    I_IMM_SELECT = 'd0;
    I_OPCODE = 'd0;
    I_REGFILE_DATA = 'd0;
    I_REGFILE_DATA_SELECT = 'b0;
    #2;

    // Load 7 (0111) into register 0
    I_IMMEDIATE = 'd7;
    I_IMM_SELECT = 1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0001;
    #2;
    // Load 4 (0100) into register 1
    I_IMMEDIATE = 'd4;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0010;
    #2;
    I_IMM_SELECT = 0;

    // Begin test
    I_REG_A_SELECT = 0;
    I_REG_B_SELECT = 1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0100;

    // Test AND
    I_OPCODE = AND;
    #2;
    if (O_RESULT_BUS != 4)
        $display("Boolean test failed in AND Expected: %b, Actual: %b", 16'd4, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test OR
    I_OPCODE = OR;
    #2;
    if (O_RESULT_BUS != 7)
        $display("Boolean test failed in OR Expected: %b, Actual: %b", 16'd7, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test XOR
    I_OPCODE = XOR;
    #2;
    if (O_RESULT_BUS != 3)
        $display("Boolean test failed in XOR Expected: %b, Actual: %b", 16'd3, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test NOT
    I_OPCODE = NOT;
    #2;
    if (O_RESULT_BUS != ~16'd7)
        $display("Boolean test failed in NOT Expected: %b, Actual: %b", ~16'd7, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    $display("\n================================================================");
    $display("Testing Reg Data Select");
    $display("================================================================");

    // Set initial register values to 0
    #2;
    I_NRESET = 'b0;
    #2;
    I_NRESET = 'b1;
    I_REG_WRITE_ENABLE = 'b0;
    I_REG_A_SELECT = 'b0;
    I_REG_B_SELECT = 'b0;
    I_IMMEDIATE = 'd0;
    I_IMM_SELECT = 'd0;
    I_OPCODE = 'd10;
    I_REGFILE_DATA = 'd0;
    I_REGFILE_DATA_SELECT = 'b0;
    #2;

    // Begin Test
    // Load 5 into first register
    I_REGFILE_DATA = 'd5;
    I_REGFILE_DATA_SELECT = 'b1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0001;
    #2;

    if (O_RESULT_BUS != 5)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd5, O_RESULT_BUS);

    // Load 6 into second register
    I_REGFILE_DATA = 'd6;
    I_REGFILE_DATA_SELECT = 'b1;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0010;
    #2;

    if (O_RESULT_BUS != 6)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd6, O_RESULT_BUS);

    // Add first and second registers into third register
    I_REG_A_SELECT = 0;
    I_REG_B_SELECT = 1;
    I_REGFILE_DATA_SELECT = 'b0;
    I_REG_WRITE_ENABLE = 'b0000_0000_0000_0100;
    I_OPCODE = 'b0000;
    #2;
    if (O_RESULT_BUS != 11)
        $display("Reg Data Select test failed Expected: %b, Actual: %b", 16'd11, O_RESULT_BUS);

    $display("\n================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
