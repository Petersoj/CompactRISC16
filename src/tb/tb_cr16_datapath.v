module tb_cr16_datapath ();

// Inputs
reg [15:0] I_REG_ENABLE; // Enables write to register
reg I_NRESET;
reg [3:0] I_OPCODE;
reg I_CLK;
reg I_ENABLE; // Global enable signal
reg I_READ_PORT_A_SEL;
reg I_READ_PORT_B_SEL;
reg I_IMMEDIATE;
reg I_IMM_SEL; // 1 if loading immediate, 0 otherwise

// Outputs
wire [15:0] O_WRITE_PORT;
wire [4:0] O_FLAGS;

// establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

integer i, num, prevNum;

cr16_datapath datapath(
			.I_REG_ENABLE(I_REG_ENABLE),
			.I_NRESET(I_NRESET),
			.I_OPCODE(I_OPCODE),
			.I_CLK(I_CLK),
			.I_ENABLE(I_ENABLE),
			.I_READ_PORT_A_SEL(I_READ_PORT_A_SEL),
			.I_READ_PORT_B_SEL(I_READ_PORT_B_SEL),
			.I_IMMEDIATE(I_IMMEDIATE),
			.I_IMM_SEL(I_IMM_SEL),
			.O_WRITE_PORT(O_WRITE_PORT),
			.O_FLAGS(O_FLAGS)
			);

		 
initial begin

	// Initialize Inputs
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	I_NRESET = 0;
	I_OPCODE = 4'b0000;
	I_ENABLE = 1;
	I_IMMEDIATE = 0;
	I_IMM_SEL = 1;
	
	// Set initial register values to 0
	for(i = 0; i < 14; i = i + 1) begin
		I_REG_ENABLE << 1;
		#2;
		
	end
	
	// Load 1 into registers 1 and 2
	I_IMMEDIATE = 1;
	I_REG_ENABLE = 16'b0000_0000_0000_0001;
	#2;
	I_REG_ENABLE = 16'b0000_0000_0000_0010;
	#2;
	
	I_IMM_SEL = 0;
	
	// Begin test
	I_READ_PORT_A_SEL = 0;
	I_READ_PORT_B_SEL = 1;
	num = 1;
	prevNum = 1;
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	for(i = 0; i < 15; i = i + 1) begin
		#2
		
		if ((num + prevNum) != O_WRITE_PORT)
                $display("Borked Expected: %0d, Actual: %0d", num + prevNum, O_WRITE_PORT);
		prevNum = num;
		num = O_WRITE_PORT;
		
		I_READ_PORT_A_SEL = I_READ_PORT_A_SEL+ 1;
		I_READ_PORT_B_SEL = I_READ_PORT_B_SEL+ 1;
		I_REG_ENABLE << 1;
		
	end
	
	
	end

endmodule
