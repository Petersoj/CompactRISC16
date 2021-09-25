module tb_cr16_datapath ();

// Inputs
reg [15:0] I_REG_ENABLE; // Enables write to register
reg I_NRESET;
reg [3:0] I_OPCODE;
reg I_CLK;
reg I_ENABLE; // Global enable signal
reg [3:0] I_READ_PORT_A_SEL; // 4 bit selectors for register values to ALU
reg [3:0] I_READ_PORT_B_SEL;
reg I_IMMEDIATE;
reg I_IMM_SEL; // 1 if loading immediate, 0 otherwise

// Outputs
wire [15:0] O_WRITE_PORT;
wire [4:0] O_FLAGS;

// establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

integer i, num, prevNum, temp;

cr16_datapath datapath(
			.I_REG_WRITE_ENABLE(I_REG_ENABLE),
			.I_NRESET(I_NRESET),
			.I_OPCODE(I_OPCODE),
			.I_CLK(I_CLK),
			.I_ENABLE(I_ENABLE),
			.I_REG_A_SELECT(I_READ_PORT_A_SEL),
			.I_REG_B_SELECT(I_READ_PORT_B_SEL),
			.I_IMMEDIATE(I_IMMEDIATE),
			.I_IMMEDIATE_SELECT(I_IMM_SEL),
			.O_RESULT_BUS(O_WRITE_PORT),
			.O_STATUS_FLAGS(O_FLAGS)
			);

		 
initial begin

	//////////////////////////////////////////////////////////
	/// #1: Fibbonacci Sequence
	//////////////////////////////////////////////////////////
	// Initialize Inputs
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	I_NRESET = 0;
	I_OPCODE = 4'b0000;
	I_ENABLE = 1;
	I_IMMEDIATE = 4'h0000;
	I_IMM_SEL = 1;
	I_CLK = 0;
	
	
	// Set initial register values to 0
	for(i = 0; i < 14; i = i + 1) begin
		I_REG_ENABLE <<= 1;
		#5;
		
	end
	
	// Load 1 into registers 1 and 2
	I_IMMEDIATE = 4'h0001;
	I_REG_ENABLE = 16'b0000_0000_0000_0001;
	#5;
	I_REG_ENABLE = 16'b0000_0000_0000_0010;
	#5;
	I_NRESET = 1;
	// Begin test
	I_READ_PORT_A_SEL = 4'b0000;
	I_READ_PORT_B_SEL = 4'b0001;
	#5
	I_IMM_SEL = 0;
	
	num = 1;
	prevNum = 1;
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	for(i = 0; i < 15; i = i + 1) begin
		#5;
		
		if ((num + prevNum) != O_WRITE_PORT)
                $display("Test Failed: Expected: %0d, Actual: %0d", num + prevNum, O_WRITE_PORT);
		prevNum = num;
		num = O_WRITE_PORT;
		
		I_READ_PORT_A_SEL = I_READ_PORT_A_SEL + 4'b0001;
		I_READ_PORT_B_SEL = I_READ_PORT_B_SEL + 4'b0001;
		I_REG_ENABLE <<= 1;
		
	end
	
	//////////////////////////////////////////////////////////
	/// #2: Signed Operations
	//////////////////////////////////////////////////////////
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	I_NRESET = 0;
	I_OPCODE = 4'b0100;
	I_ENABLE = 1;
	I_IMMEDIATE = 0;
	I_IMM_SEL = 1;
	
	// Set initial register values to 0
	for(i = 0; i < 14; i = i + 1) begin
		I_REG_ENABLE <<= 1;
		#2;
		
	end
	
	// Load 1 into register 2
	I_IMMEDIATE = 1;
	I_REG_ENABLE = 16'b0000_0000_0000_0010;
	#2;
	
	I_IMM_SEL = 0;
	
	// Begin test
	I_READ_PORT_A_SEL = 0;
	I_READ_PORT_B_SEL = 1;
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	
	if (O_WRITE_PORT != 16'b1111_1111_1111_1111)
				 $display("Test Failed in signed operations: Expected: %b, Actual: %b", 16'b1111_1111_1111_1111, O_WRITE_PORT);

	
	//////////////////////////////////////////////////////////
	/// #3: Boolean test
	//////////////////////////////////////////////////////////
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	I_NRESET = 0;
	I_OPCODE = 4'b0000;
	I_ENABLE = 1;
	I_IMMEDIATE = 0;
	I_IMM_SEL = 1;
	
	// Set initial register values to 0
	for(i = 0; i < 14; i = i + 1) begin
		I_REG_ENABLE <<= 1;
		#2;
		
	end
	
	// Load 7 (0111) into register 1
	I_IMMEDIATE = 7;
	I_REG_ENABLE = 16'b0000_0000_0000_0001;
	#5;
	// Load 4 (0100) into register 2
	I_IMMEDIATE = 4;
	I_REG_ENABLE = 16'b0000_0000_0000_0010;
	#5;
	
	I_IMM_SEL = 0;
	
	// Begin test
	I_READ_PORT_A_SEL = 0;
	I_READ_PORT_B_SEL = 1;
	
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	
	// Test AND
	I_OPCODE = 4'b0110;
	#5
	if (O_WRITE_PORT != 4)
				 $display("Boolean test failed in AND");
	I_REG_ENABLE <<= 1;
	#5
	
	// Test OR
	I_OPCODE = 4'b0111;
	#5
	if (O_WRITE_PORT != 7)
				 $display("Boolean test failed in OR");
	I_REG_ENABLE <<= 1;
	#5
	
	// Test xOR
	I_OPCODE = 4'b1000;
	#5
	if (O_WRITE_PORT != 3)
				 $display("Boolean test failed in xOR");
	I_REG_ENABLE <<= 1;
	#5
	
	// Test NOT
	I_OPCODE = 4'b1001;
	#5
	if (O_WRITE_PORT != 11)
				 $display("Boolean test failed in NOT");
	I_REG_ENABLE <<= 1;
	#5

	
	//////////////////////////////////////////////////////////
	/// #4: Bit shifting
	//////////////////////////////////////////////////////////
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	I_NRESET = 0;
	I_OPCODE = 4'b0000;
	I_ENABLE = 1;
	I_IMMEDIATE = 0;
	I_IMM_SEL = 1;
	
	// Set initial register values to 0
	for(i = 0; i < 14; i = i + 1) begin
		I_REG_ENABLE <<= 1;
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
	I_REG_ENABLE = 16'b0000_0000_0000_0100;
	
	num = 1;
	for(i = 0; i < 15; i = i + 1) begin
		#5
		
		num *= 2;
		if (num != O_WRITE_PORT)
                $display("Test Failed in bit shifting: Expected: %0d, Actual: %0d", num + prevNum, O_WRITE_PORT);

		
		I_READ_PORT_B_SEL = I_READ_PORT_B_SEL+ 1;
		I_REG_ENABLE <<= 1;
		
	end
	
	$stop;
	
	end

endmodule
module tb_cr16_datapath ();

// Inputs
reg [15:0] I_REG_ENABLE; // Enables write to register
reg I_NRESET;
reg [3:0] I_OPCODE;
reg I_CLK;
reg I_ENABLE; // Global enable signal
reg [3:0] I_READ_PORT_A_SEL; // 4 bit selectors for register values to ALU
reg [3:0] I_READ_PORT_B_SEL;
reg I_IMMEDIATE;
reg I_IMM_SEL; // 1 if loading immediate, 0 otherwise

// Outputs
wire [15:0] O_WRITE_PORT;
wire [4:0] O_FLAGS;

// establish the clock signal to sync the test
always #1 I_CLK = ~I_CLK;

integer i, num, prevNum;

cr16_datapath datapath(
                  .I_REG_WRITE_ENABLE(I_REG_ENABLE),
                  .I_NRESET(I_NRESET),
                  .I_OPCODE(I_OPCODE),
                  .I_CLK(I_CLK),
                  .I_ENABLE(I_ENABLE),
                  .I_REG_A_SELECT(I_READ_PORT_A_SEL),
                  .I_REG_B_SELECT(I_READ_PORT_B_SEL),
                  .I_IMMEDIATE(I_IMMEDIATE),
                  .I_IMMEDIATE_SELECT(I_IMM_SEL),
                  .O_RESULT_BUS(O_WRITE_PORT),
                  .O_STATUS_FLAGS(O_FLAGS)
              );


initial begin

    //////////////////////////////////////////////////////////
    /// #1: Fibbonacci Sequence
    //////////////////////////////////////////////////////////
    // Initialize Inputs
    I_REG_ENABLE = 16'b0000_0000_0000_0100;
    I_NRESET = 0;
    I_OPCODE = 4'b0000;
    I_ENABLE = 1;
    I_IMMEDIATE = 4'h0000;
    I_IMM_SEL = 1;
    I_CLK = 0;


    // Set initial register values to 0
    for(i = 0; i < 14; i = i + 1) begin
        I_REG_ENABLE <<= 1;
        #5;

    end

    // Load 1 into registers 1 and 2
    I_IMMEDIATE = 4'h0001;
    I_REG_ENABLE = 16'b0000_0000_0000_0001;
    #5;
    I_REG_ENABLE = 16'b0000_0000_0000_0010;
    #5;
    I_NRESET = 1;
    // Begin test
    I_READ_PORT_A_SEL = 4'b0000;
    I_READ_PORT_B_SEL = 4'b0001;
    #5
     I_IMM_SEL = 0;

    num = 1;
    prevNum = 1;
    I_REG_ENABLE = 16'b0000_0000_0000_0100;
    for(i = 0; i < 15; i = i + 1) begin
        #5;

        if ((num + prevNum) != O_WRITE_PORT)
            $display("Test Failed: Expected: %0d, Actual: %0d", num + prevNum, O_WRITE_PORT);
        prevNum = num;
        num = O_WRITE_PORT;

        I_READ_PORT_A_SEL = I_READ_PORT_A_SEL + 4'b0001;
        I_READ_PORT_B_SEL = I_READ_PORT_B_SEL + 4'b0001;
        I_REG_ENABLE <<= 1;

    end

    //////////////////////////////////////////////////////////
    /// #2: Signed Operations
    //////////////////////////////////////////////////////////
    I_REG_ENABLE = 16'b0000_0000_0000_0100;
    I_NRESET = 0;
    I_OPCODE = 4'b0000;
    I_ENABLE = 1;
    I_IMMEDIATE = 0;
    I_IMM_SEL = 1;

    // Set initial register values to 0
    for(i = 0; i < 14; i = i + 1) begin
        I_REG_ENABLE <<= 1;
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
        #5

         if ((num + prevNum) != O_WRITE_PORT)
             $display("Test Failed: Expected: %0d, Actual: %0d", num + prevNum, O_WRITE_PORT);
        prevNum = num;
        num = O_WRITE_PORT;

        I_READ_PORT_A_SEL = I_READ_PORT_A_SEL+ 1;
        I_READ_PORT_B_SEL = I_READ_PORT_B_SEL+ 1;
        I_REG_ENABLE <<= 1;

    end

    $stop;

end

endmodule
