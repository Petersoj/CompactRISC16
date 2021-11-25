package io.github.compactrisc16.assembler.isa.instruction.type.pseudo;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.Instructions;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;

/**
 * {@link NOPInstruction} is an {@link AbstractInstruction} for the <code>NOP</code> pseudo instruction.
 */
public class NOPInstruction extends AbstractInstruction {

    private static final String[] NOP_ASSEMBLY = new String[]{"NOP", "r0", "r0"};

    public NOPInstruction() {
        super("NOP", Instructions.OR.getOpcode());
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 1) {
            throw new InstructionParseException(String.format("Invalid arguments. Expected: %s", mnemonic));
        }

        Instructions.OR.parse(NOP_ASSEMBLY);
    }

    @Override
    public int assemble() {
        return Instructions.OR.assemble();
    }
}
