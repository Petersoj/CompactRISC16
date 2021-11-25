package io.github.compactrisc16.assembler.isa.instruction.type.cond;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;

/**
 * {@link BInstruction} is an {@link AbstractInstruction} representing a <code>B[condition]</code> instruction with
 * <code>Displacement Imm</code> as an argument.
 */
public class BInstruction extends AbstractInstruction {

    public static final int INSTRUCTION_INDEX_DISPLACEMENT_IMM = 1;

    private final int condition;

    private int displacementImm;

    /**
     * Instantiates a new {@link BInstruction}.
     *
     * @param mnemonic  the mnemonic
     * @param condition the condition
     */
    public BInstruction(String mnemonic, int condition) {
        super(mnemonic, 0b1100);
        this.condition = condition;
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 2) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Displacement Imm>", mnemonic));
        }

        displacementImm = parseImmediate(assemblyInstruction[INSTRUCTION_INDEX_DISPLACEMENT_IMM],
                Byte.MIN_VALUE, Byte.MAX_VALUE);
    }

    @Override
    public int assemble() {
        return super.assemble() | condition << 8 | (displacementImm & 0xFF);
    }
}
