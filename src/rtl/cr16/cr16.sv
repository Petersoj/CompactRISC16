//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/08/2021
// Module Name: cr16
// Description: The CompactRISC16 (CR16) processor with an integrated FSM and instruction decoder
// along with an instantiated datapath (containing the ALU and regfile), and program counter.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_CLK              the clock signal
// @param I_ENABLE           the enable signal
// @param I_NRESET           the active-low reset signal
// @param I_INSTRUCTION      the instruction being processed by the FSM
// @param
// @param O_PC_ENABLE        enable signal for the program counter
// @param O_REGFILE_ENABLE   enable signal for the register file
// @param O_WRITE_ENABLE     one-hot encoded vector indicating which register the datapath may write to.
// @param O_REG_A_SELECT     decimal value of the register for ALU input A
// @param O_REG_B_SELECT     decimal value of the register for ALU input B
// @param O_IMMEDIATE        the immediate value as the 'A' ALU input
// @param O_IMMEDIATE_SELECT 1 to use the 'I_IMMEDIATE' value as the 'A' ALU input, 0 to use the regfile 'I_REG_A_SELECT'
// @param O_ALU_OPCODE           the ALU opcode
// @param O_REG_DATA         the input data that is muxed with the ALU output as direct input to the regfile
// @param O_REG_DATA_SELECT  1 to use the 'I_REG_DATA' as an input to the regfile, 0 to use the ALU output to the regfile
module cr16 (input wire I_CLK,
             input wire I_ENABLE,
             input wire I_NRESET,
             input wire[15 : 0] I_DATA_A,
             output reg [15 : 0] O_DATA_A,
             output reg[9 : 0] O_ADDRESS_A,
             output reg O_WRITE_ENABLE_A);


reg [15:0] instruction; // The 16-bit encoded instruction
wire [15:0] address; // connects PC to memory interface.

wire pc_enable; // allows the program counter to advance on 1
wire pc_address_select; // 1 for pc to use address on address register, 0 to continue counting from previous value
wire pc_address_select_increment; // if selecting address from register, 1 to increment it by 1, 0 not to increment
wire pc_address_select_displace; // If selecting address from register, assert to use input address as displacement value

wire [4:0] status_flags; // Flag bits from the ALU
wire [15:0] reg_write_enable; // one-hot endoded write enable for registers r0-r15
reg [15:0] write_register; // register to be written to. Only applied to reg_write_enable on writeback.
wire [3:0] reg_a_select; // selection for rsrc
wire [3:0] reg_b_select; // selection for rdest
wire [7:0] immediate; // because we can only store 8 bits into an immediate instruction...
wire immediate_select; // selector to apply immediate on port A of ALU
wire [3:0] alu_opcode; // opcode to be applied to ALU
wire [15:0] a;
wire [15:0] b;
wire [15:0] result_bus;

wire [15:0] mem_data; // data on DOUT from memory, used for load instructions
wire mem_data_select; // 1 if write port should receive from Dout, 0 if ALU output

// Program counter
pc i_pc
   (.I_ENABLE(pc_enable),
    .I_NRESET(I_NRESET),
    .I_ADDRESS(address),
    .I_ADDRESS_SELECT(pc_address_select),
    .I_ADDRESS_SELECT_INCREMENT(pc_address_select_increment),
    .I_ADDRESS_SELECT_DISPLACE(pc_address_select_displace),
    .O_ADDRESS(O_ADDRESS_A));

// Datapath
datapath i_datapath
         (.I_CLK(I_CLK),
          .I_ENABLE(I_ENABLE),
          .I_NRESET(I_NRESET),
          .I_REG_WRITE_ENABLE(reg_write_enable),
          .I_REG_A_SELECT(reg_a_select),
          .I_REG_B_SELECT(reg_b_select),
          .I_IMMEDIATE_SELECT(immediate_select),
          .I_IMMEDIATE(immediate),
          .I_OPCODE(alu_opcode),
          .I_REG_DATA(mem_data),
          .I_REG_DATA_SELECT(mem_data_select),
          .O_A(a),
          .O_B(b),
          .O_RESULT_BUS(result_bus),
          .O_STATUS_FLAGS(status_flags));

// Decode reg_write_enable
decoder4_16 i_decoder
            (.I_DATA(reg_b_select),
             .O_DATA(write_register));

parameter [2:0] S0 = 0, //fetch
          S1 = 1, //decode
          S2 = 2, //execute and writeback for R-type
          S3 = 3, //writeback into memory for store
          S4 = 4, //apply load address to memory
          S5 = 5; //store mem_data to regfile via mux on the ALU.

// Decode phase:
reg [2:0] ns;
always @(posedge I_CLK) begin
    if (I_NRESET == 0) // NRESET triggers the FSM to start.
        ns <= S0;
    else begin
        case (ns)
            S0: begin // Fetch instruction
                pc_enable = 0;
                reg_write_enable = 0;
                reg_a_select = 4'bxxxx;
                reg_b_select = 4'bxxxx;
                immediate = 8'bxxxxxxxx;
                immediate_select = 1'bx;
                alu_opcode = 4'bxxxx;
                mem_data_select = 1'bx;
                O_DATA_A = 16'hxxxx;
                O_WRITE_ENABLE_A = 0;
                instruction = I_DATA_A;

                ns <= S1;
            end
            S1: begin // Decode instruction
                pc_enable = 0;
                reg_write_enable = 0;
                reg_a_select = 4'bxxxx;
                reg_b_select = 4'bxxxx;
                immediate = 8'bxxxxxxxx;
                immediate_select = 1'bx;
                alu_opcode = 4'bxxxx;
                mem_data_select = 1'bx;
                O_DATA_A = 16'hxxxx;
                O_WRITE_ENABLE_A = 0;

                if (instruction[15:12] == 4'b0000 || instruction[13:12] != 2'b00 || instruction[15:14] == 2'b10)
                    ns <= S2;
                else
                    ns <= S0;
            end
            S2: begin // Perform arithmetic/logic/mov
                if (instruction[13:12] != 2'b00)begin // Immediate arithmetic/logic
                    reg_a_select = 4'bxxxx;
                    immediate = instruction[7:0];
                    immediate_select = 1'b1;
                    alu_opcode = instruction[15:12];
                end
                else begin
                    if (instruction [15:14] == 2'b10) begin // shift instructions
                        reg_a_select = 4'bxxxx;
                        immediate = instruction[7:0];
                        immediate_select = 1'b1;
                        alu_opcode = instruction[15:12];
                    end
                    else begin // register to register arithmetic
                        reg_a_select = instruction[3:0];
                        immediate = 8'bxxxxxxxx;
                        immediate_select = 1'b0;
                        alu_opcode = instruction[7:4];
                    end
                end

                reg_b_select = instruction[11:8];
                reg_write_enable = write_register;
                mem_data_select = 1'b0;
                O_DATA_A = 16'hxxxx;
                O_WRITE_ENABLE_A = 0;
                pc_enable = 1;

                ns <= S0;
            end
            //S3: begin
            //  pc_enable = 1;

            //end
            //S4: begin
            //  pc_enable = 0;

            //end
            //S5: begin
            //  pc_enable = 1;
            //end
        endcase
    end
end

// TODO implement CR16 decoder and FSM, instantiate other modules
// This should not instantiate BRAM, but rather have port interfaces for it
// so that a memory mapping module (for virtual memory addressing or mapping certain addresses to
// a peripheral register/interface) can be used outside of this project.

endmodule
