package io.github.compactrisc16.assembler.isa.instruction.type.cond;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;

import java.util.List;

/**
 * {@link BInstruction} is an {@link AbstractInstruction} representing a <code>B[condition]</code> instruction with
 * <code>Displacement Imm</code> as an argument.
 */
public class BInstruction extends AbstractInstruction {

    public static final int INSTRUCTION_INDEX_DISPLACEMENT_IMM = 1;
    public static final int MIN_DISPLACEMENT_IMM = Byte.MIN_VALUE;
    public static final int MAX_DISPLACEMENT_IMM = Byte.MAX_VALUE;

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
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 2) {
            throw new InstructionParseException(formatInstructParseExceptionMessage(lineWords, "<Displacement Imm>"));
        }

        displacementImm = parseImmediate(lineWords.get(INSTRUCTION_INDEX_DISPLACEMENT_IMM),
                MIN_DISPLACEMENT_IMM, MAX_DISPLACEMENT_IMM);
    }

    @Override
    public int assemble() {
        return super.assemble() | condition << 8 | (displacementImm & 0xFF);
    }

    public int getDisplacementImm() {
        return displacementImm;
    }
}
