module mux2_1 (input wire [1:0]INPUT, input wire s, output wire OUT);
	assign OUT = (~s & INPUT[0]) | (s & INPUT[1]);
endmodule

module mux4_1 (input wire [3:0]INPUT, input wire[1:0]s, output wire OUT);
	wire[1:0] layer1;
	mux2_1 m1 (INPUT[1:0], s[0], layer1[0]);
	mux2_1 m2 (INPUT[3:2], s[0], layer1[1]);
	mux2_1 m3 (layer1[1:0], s[1], OUT);
endmodule

module mux16_1 (input wire [15:0]INPUT, input wire[3:0]s, output wire OUT);
	wire[3:0] layer2;
	mux4_1 m1 (INPUT[3:0], s[1:0], layer2[0]);
	mux4_1 m2 (INPUT[7:4], s[1:0], layer2[1]);
	mux4_1 m3 (INPUT[11:8], s[1:0], layer2[2]);
	mux4_1 m4 (INPUT[15:12], s[1:0], layer2[3]);
	
	mux4_1 m5 (layer2[3:0], s[3:2], OUT);
endmodule
