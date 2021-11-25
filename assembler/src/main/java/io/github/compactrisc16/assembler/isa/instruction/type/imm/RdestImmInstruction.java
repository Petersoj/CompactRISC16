package io.github.compactrisc16.assembler.isa.instruction.type.imm;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.register.Register;

/**
 * {@link RdestImmInstruction} is an {@link AbstractInstruction} with <code>Rdest</code> and <code>Imm</code> as
 * arguments.
 */
public class RdestImmInstruction extends AbstractInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;
    public static final int INSTRUCTION_INDEX_IMM = 2;

    private Register rdest;
    private int imm;

    /**
     * Instantiates a new {@link RdestImmInstruction}.
     *
     * @param mnemonic the mnemonic
     * @param opcode   the opcode
     */
    public RdestImmInstruction(String mnemonic, int opcode) {
        super(mnemonic, opcode);
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 3) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Rdest>, <Imm>", mnemonic));
        }

        rdest = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RDEST]);
        // Note that the maximum allowable value is '0xFF' because the assembly can contain unsigned integers, and it's
        // up to the programmer to determine if the number should be interpreted as unsigned or signed numbers at
        // CR16 runtime.
        imm = parseImmediate(assemblyInstruction[INSTRUCTION_INDEX_IMM], Byte.MIN_VALUE, 0xFF);
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8 | (imm & 0xFF);
    }
}
