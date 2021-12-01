package io.github.compactrisc16.assembler.isa.instruction.type.imm;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;

import java.util.List;

/**
 * {@link CallDInstruction} is an {@link AbstractInstruction} representing a <code>CALLD</code> instruction with
 * <code>Displacement Imm</code> as an argument.
 */
public class CallDInstruction extends AbstractInstruction {

    public static final int INSTRUCTION_INDEX_DISPLACEMENT_IMM = 1;

    private int displacementImm;

    /**
     * Instantiates a new {@link CallDInstruction}.
     */
    public CallDInstruction() {
        super("CALLD", 0b1101);
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 2) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Displacement Imm>", mnemonic));
        }

        displacementImm = parseImmediate(lineWords.get(INSTRUCTION_INDEX_DISPLACEMENT_IMM),
                (int) -Math.pow(2, 11), (int) Math.pow(2, 11) - 1);
    }

    @Override
    public int assemble() {
        return super.assemble() | (displacementImm & 0xFFF);
    }

    public int getDisplacementImm() {
        return displacementImm;
    }
}
