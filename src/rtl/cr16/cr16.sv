//
// University of Utah, Computer Design Laboratory ECE 3710, CompactRISC16
//
// Create Date: 10/08/2021
// Module Name: cr16
// Description: This is the CompactRISC16 (CR16) processor with an integrated FSM and instruction
// decoder along with an instantiated datapath (containing the ALU and regfile) and program counter.
// Authors: Jacob Peterson, Brady Hartog, Isabella Gilman, Nate Hansen
//

// Note that the ISA of this CR16 implementation allows instructions to interface with external
// memory addresses in order to control various external/peripheral I/O devices and interfaces.
// This external memory interface is separate from the main memory interface so that the full
// address space of main memory can be used.
//
// @param I_CLK                  the clock signal
// @param I_ENABLE               the enable signal
// @param I_NRESET               the active-low asynchronous reset signal
// @param I_MEM_DATA             input of the memory output data
// @param I_EXT_MEM_DATA         input of the external (peripheral) memory output data
// @param O_MEM_DATA             output to the memory data input
// @param O_MEM_ADDRESS          output to the memory data address input
// @param O_MEM_WRITE_ENABLE     output to the memory write enable input signal
// @param O_EXT_MEM_DATA         output to the external (peripheral) memory data input
// @param O_EXT_MEM_ADDRESS      output to the external (peripheral) memory data address input
// @param O_EXT_MEM_WRITE_ENABLE output to the external (peripheral) memory write enable input
//                               signal
// @param O_RESULT_BUS           the datapath result bus which is connected to the mux of the ALU
//                               output and the regfile data input
// @param O_STATUS_FLAGS         the ALU status flags which updates after the execute state
module cr16
       (input wire I_CLK,
        input wire I_ENABLE,
        input wire I_NRESET,
        input wire [15:0] I_MEM_DATA,
        input wire [15:0] I_EXT_MEM_DATA,
        output reg [15:0] O_MEM_DATA,
        output reg [15:0] O_MEM_ADDRESS,
        output reg O_MEM_WRITE_ENABLE,
        output reg [15:0] O_EXT_MEM_DATA,
        output reg [15:0] O_EXT_MEM_ADDRESS,
        output reg O_EXT_MEM_WRITE_ENABLE,
        output wire [15:0] O_RESULT_BUS,
        output wire [4:0] O_STATUS_FLAGS);

// Define states of FSM
localparam P_STATE_BIT_WIDTH = 3;
localparam [P_STATE_BIT_WIDTH - 1 : 0]
           S_FETCH = 0,
           S_DECODE = 1,
           S_EXECUTE_ALU = 2,
           S_EXECUTE_MEM_STORE = 3,
           S_EXECUTE_MEM_LOAD = 4;

// Parameterized Opcodes with extensions
localparam [7:0]
           ADD = 8'b0000_0000,
           ADDC = 8'b0000_0001,
           MUL = 8'b0000_0010,
           SUB = 8'b0000_0011,
           CMP = 8'b0000_0100,
           NOT = 8'b0000_0101,
           AND = 8'b0000_0110,
           OR = 8'b0000_0111,
           XOR = 8'b0000_1000,
           LSH = 8'b0000_1001,
           LSHI = 8'b0000_1010,
           RSH = 8'b0000_1011,
           RSHI = 8'b0000_1100,
           ALSH = 8'b0000_1101,
           ALSHI = 8'b0000_1110,
           ARSH = 8'b0000_1111,
           ARSHI = 8'b1111_0000;
           // TODO finish ISA and add other Opcodes with extensions

// Parameterized Opcodes without extensions
localparam [3:0]
           ADDI = 4'b0001,
           ADDCI = 4'b0010,
           MULI = 4'b0011,
           SUBI = 4'b0100,
           CMPI = 4'b0101,
           NOTI = 4'b0110,
           ANDI = 4'b0111,
           ORI = 4'b1000,
           XORI = 4'b1001;
           // TODO finish ISA and add other Opcodes without extensions

// Parameterized ALU Opcodes
localparam [3:0]
           ALU_ADD = 0,
           ALU_ADDC = 1,
           ALU_MUL = 2,
           ALU_SUB = 3,
           ALU_NOT = 4,
           ALU_AND = 5,
           ALU_OR = 6,
           ALU_XOR = 7,
           ALU_LSH = 8,
           ALU_RSH = 9,
           ALU_ALSH = 10,
           ALU_ARSH = 11,
           ALU_CLEAR = 12;

// State register
reg [P_STATE_BIT_WIDTH - 1 : 0] state = S_FETCH;

// Declare reg for temporary instruction storage and wires for instruction decoding
reg [15:0] instruction;
wire [3:0] instr_opcode = instruction[15:12];
wire [3:0] instr_rdest = instruction[11:8];
wire [3:0] instr_immhi_opcode_ext = instruction[7:4];
wire [3:0] instr_immlo_rsrc = instruction[3:0];
wire [7:0] instr_opcode_and_ext = {instr_opcode, instr_immhi_opcode_ext};
// Asserted if 'instr_opcode' represents an immediate instruction
wire instr_is_imm = instr_opcode != 4'b0000 && instr_opcode != 4'b1111 ||
                    instr_opcode_and_ext == LSHI || instr_opcode_and_ext == RSHI ||
                    instr_opcode_and_ext == ALSHI || instr_opcode_and_ext == ARSHI;
// Asserted if 'instr_opcode' contains the ImmHi and ImmLo values
wire instr_has_imm_hi_lo = instr_opcode != 4'b0000 && instr_opcode != 4'b1111;

// Used to persist the ALU status flags
reg [4:0] status_flags;
assign O_STATUS_FLAGS = status_flags;

// Ports for 'i_pc'
reg pc_enable;
reg [15:0] pc_i_address;
reg pc_address_select;
reg pc_address_select_increment;
reg pc_address_select_displace;
wire [15:0] pc_o_address;

// Ports for 'i_datapath'
reg [15:0] reg_write_enable;
reg [15:0] immediate;
reg [3:0] alu_opcode;
reg [15:0] regfile_data;
reg regfile_data_select;
wire [15:0] a, b; // 'a' is Rsrc, 'b' is Rdest
wire [4:0] alu_status_flags;

// Ports for 'i_decoder_regfile_dest_reg'
wire [15:0] regfile_dest_reg;

// Instantiate the Program Counter
pc #(.P_ADDRESS_WIDTH(16))
   i_pc
   (.I_ENABLE(pc_enable),
    .I_NRESET(I_NRESET),
    .I_ADDRESS(pc_i_address),
    .I_ADDRESS_SELECT(pc_address_select),
    .I_ADDRESS_SELECT_INCREMENT(pc_address_select_increment),
    .I_ADDRESS_SELECT_DISPLACE(pc_address_select_displace),
    .O_ADDRESS(pc_o_address));

// Instantiate the Datapath containing the regfile, ALU, and status flags
datapath i_datapath
         (.I_CLK(I_CLK),
          .I_ENABLE(I_ENABLE),
          .I_NRESET(I_NRESET),
          .I_REG_WRITE_ENABLE(reg_write_enable),
          .I_REG_A_SELECT(instr_immlo_rsrc),
          .I_REG_B_SELECT(instr_rdest),
          .I_IMMEDIATE(immediate),
          .I_IMMEDIATE_SELECT(instr_is_imm),
          .I_OPCODE(alu_opcode),
          .I_REGFILE_DATA(regfile_data),
          .I_REGFILE_DATA_SELECT(regfile_data_select),
          .O_A(a),
          .O_B(b),
          .O_RESULT_BUS(O_RESULT_BUS),
          .O_STATUS_FLAGS(alu_status_flags));

// Instantiate a decoder to decode a given 'dest' register index into the write enable signal
// of the specified register in the regfile. Note that the 'instr_rdest' is used instead of
// 'instr_immlo_rsrc' since 'A' in the datapath is muxed with immediate values so 'B' will determine
// which register the immediates, results, etc. are written to.
decoder4_16 i_decoder_regfile_dest_reg
            (.I_DATA(instr_rdest),
             .I_ENABLE(1'b1),
             .O_DATA(regfile_dest_reg));

// Clocked CR16 FSM block
always @(posedge I_CLK or negedge I_NRESET) begin
    if (!I_NRESET)
        state = S_FETCH;
    else if (I_ENABLE)
        case (state)
            S_FETCH: begin
                state = S_DECODE;

                instruction = I_MEM_DATA;
                status_flags = status_flags;

                pc_enable = 1'b0;
                pc_i_address = pc_i_address;
                pc_address_select = 1'b0;
                pc_address_select_increment = 1'b0;
                pc_address_select_displace = 1'b0;

                reg_write_enable = 16'b0;
                regfile_data = regfile_data;
                regfile_data_select = 1'b0;

                O_MEM_DATA = 16'b0;
                O_MEM_ADDRESS = pc_o_address;
                O_MEM_WRITE_ENABLE = 1'b0;
                O_EXT_MEM_DATA = 16'b0;
                O_EXT_MEM_ADDRESS = 16'b0;
                O_EXT_MEM_WRITE_ENABLE = 1'b0;
            end
            S_DECODE: begin
                if (alu_opcode != ALU_CLEAR)
                    state = S_EXECUTE_ALU;
                else
                    // TODO implement other states
                    state = S_FETCH;

                instruction = instruction;
                status_flags = status_flags;

                pc_enable = 1'b0;
                pc_i_address = pc_i_address;
                pc_address_select = 1'b0;
                pc_address_select_increment = 1'b0;
                pc_address_select_displace = 1'b0;

                reg_write_enable = 16'b0;
                regfile_data = 16'b0;
                regfile_data_select = 1'b0;

                O_MEM_DATA = 16'b0;
                O_MEM_ADDRESS = pc_o_address;
                O_MEM_WRITE_ENABLE = 1'b0;
                O_EXT_MEM_DATA = 16'b0;
                O_EXT_MEM_ADDRESS = 16'b0;
                O_EXT_MEM_WRITE_ENABLE = 1'b0;
            end
            S_EXECUTE_ALU: begin
                state = S_FETCH;

                instruction = instruction;
                status_flags = alu_status_flags;

                pc_enable = 1'b1;
                pc_i_address = pc_i_address;
                pc_address_select = 1'b0;
                pc_address_select_increment = 1'b0;
                pc_address_select_displace = 1'b0;

                reg_write_enable = regfile_dest_reg;
                regfile_data = 16'b0;
                regfile_data_select = 1'b0;

                O_MEM_DATA = 16'b0;
                O_MEM_ADDRESS = pc_o_address;
                O_MEM_WRITE_ENABLE = 1'b0;
                O_EXT_MEM_DATA = 16'b0;
                O_EXT_MEM_ADDRESS = 16'b0;
                O_EXT_MEM_WRITE_ENABLE = 1'b0;
            end

            // TODO implement other states

            default: begin
                state = S_FETCH;
            end
        endcase
end

// CR16 Instruction to ALU Opcode mapping block
always @(instr_has_imm_hi_lo, instr_opcode, instr_opcode_and_ext) begin
    if (instr_has_imm_hi_lo)
        case (instr_opcode)
            ADDI:
                alu_opcode = ALU_ADD;
            ADDCI:
                alu_opcode = ALU_ADDC;
            MULI:
                alu_opcode = ALU_MUL;
            SUBI:
                alu_opcode = ALU_SUB;
            CMPI:
                alu_opcode = ALU_SUB;
            NOTI:
                alu_opcode = ALU_NOT;
            ANDI:
                alu_opcode = ALU_AND;
            ORI:
                alu_opcode = ALU_OR;
            XORI:
                alu_opcode = ALU_XOR;
            default:
                alu_opcode = ALU_CLEAR;
        endcase
    else
        case (instr_opcode_and_ext)
            ADD:
                alu_opcode = ALU_ADD;
            ADDC:
                alu_opcode = ALU_ADDC;
            MUL:
                alu_opcode = ALU_MUL;
            SUB:
                alu_opcode = ALU_SUB;
            CMP:
                alu_opcode = ALU_SUB;
            NOT:
                alu_opcode = ALU_NOT;
            AND:
                alu_opcode = ALU_AND;
            OR:
                alu_opcode = ALU_OR;
            XOR:
                alu_opcode = ALU_XOR;
            LSH,
            LSHI:
                alu_opcode = ALU_LSH;
            RSH,
            RSHI:
                alu_opcode = ALU_RSH;
            ALSH,
            ALSHI:
                alu_opcode = ALU_ALSH;
            ARSH,
            ARSHI:
                alu_opcode = ALU_ARSH;
            default:
                alu_opcode = ALU_CLEAR;
        endcase
end

// CR16 Instruction to ALU 'immediate' mapping block
always @(instr_is_imm, instr_has_imm_hi_lo, instr_opcode, instr_opcode_and_ext,
         instr_immhi_opcode_ext, instr_immlo_rsrc) begin
    if (instr_is_imm)
        if (instr_has_imm_hi_lo)
            case (instr_opcode)
                ADDI,
                ADDCI,
                MULI,
                SUBI,
                CMPI:
                    // Sign extend immediates for arithmetic instructions by concatentating the sign bit
                    // of 'instr_immhi_opcode_ext' as the upper bits of 'immediate'
                    immediate = {{8{instr_immhi_opcode_ext[3]}}, instr_immhi_opcode_ext, instr_immlo_rsrc};
                NOTI,
                ANDI,
                ORI,
                XORI:
                    // Zero extend immediates for boolean logic
                    immediate = {8'b0, instr_immhi_opcode_ext, instr_immlo_rsrc};
                default:
                    immediate = 16'b0;
            endcase
        else
            case (instr_opcode_and_ext)
                LSHI,
                RSHI,
                ALSHI,
                ARSHI:
                    // Zero extend immediates for bit shifting
                    immediate = {12'b0, instr_immlo_rsrc};
                default:
                    immediate = 16'b0;
            endcase
    else
        immediate = 16'b0;
end
endmodule
