//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/08/2021
// Module Name: cr16
// Description: The CompactRISC16 (CR16) processor with an integrated FSM and instruction decoder
// along with an instantiated datapath, ALU, and program counter.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// @param I_CLK              the clock signal
// @param I_ENABLE           the enable signal
// @param I_NRESET           the active-low reset signal
// @param I_INSTRUCTION      the instruction being processed by the FSM
// @param I_STATUS_REG       the status flags output by the ALU
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
module cr16 (    input wire I_CLK,
                 input wire I_ENABLE,
					  input wire I_NRESET,
					  input wire [15:0] I_INSTRUCTION,
					  input wire [4:0] I_STATUS_REG,
					  output wire O_PC_ENABLE,
					  output wire O_REGFILE_ENABLE,
					  output wire [15:0] O_WRITE_ENABLE,
					  output wire [3:0] O_REG_A_SELECT,
					  output wire [3:0] O_REG_B_SELECT,
					  output wire [7:0] O_IMMEDIATE, // because we can only store 8 bits into an immediate instruction...
					  output wire O_IMMEDIATE_SELECT,
					  output wire [3:0] O_ALU_OPCODE,
					  output wire [15:0] O_REG_DATA,
					  output wire O_REG_DATA_SELECT );

// Decode phase:
always @()

// TODO implement CR16 decoder and FSM, instantiate other modules
// This should not instantiate BRAM, but rather have port interfaces for it
// so that a memory mapping module (for virtual memory addressing or mapping certain addresses to
// a peripheral register/interface) can be used outside of this project.

endmodule
