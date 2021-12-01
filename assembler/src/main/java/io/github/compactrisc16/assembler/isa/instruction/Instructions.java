package io.github.compactrisc16.assembler.isa.instruction;

import io.github.compactrisc16.assembler.isa.instruction.type.cond.BInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.cond.JInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.imm.CallDInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.imm.RdestImmInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.imm.RdestImmLoInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.pseudo.NOPInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.CallInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.RdestInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.RdestRsrcInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.RetInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.RsrcInstruction;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * {@link Instructions} instantiates all {@link AbstractInstruction}s as defined in the <a
 * href="https://github.com/Petersoj/CompactRISC16/blob/main/docs/Datasheets/CR16%20ISA/CR16%20ISA.pdf">CR16 ISA</a>.
 * Note that none of the instantiated {@link AbstractInstruction}s here are thread-safe. Also note that these are shared
 * instances to reduce memory consumption when assembling, which is fine since assembling is done serially.
 */
public final class Instructions {

    public static final RdestRsrcInstruction ADD = new RdestRsrcInstruction("ADD", 0b0000, 0b0000);
    public static final RdestImmInstruction ADDI = new RdestImmInstruction("ADDI", 0b0001);
    public static final RdestRsrcInstruction ADDC = new RdestRsrcInstruction("ADDC", 0b0000, 0b0001);
    public static final RdestImmInstruction ADDCI = new RdestImmInstruction("ADDCI", 0b0010);
    public static final RdestRsrcInstruction MUL = new RdestRsrcInstruction("MUL", 0b0000, 0b0010);
    public static final RdestImmInstruction MULI = new RdestImmInstruction("MULI", 0b0011);
    public static final RdestRsrcInstruction SUB = new RdestRsrcInstruction("SUB", 0b0000, 0b0011);
    public static final RdestImmInstruction SUBI = new RdestImmInstruction("SUBI", 0b0100);
    public static final RdestRsrcInstruction CMP = new RdestRsrcInstruction("CMP", 0b0000, 0b0100);
    public static final RdestImmInstruction CMPI = new RdestImmInstruction("CMPI", 0b0101);
    public static final RdestRsrcInstruction NOT = new RdestRsrcInstruction("NOT", 0b0000, 0b0101);
    public static final RdestImmInstruction NOTI = new RdestImmInstruction("NOTI", 0b0110);
    public static final RdestRsrcInstruction AND = new RdestRsrcInstruction("AND", 0b0000, 0b0110);
    public static final RdestImmInstruction ANDI = new RdestImmInstruction("ANDI", 0b0111);
    public static final RdestRsrcInstruction OR = new RdestRsrcInstruction("OR", 0b0000, 0b0111);
    public static final RdestImmInstruction ORI = new RdestImmInstruction("ORI", 0b1000);
    public static final RdestRsrcInstruction XOR = new RdestRsrcInstruction("XOR", 0b0000, 0b1000);
    public static final RdestImmInstruction XORI = new RdestImmInstruction("XORI", 0b1001);
    public static final RdestRsrcInstruction LSH = new RdestRsrcInstruction("LSH", 0b0000, 0b1001);
    public static final RdestImmLoInstruction LSHI = new RdestImmLoInstruction("LSHI", 0b0000, 0b1010);
    public static final RdestRsrcInstruction RSH = new RdestRsrcInstruction("RSH", 0b0000, 0b1011);
    public static final RdestImmLoInstruction RSHI = new RdestImmLoInstruction("RSHI", 0b0000, 0b1100);
    public static final RdestRsrcInstruction ALSH = new RdestRsrcInstruction("ALSH", 0b0000, 0b1101);
    public static final RdestImmLoInstruction ALSHI = new RdestImmLoInstruction("ALSHI", 0b0000, 0b1110);
    public static final RdestRsrcInstruction ARSH = new RdestRsrcInstruction("ARSH", 0b0000, 0b1111);
    public static final RdestImmLoInstruction ARSHI = new RdestImmLoInstruction("ARSHI", 0b1111, 0b0000);
    public static final RdestRsrcInstruction MOV = new RdestRsrcInstruction("MOV", 0b1111, 0b0001);
    public static final RdestImmInstruction MOVIL = new RdestImmInstruction("MOVIL", 0b1010);
    public static final RdestImmInstruction MOVIU = new RdestImmInstruction("MOVIU", 0b1011);
    public static final JInstruction JEQ = new JInstruction("JEQ", 0b0000);
    public static final JInstruction JNE = new JInstruction("JNE", 0b0001);
    public static final JInstruction JCS = new JInstruction("JCS", 0b0010);
    public static final JInstruction JCC = new JInstruction("JCC", 0b0011);
    public static final JInstruction JFS = new JInstruction("JFS", 0b0100);
    public static final JInstruction JFC = new JInstruction("JFC", 0b0101);
    public static final JInstruction JLT = new JInstruction("JLT", 0b0110);
    public static final JInstruction JLE = new JInstruction("JLE", 0b0111);
    public static final JInstruction JLO = new JInstruction("JLO", 0b1000);
    public static final JInstruction JLS = new JInstruction("JLS", 0b1001);
    public static final JInstruction JGT = new JInstruction("JGT", 0b1010);
    public static final JInstruction JGE = new JInstruction("JGE", 0b1011);
    public static final JInstruction JHI = new JInstruction("JHI", 0b1100);
    public static final JInstruction JHS = new JInstruction("JHS", 0b1101);
    public static final JInstruction JUC = new JInstruction("JUC", 0b1110);
    public static final BInstruction BEQ = new BInstruction("BEQ", 0b0000);
    public static final BInstruction BNE = new BInstruction("BNE", 0b0001);
    public static final BInstruction BCS = new BInstruction("BCS", 0b0010);
    public static final BInstruction BCC = new BInstruction("BCC", 0b0011);
    public static final BInstruction BFS = new BInstruction("BFS", 0b0100);
    public static final BInstruction BFC = new BInstruction("BFC", 0b0101);
    public static final BInstruction BLT = new BInstruction("BLT", 0b0110);
    public static final BInstruction BLE = new BInstruction("BLE", 0b0111);
    public static final BInstruction BLO = new BInstruction("BLO", 0b1000);
    public static final BInstruction BLS = new BInstruction("BLS", 0b1001);
    public static final BInstruction BGT = new BInstruction("BGT", 0b1010);
    public static final BInstruction BGE = new BInstruction("BGE", 0b1011);
    public static final BInstruction BHI = new BInstruction("BHI", 0b1100);
    public static final BInstruction BHS = new BInstruction("BHS", 0b1101);
    public static final BInstruction BUC = new BInstruction("BUC", 0b1110);
    public static final CallInstruction CALL = new CallInstruction();
    public static final CallDInstruction CALLD = new CallDInstruction();
    public static final RetInstruction RET = new RetInstruction();
    public static final RdestInstruction LPC = new RdestInstruction("LPC", 0b1111, 0b0101);
    public static final RdestInstruction LSF = new RdestInstruction("LSF", 0b1111, 0b0110);
    public static final RsrcInstruction SSF = new RsrcInstruction("SSF", 0b1111, 0b0111);
    public static final RsrcInstruction PUSH = new RsrcInstruction("PUSH", 0b1111, 0b1000);
    public static final RdestInstruction POP = new RdestInstruction("POP", 0b1111, 0b1001);
    public static final RdestRsrcInstruction LOAD = new RdestRsrcInstruction("LOAD", 0b1111, 0b1010);
    public static final RdestRsrcInstruction STORE = new RdestRsrcInstruction("STORE", 0b1111, 0b1011);
    public static final RdestRsrcInstruction LOADX = new RdestRsrcInstruction("LOADX", 0b1111, 0b1100);
    public static final RdestRsrcInstruction STOREX = new RdestRsrcInstruction("STOREX", 0b1111, 0b1101);
    public static final NOPInstruction NOP = new NOPInstruction();

    public static final List<AbstractInstruction> INSTRUCTIONS =
            List.of(ADD, ADDI, ADDC, ADDCI, MUL, MULI, SUB, SUBI, CMP, CMPI, NOT, NOTI, AND, ANDI, OR, ORI, XOR, XORI,
                    LSH, LSHI, RSH, RSHI, ALSH, ALSHI, ARSH, ARSHI, MOV, MOVIL, MOVIU, JEQ, JNE, JCS, JCC, JFS, JFC,
                    JLT, JLE, JLO, JLS, JGT, JGE, JHI, JHS, JUC, BEQ, BNE, BCS, BCC, BFS, BFC, BLT, BLE, BLO, BLS, BGT,
                    BGE, BHI, BHS, BUC, CALL, CALLD, RET, LPC, LSF, SSF, PUSH, POP, LOAD, STORE, LOADX, STOREX, NOP);
    public static final List<AbstractInstruction> J_INSTRUCTIONS =
            List.of(JEQ, JNE, JCS, JCC, JFS, JFC, JLT, JLE, JLO, JLS, JGT, JGE, JHI, JHS, JUC);
    public static final List<AbstractInstruction> B_INSTRUCTIONS =
            List.of(BEQ, BNE, BCS, BCC, BFS, BFC, BLT, BLE, BLO, BLS, BGT, BGE, BHI, BHS, BUC);
    public static final Map<String, AbstractInstruction> INSTRUCTIONS_OF_MNEMONICS = INSTRUCTIONS.stream()
            .collect(Collectors.toMap(AbstractInstruction::getMnemonic, Function.identity()));
}
