//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 09/28/2021
// Module Name: bram
// Description: A BRAM (Block Random Access Memory) module (from Quartus Prime Verilog Template).
//

module bram
       #(parameter P_DATA_WIDTH=16,
         parameter P_ADDRESS_WIDTH=10)
       (input I_CLK,
        input [P_DATA_WIDTH - 1 : 0] I_DATA_A, I_DATA_B,
        input [P_ADDRESS_WIDTH - 1 : 0] I_ADDRESS_A, I_ADDRESS_B,
        input I_WRITE_ENABLE_A, I_WRITE_ENABLE_B,
        output reg [P_DATA_WIDTH - 1 : 0] O_DATA_A, O_DATA_B);

reg [P_DATA_WIDTH - 1 : 0] ram [0 : 2 ** P_ADDRESS_WIDTH - 1]; // 2D packed register array for RAM

// TODO initialize ram using init ram file
   integer i;
   initial
   begin
       for(i=0;i<1024;i=i+1)
           ram[i] = i[15:0];
  	
	   $readmemh("ram_init.txt", ram);
	end


// Port A
always @(posedge I_CLK) begin
    if (I_WRITE_ENABLE_A) begin
        ram[I_ADDRESS_A] <= I_DATA_A;
        O_DATA_A <= O_DATA_A;
    end
    else
        O_DATA_A <= ram[I_ADDRESS_A];
end

// Port B
always @(posedge I_CLK) begin
    if (I_WRITE_ENABLE_B) begin
        ram[I_ADDRESS_B] <= I_DATA_B;
        O_DATA_B <= O_DATA_B;
    end
    else
        O_DATA_B <= ram[I_ADDRESS_B];
end
endmodule
