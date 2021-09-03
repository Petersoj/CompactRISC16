//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/02/2021
// Module Name: cr16_alu_tb
// Description: The CR16 ALU testbench
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

module alutest();
    
    // Inputs
    reg [15:0] I_op1;
    reg [15:0] I_op2;
    reg [3:0] Opcode;
    
    // Outputs
    wire [15:0] O_dest;
    wire [4:0] flags;
    
    integer i;
    // Instantiate the Unit Under Test (UUT)
    alu uut (
    .I_op1(I_op1),
    .I_op2(I_op2),
    .O_dest(O_dest),
    .Opcode(Opcode),
    .flags(flags)
    );
    
    initial begin
        //			$monitor("I_op1 %0d, I_op2: %0d, O_dest: %0d, flags[4:0]:%b, time:%0d", I_op1, I_op2, O_dest, flags[4:0], $time);
        //Instead of the $display stmt in the loop, you could use just this
        //monitor statement which is executed everytime there is an event on any
        //signal in the argument list.
        
        // Initialize Inputs
        I_op1  = 0;
        I_op2  = 0;
        Opcode = 2'b11;
        
        // Wait 100 ns for global reset to finish
        /*****
         // One vector-by-vector case simulation
         #10;
         Opcode = 2'b11;
         I_op1  = 4'b0010; I_op2  = 4'b0011;
         #10
         I_op1 = 4'b1111; I_op2 = 4'b 1110;
         //$display("I_op1: %b, I_op2: %b, O_dest:%b, flags[4:0]: %b, time:%d", I_op1, I_op2, O_dest, flags[4:0], $time);
         ****/
        //Random simulation
        for(i = 0; i< 10; i = i+ 1) begin
            #10
            I_op1 = $random %16;
            I_op2 = $random %16;
            $display("I_op1: %0d, I_op2: %0d, O_dest: %0d, flags[4:0]: %b, time:%0d", I_op1, I_op2, O_dest, flags[4:0], $time);
        end
        $finish(2);
        
        // Add stimulus here
        
    end
    
endmodule
