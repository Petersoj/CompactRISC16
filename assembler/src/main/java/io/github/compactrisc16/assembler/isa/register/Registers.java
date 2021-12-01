package io.github.compactrisc16.assembler.isa.register;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * {@link Registers} instantiates all CR16 {@link Register}s as defined in the
 * <a href="https://github.com/Petersoj/CompactRISC16/blob/main/docs/Datasheets/CR16%20ISA/CR16%20ISA.pdf">CR16
 * ISA</a>.
 */
public class Registers {

    public static final Register RSP = new Register("rsp", 15);
    public static final Register R14 = new Register("r14", 14);
    public static final Register R13 = new Register("r13", 13);
    public static final Register R12 = new Register("r12", 12);
    public static final Register R11 = new Register("r11", 11);
    public static final Register R10 = new Register("r10", 10);
    public static final Register R9 = new Register("r9", 9);
    public static final Register R8 = new Register("r8", 8);
    public static final Register R7 = new Register("r7", 7);
    public static final Register R6 = new Register("r6", 6);
    public static final Register R5 = new Register("r5", 5);
    public static final Register R4 = new Register("r4", 4);
    public static final Register R3 = new Register("r3", 3);
    public static final Register R2 = new Register("r2", 2);
    public static final Register R1 = new Register("r1", 1);
    public static final Register R0 = new Register("r0", 0);

    public static final List<Register> REGISTERS = List.of(
            RSP, R14, R13, R12, R11, R10, R9, R8, R7, R6, R5, R4, R3, R2, R1, R0);
    public static final Map<String, Register> REGISTERS_OF_NAMES = REGISTERS.stream()
            .collect(Collectors.toMap(Register::getName, Function.identity()));
}
