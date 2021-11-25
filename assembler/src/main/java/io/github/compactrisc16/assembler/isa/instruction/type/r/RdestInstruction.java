package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

/**
 * {@link RdestInstruction} is an {@link OpcodeExtInstruction} with <code>Rdest</code> as an argument.
 */
public class RdestInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;

    private Register rdest;

    /**
     * Instantiates a new {@link RdestInstruction}.
     *
     * @param mnemonic        the mnemonic
     * @param opcode          the opcode
     * @param opcodeExtension the opcode extension
     */
    public RdestInstruction(String mnemonic, int opcode, int opcodeExtension) {
        super(mnemonic, opcode, opcodeExtension);
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 2) {
            throw new InstructionParseException(String.format("Invalid arguments. Expected: %s <Rdest>", mnemonic));
        }

        rdest = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RDEST]);
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8;
    }
}
