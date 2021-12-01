package io.github.compactrisc16.assembler.isa.instruction.type.pseudo;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;

import java.util.List;

import static io.github.compactrisc16.assembler.isa.instruction.Instructions.OR;

/**
 * {@link NOPInstruction} is an {@link AbstractInstruction} for the <code>NOP</code> pseudo instruction.
 */
public class NOPInstruction extends AbstractInstruction {

    private static final List<String> NOP_ASSEMBLY_LINE_WORDS = List.of("OR", "r0", "r0");

    public NOPInstruction() {
        super("NOP", OR.getOpcode());
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 1) {
            throw new InstructionParseException(String.format("Invalid arguments. Expected: %s", mnemonic));
        }

        OR.parse(NOP_ASSEMBLY_LINE_WORDS);
    }

    @Override
    public int assemble() {
        return OR.assemble();
    }
}
