module mux2_1 (input wire [0:1]INPUT, s, output wire OUT);
	assign OUT = (~s & INPUT[0]) | (s & INPUT[1]);
end module

module mux4_1 (input wire [0:3]INPUT, [1:0]s, output wire OUT);
	wire[1:0] layer1;
	mux2_1 m1 (INPUT[0:1], s[0], layer1[0]);
	mux2_1 m1 (INPUT[2:3], s[0], layer1[1]);
	mux2_1 m1 (layer1[0:1], s[1], OUT);	
end module

module mux16_1 (input wire [0:15]INPUT, [0:3]s, output wire OUT);
	wire[3:0] layer2;
	mux4_1 m1 (INPUT[0:3], s[1:0], layer2[0]);
	mux4_1 m1 (INPUT[4:7], s[1:0], layer2[1]);
	mux4_1 m1 (INPUT[8:11], s[1:0], layer2[2]);
	mux4_1 m1 (INPUT[12:15], s[1:0], layer2[3]);
	
	mux4_1 m1 (layer2[0:3], s[3:2], OUT);
end module
