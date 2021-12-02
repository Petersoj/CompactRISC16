package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;

import java.util.List;

/**
 * {@link RetInstruction} is an {@link OpcodeExtInstruction} representing a <code>RET</code> instruction.
 */
public class RetInstruction extends OpcodeExtInstruction {

    /**
     * Instantiates a new {@link RetInstruction}.
     */
    public RetInstruction() {
        super("RET", 0b1111, 0b0100);
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 1) {
            throw new InstructionParseException(formatInstructParseExceptionMessage(lineWords, ""));
        }
    }
}
