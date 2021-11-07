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
// @param O_PC                   the program counter (instruction address)
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
        output wire [4:0] O_STATUS_FLAGS,
        output wire [15:0] O_PC);

// Define states of FSM
localparam P_STATE_BIT_WIDTH = 4;
localparam [P_STATE_BIT_WIDTH - 1 : 0]
           S_FETCH               = 0,
           S_DECODE              = 1,
           S_EXECUTE_ALU         = 2,
           S_EXECUTE_MOV         = 3,
           S_EXECUTE_SSF         = 4,
           S_EXECUTE_LOAD        = 5,
           S_EXECUTE_LOAD_FINISH = 6,
           S_EXECUTE_STORE       = 7;

// Parameterized Opcodes with extensions
localparam [7:0]
           ADD    = 8'b0000_0000,
           ADDC   = 8'b0000_0001,
           MUL    = 8'b0000_0010,
           SUB    = 8'b0000_0011,
           CMP    = 8'b0000_0100,
           NOT    = 8'b0000_0101,
           AND    = 8'b0000_0110,
           OR     = 8'b0000_0111,
           XOR    = 8'b0000_1000,
           LSH    = 8'b0000_1001,
           LSHI   = 8'b0000_1010,
           RSH    = 8'b0000_1011,
           RSHI   = 8'b0000_1100,
           ALSH   = 8'b0000_1101,
           ALSHI  = 8'b0000_1110,
           ARSH   = 8'b0000_1111,
           ARSHI  = 8'b1111_0000,
           MOV    = 8'b1111_0001,
           JCOND  = 8'b1111_0010,
           CALL   = 8'b1111_0011,
           RET    = 8'b1111_0100,
           LPC    = 8'b1111_0101,
           LSF    = 8'b1111_0110,
           SSF    = 8'b1111_0111,
           PUSH   = 8'b1111_1000,
           POP    = 8'b1111_1001,
           LOAD   = 8'b1111_1010,
           STORE  = 8'b1111_1011,
           LOADX  = 8'b1111_1100,
           STOREX = 8'b1111_1101;

// Parameterized Opcodes without extensions
localparam [3:0]
           ADDI  = 4'b0001,
           ADDCI = 4'b0010,
           MULI  = 4'b0011,
           SUBI  = 4'b0100,
           CMPI  = 4'b0101,
           NOTI  = 4'b0110,
           ANDI  = 4'b0111,
           ORI   = 4'b1000,
           XORI  = 4'b1001,
           MOVIL = 4'b1010,
           MOVIU = 4'b1011,
           BCOND = 4'b1100,
           CALLD = 4'b1101;

// Parameterized ALU Opcodes
localparam [3:0]
           ALU_ADD   = 4'd0,
           ALU_ADDC  = 4'd1,
           ALU_MUL   = 4'd2,
           ALU_SUB   = 4'd3,
           ALU_NOT   = 4'd4,
           ALU_AND   = 4'd5,
           ALU_OR    = 4'd6,
           ALU_XOR   = 4'd7,
           ALU_LSH   = 4'd8,
           ALU_RSH   = 4'd9,
           ALU_ALSH  = 4'd10,
           ALU_ARSH  = 4'd11,
           ALU_CLEAR = 4'd12; // Pseudo ALU opcode that represents default case in ALU
                              // which sets ALU outputs to zero

// State register
reg [P_STATE_BIT_WIDTH - 1 : 0] state = S_FETCH;

// Declare reg for temporary instruction storage and reg/wires for general instruction decoding
reg [15:0] instruction;
wire [3:0] instr_opcode         = instruction[15:12];
wire [3:0] instr_opcode_ext     = instruction[7:4];
wire [7:0] instr_opcode_and_ext = {instr_opcode, instr_opcode_ext};
wire [3:0] instr_rdest          = instruction[11:8];
wire [3:0] instr_rsrc           = instruction[3:0];
wire [3:0] instr_immhi          = instruction[7:4];
wire [3:0] instr_immlo          = instruction[3:0];
wire [7:0] instr_immhi_immlo    = {instr_immhi, instr_immlo};
// Asserted if 'instruction' has an opcode extension
wire instr_has_opcode_ext = instr_opcode == 4'b0000 || instr_opcode == 4'b1111;
// Asserted if 'instruction' has an immediate value
wire instr_has_imm = !instr_has_opcode_ext ||
                     instr_opcode_and_ext == LSHI || instr_opcode_and_ext == RSHI ||
                     instr_opcode_and_ext == ALSHI || instr_opcode_and_ext == ARSHI;

// Registers for decoding ALU instructions
reg [15:0] instr_alu_immediate;
reg instr_alu_immediate_select;
reg [3:0] instr_alu_opcode;

// Wires for decoding 'MOV' instruction
wire [15:0] instr_mov_imm_lower = {8'b0, instr_immhi_immlo};
wire [15:0] instr_mov_imm_upper = {instr_immhi_immlo, 8'b0};

// Wires for decoding 'LOAD', 'LOADX' 'STORE', and 'STOREX' instructions
wire [3:0] instr_load_raddr  = instr_rsrc;
wire [3:0] instr_store_raddr = instr_rdest;
wire [3:0] instr_store_rsrc  = instr_rsrc;
// Wire to multiplex between input memory data ports
wire [15:0] instr_load_i_mem_data_port = instr_opcode_and_ext == LOADX
                                         ? I_EXT_MEM_DATA : I_MEM_DATA;

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
assign O_PC = pc_o_address;

// Ports for 'i_datapath'
reg [15:0] reg_write_enable;
reg [3:0] reg_a_select, reg_b_select;
reg [15:0] immediate;
reg immediate_select;
reg [3:0] alu_opcode;
reg [15:0] regfile_data;
reg regfile_data_select;
wire [15:0] a, b; // 'a' is Rsrc, 'b' is Rdest
wire [4:0] alu_status_flags;

// Ports for 'i_decoder_regfile_instr_dest_reg'
wire [15:0] regfile_instr_dest_reg;

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
          .I_REG_A_SELECT(reg_a_select),
          .I_REG_B_SELECT(reg_b_select),
          .I_IMMEDIATE(immediate),
          .I_IMMEDIATE_SELECT(immediate_select),
          .I_OPCODE(alu_opcode),
          .I_REGFILE_DATA(regfile_data),
          .I_REGFILE_DATA_SELECT(regfile_data_select),
          .O_A(a),
          .O_B(b),
          .O_RESULT_BUS(O_RESULT_BUS),
          .O_STATUS_FLAGS(alu_status_flags));

// Instantiate a decoder to decode a given 'dest' register index into the write enable signal
// of the specified register in the regfile. Note that the 'instr_rdest' is used instead of
// 'instr_rsrc' since 'A' in the datapath is muxed with immediate values so 'B' will determine
// which register the immediates, results, etc. are written to.
decoder4_16 i_decoder_regfile_instr_dest_reg
            (.I_DATA(instr_rdest),
             .O_DATA(regfile_instr_dest_reg));

// Clocked CR16 FSM block
always @(posedge I_CLK or negedge I_NRESET) begin
    if (!I_NRESET) begin
        state        <= S_FETCH;
        instruction  <= 16'b0;
        status_flags <= 5'b0;

        pc_enable                   <= 1'b0;
        pc_i_address                <= 16'b0;
        pc_address_select           <= 1'b0;
        pc_address_select_increment <= 1'b0;
        pc_address_select_displace  <= 1'b0;

        reg_write_enable    <= 16'b0;
        reg_a_select        <= 4'b0;
        reg_b_select        <= 4'b0;
        immediate           <= 16'b0;
        immediate_select    <= 1'b0;
        alu_opcode          <= 4'b0;
        regfile_data        <= 16'b0;
        regfile_data_select <= 1'b0;
    end
    else if (I_ENABLE)
        case (state)
            S_FETCH: begin
                state        <= S_DECODE;
                instruction  <= I_MEM_DATA;
                status_flags <= status_flags;

                pc_enable                   <= 1'b1;
                pc_i_address                <= pc_i_address;
                pc_address_select           <= 1'b0;
                pc_address_select_increment <= 1'b0;
                pc_address_select_displace  <= 1'b0;

                reg_write_enable    <= 16'b0;
                reg_a_select        <= reg_a_select;
                reg_b_select        <= reg_b_select;
                immediate           <= immediate;
                immediate_select    <= 1'b0;
                alu_opcode          <= alu_opcode;
                regfile_data        <= regfile_data;
                regfile_data_select <= 1'b0;
            end
            S_DECODE: begin
                pc_enable <= 1'b0;

                if (instr_has_opcode_ext)
                    case (instr_opcode_and_ext)
                        ADD,
                        ADDC,
                        MUL,
                        SUB,
                        CMP,
                        NOT,
                        AND,
                        OR,
                        XOR,
                        LSH,
                        LSHI,
                        RSH,
                        RSHI,
                        ALSH,
                        ALSHI,
                        ARSH,
                        ARSHI: begin
                            state <= S_EXECUTE_ALU;

                            reg_a_select     <= instr_rsrc;
                            reg_b_select     <= instr_rdest;
                            immediate        <= instr_alu_immediate;
                            immediate_select <= instr_alu_immediate_select;
                            alu_opcode       <= instr_alu_opcode;
                        end
                        MOV: begin
                            state        <= S_EXECUTE_MOV;
                            reg_a_select <= instr_rsrc;
                        end
                        LPC: begin
                            // 'LPC' can be executed in this 'S_DECODE' state
                            state <= S_FETCH;

                            reg_write_enable    <= regfile_instr_dest_reg;
                            regfile_data        <= pc_o_address;
                            regfile_data_select <= 1'b1;
                        end
                        LSF: begin
                            // 'LSF' can be executed in this 'S_DECODE' state
                            state <= S_FETCH;

                            reg_write_enable    <= regfile_instr_dest_reg;
                            regfile_data        <= {11'b0, status_flags};
                            regfile_data_select <= 1'b1;
                        end
                        SSF: begin
                            state        <= S_EXECUTE_SSF;
                            reg_a_select <= instr_rsrc;
                        end
                        LOAD,
                        LOADX: begin
                            state        <= S_EXECUTE_LOAD;
                            reg_a_select <= instr_load_raddr;
                        end
                        STORE,
                        STOREX: begin
                            state <= S_EXECUTE_STORE;

                            reg_b_select <= instr_store_raddr;
                            reg_a_select <= instr_store_rsrc;
                        end
                        default:
                            state <= S_FETCH;
                    endcase
                else
                    case (instr_opcode)
                        ADDI,
                        ADDCI,
                        MULI,
                        SUBI,
                        CMPI,
                        NOTI,
                        ANDI,
                        ORI,
                        XORI: begin
                            state <= S_EXECUTE_ALU;

                            reg_a_select     <= instr_rsrc;
                            reg_b_select     <= instr_rdest;
                            immediate        <= instr_alu_immediate;
                            immediate_select <= instr_alu_immediate_select;
                            alu_opcode       <= instr_alu_opcode;
                        end
                        MOVIL,
                        MOVIU:
                            state <= S_EXECUTE_MOV;
                        default:
                            state <= S_FETCH;
                    endcase
            end
            S_EXECUTE_ALU: begin
                state <= S_FETCH;

                status_flags     <= alu_status_flags;
                reg_write_enable <= regfile_instr_dest_reg;
            end
            S_EXECUTE_MOV: begin
                state <= S_FETCH;

                reg_write_enable <= regfile_instr_dest_reg;
                if (instr_opcode_and_ext == MOV)
                    regfile_data <= a;
                else if (instr_opcode == MOVIL)
                    regfile_data <= instr_mov_imm_lower;
                else if (instr_opcode == MOVIU)
                    regfile_data <= instr_mov_imm_upper;
                regfile_data_select <= 1'b1;
            end
            S_EXECUTE_SSF: begin
                state        <= S_FETCH;
                status_flags <= a[4:0];
            end
            S_EXECUTE_LOAD: begin
                state <= S_EXECUTE_LOAD_FINISH;
            end
            S_EXECUTE_LOAD_FINISH: begin
                state <= S_FETCH;

                reg_write_enable    <= regfile_instr_dest_reg;
                regfile_data        <= instr_load_i_mem_data_port;
                regfile_data_select <= 1'b1;
            end
            S_EXECUTE_STORE: begin
                state <= S_FETCH;
            end
            default: begin
                state <= S_FETCH;
            end
        endcase
end

// ALU instruction to 'instr_alu_immediate' mapping block
always @(instr_opcode, instr_opcode_and_ext, instr_has_opcode_ext, instr_has_imm,
         instr_immhi_immlo, instr_immlo) begin
    if (instr_has_imm)
        if (instr_has_opcode_ext)
            case (instr_opcode_and_ext)
                LSHI,
                RSHI,
                ALSHI,
                ARSHI: begin
                    // Zero extend immediates for bit shifting
                    instr_alu_immediate        = {12'b0, instr_immlo};
                    instr_alu_immediate_select = 1'b1;
                end
                default: begin
                    instr_alu_immediate        = 16'b0;
                    instr_alu_immediate_select = 1'b0;
                end
            endcase
        else
            case (instr_opcode)
                ADDI,
                ADDCI,
                MULI,
                SUBI,
                CMPI: begin
                    // Sign extend immediates for arithmetic instructions by concatentating the sign bit
                    // of 'instr_immhi_immlo' as the upper bits of 'instr_alu_immediate'
                    instr_alu_immediate        = {{8{instr_immhi_immlo[7]}}, instr_immhi_immlo};
                    instr_alu_immediate_select = 1'b1;
                end
                NOTI,
                ANDI,
                ORI,
                XORI: begin
                    // Zero extend immediates for boolean logic
                    instr_alu_immediate        = {8'b0, instr_immhi_immlo};
                    instr_alu_immediate_select = 1'b1;
                end
                default: begin
                    instr_alu_immediate        = 16'b0;
                    instr_alu_immediate_select = 1'b0;
                end
            endcase
    else begin
        instr_alu_immediate        = 16'b0;
        instr_alu_immediate_select = 1'b0;
    end
end

// ALU instruction to 'alu_opcode' mapping block
always @(instr_opcode, instr_opcode_and_ext, instr_has_opcode_ext) begin
    if (instr_has_opcode_ext)
        case (instr_opcode_and_ext)
            ADD:
                instr_alu_opcode = ALU_ADD;
            ADDC:
                instr_alu_opcode = ALU_ADDC;
            MUL:
                instr_alu_opcode = ALU_MUL;
            SUB:
                instr_alu_opcode = ALU_SUB;
            CMP:
                instr_alu_opcode = ALU_SUB;
            NOT:
                instr_alu_opcode = ALU_NOT;
            AND:
                instr_alu_opcode = ALU_AND;
            OR:
                instr_alu_opcode = ALU_OR;
            XOR:
                instr_alu_opcode = ALU_XOR;
            LSH,
            LSHI:
                instr_alu_opcode = ALU_LSH;
            RSH,
            RSHI:
                instr_alu_opcode = ALU_RSH;
            ALSH,
            ALSHI:
                instr_alu_opcode = ALU_ALSH;
            ARSH,
            ARSHI:
                instr_alu_opcode = ALU_ARSH;
            default:
                instr_alu_opcode = ALU_CLEAR;
        endcase
    else
        case (instr_opcode)
            ADDI:
                instr_alu_opcode = ALU_ADD;
            ADDCI:
                instr_alu_opcode = ALU_ADDC;
            MULI:
                instr_alu_opcode = ALU_MUL;
            SUBI:
                instr_alu_opcode = ALU_SUB;
            CMPI:
                instr_alu_opcode = ALU_SUB;
            NOTI:
                instr_alu_opcode = ALU_NOT;
            ANDI:
                instr_alu_opcode = ALU_AND;
            ORI:
                instr_alu_opcode = ALU_OR;
            XORI:
                instr_alu_opcode = ALU_XOR;
            default:
                instr_alu_opcode = ALU_CLEAR;
        endcase
end

// Always block to combinationally assign memory interface outputs based on 'state'
// and 'instruction'. By combinationally assigning the memory outputs, this saves the FSM
// some clock cycles since it doesn't have to assign memory outputs once datapath selections
// are ready, as they are done combinationally upon datapath selections and state changes.
always @(I_NRESET, state, instr_has_opcode_ext, instr_opcode_and_ext, pc_o_address, a, b) begin
    if (!I_NRESET) begin
        O_MEM_DATA             = 16'b0;
        O_MEM_ADDRESS          = 16'b0;
        O_MEM_WRITE_ENABLE     = 1'b0;
        O_EXT_MEM_DATA         = 16'b0;
        O_EXT_MEM_ADDRESS      = 16'b0;
        O_EXT_MEM_WRITE_ENABLE = 1'b0;
    end
    else
        // 'state' in this combinational logic context should actually be interpreted
        // as 'next_state'
        case (state)
            S_EXECUTE_LOAD: begin
                if (instr_opcode_and_ext == LOAD) begin
                    O_MEM_DATA             = 16'b0;
                    O_MEM_ADDRESS          = a;
                    O_MEM_WRITE_ENABLE     = 1'b0;
                    O_EXT_MEM_DATA         = 16'b0;
                    O_EXT_MEM_ADDRESS      = 16'b0;
                    O_EXT_MEM_WRITE_ENABLE = 1'b0;
                end
                else begin
                    O_MEM_DATA             = 16'b0;
                    O_MEM_ADDRESS          = pc_o_address;
                    O_MEM_WRITE_ENABLE     = 1'b0;
                    O_EXT_MEM_DATA         = 16'b0;
                    O_EXT_MEM_ADDRESS      = a;
                    O_EXT_MEM_WRITE_ENABLE = 1'b0;
                end
            end
            S_EXECUTE_STORE: begin
                if (instr_opcode_and_ext == STORE) begin
                    O_MEM_DATA             = a;
                    O_MEM_ADDRESS          = b;
                    O_MEM_WRITE_ENABLE     = 1'b1;
                    O_EXT_MEM_DATA         = 16'b0;
                    O_EXT_MEM_ADDRESS      = 16'b0;
                    O_EXT_MEM_WRITE_ENABLE = 1'b0;
                end
                else begin
                    O_MEM_DATA             = 16'b0;
                    O_MEM_ADDRESS          = 16'b0;
                    O_MEM_WRITE_ENABLE     = 1'b0;
                    O_EXT_MEM_DATA         = a;
                    O_EXT_MEM_ADDRESS      = b;
                    O_EXT_MEM_WRITE_ENABLE = 1'b1;
                end
            end
            default: begin
                O_MEM_DATA             = 16'b0;
                O_MEM_ADDRESS          = pc_o_address;
                O_MEM_WRITE_ENABLE     = 1'b0;
                O_EXT_MEM_DATA         = 16'b0;
                O_EXT_MEM_ADDRESS      = 16'b0;
                O_EXT_MEM_WRITE_ENABLE = 1'b0;
            end
        endcase
end
endmodule
