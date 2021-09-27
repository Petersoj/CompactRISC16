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

// Outputs
wire [15:0] O_RESULT_BUS;
wire [4:0] O_STATUS_FLAGS;

// establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

datapath uut(.I_CLK(I_CLK),
             .I_ENABLE(1'b1),
             .I_NRESET(I_NRESET),
             .I_REG_WRITE_ENABLE(I_REG_WRITE_ENABLE),
             .I_REG_A_SELECT(I_REG_A_SELECT),
             .I_REG_B_SELECT(I_REG_B_SELECT),
             .I_IMMEDIATE_SELECT(I_IMM_SELECT),
             .I_IMMEDIATE(I_IMMEDIATE),
             .I_OPCODE(I_OPCODE),
             .O_RESULT_BUS(O_RESULT_BUS),
             .O_STATUS_FLAGS(O_STATUS_FLAGS));

integer i, num, prevNum, temp;

initial begin
    $display("================================================================");
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
    I_OPCODE = 'd0;
    #2;

    $display("================================================================");
    $display("BEGIN Testing Fibbonacci Sequence");
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

    $display("================================================================");
    $display("END Testing Fibbonacci Sequence");
    $display("================================================================\n");

    $display("================================================================");
    $display("BEGIN Testing Signed Operations");
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
    I_OPCODE = 'b00100;
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

    $display("================================================================");
    $display("END Testing Signed Operations");
    $display("================================================================\n");

    $display("================================================================");
    $display("BEGIN Testing Boolean Operations");
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
    I_OPCODE = 'b0110;
    #2;
    if (O_RESULT_BUS != 4)
        $display("Boolean test failed in AND Expected: %b, Actual: %b", 16'd4, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test OR
    I_OPCODE = 'b0111;
    #2;
    if (O_RESULT_BUS != 7)
        $display("Boolean test failed in OR Expected: %b, Actual: %b", 16'd7, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test XOR
    I_OPCODE = 'b1000;
    #2;
    if (O_RESULT_BUS != 3)
        $display("Boolean test failed in XOR Expected: %b, Actual: %b", 16'd3, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    // Test NOT
    I_OPCODE = 'b1001;
    #2;
    if (O_RESULT_BUS != ~16'd7)
        $display("Boolean test failed in NOT Expected: %b, Actual: %b", ~16'd7, O_RESULT_BUS);

    I_REG_WRITE_ENABLE <<= 1;
    #2;

    $display("================================================================");
    $display("END Testing Boolean Operations");
    $display("================================================================\n");

    $display("================================================================");
    $display("BEGIN Testing Bit Shifting");
    $display("================================================================");

    // Set initial register values to 0
    /*    #2;
        I_NRESET = 'b0;
        #2;
        I_NRESET = 'b1;
        I_REG_WRITE_ENABLE = 'b0;
        I_REG_A_SELECT = 'b0;
        I_REG_B_SELECT = 'b0;
        I_IMMEDIATE = 'd0;
        I_IMM_SELECT = 'd0;
        I_OPCODE = 'd10;
        #2;

        // Load 1 into registers 1 and 2
        I_IMMEDIATE = 1;
        I_IMM_SELECT = 1;
        I_REG_WRITE_ENABLE = 'b0000_0000_0000_0001;
        #2;
        I_REG_WRITE_ENABLE = 'b0000_0000_0000_0010;
        #2;
        I_IMM_SELECT = 0;

        // Begin test
        I_REG_A_SELECT = 0;
        I_REG_B_SELECT = 1;
        I_REG_WRITE_ENABLE = 'b0000_0000_0000_0100;

        num = 1;
        for(i = 0; i < 15; i = i + 1) begin
            #2;
            num *= 2;

            if (num != O_RESULT_BUS)
                $display("Test Failed in bit shifting: Expected: %0d, Actual: %0d", num, O_RESULT_BUS);

            I_REG_B_SELECT = I_REG_B_SELECT + 1;
            I_REG_WRITE_ENABLE <<= 1;
        end*/

    $display("================================================================");
    $display("END Testing Bit Shifting");
    $display("================================================================\n");

    $display("================================================================");
    $display("=========================== END SIM ============================");
    $display("================================================================");
    $stop;
end
endmodule
