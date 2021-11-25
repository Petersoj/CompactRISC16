package io.github.compactrisc16.assembler.isa.instruction.type;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;

/**
 * {@link OpcodeExtInstruction} represent an {@link AbstractInstruction} that contains on opcode extension.
 */
public abstract class OpcodeExtInstruction extends AbstractInstruction {

    protected final int opcodeExtension;

    /**
     * Instantiates a new {@link OpcodeExtInstruction}.
     *
     * @param mnemonic        the mnemonic
     * @param opcode          the opcode
     * @param opcodeExtension the opcode extension
     */
    public OpcodeExtInstruction(String mnemonic, int opcode, int opcodeExtension) {
        super(mnemonic, opcode);
        this.opcodeExtension = opcodeExtension;
    }

    @Override
    public int assemble() {
        return super.assemble() | (opcodeExtension << 4);
    }

    public int getOpcodeExtension() {
        return opcodeExtension;
    }
}
