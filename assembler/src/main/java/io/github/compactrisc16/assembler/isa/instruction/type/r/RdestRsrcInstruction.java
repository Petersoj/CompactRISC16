package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

/**
 * {@link RdestRsrcInstruction} is an {@link OpcodeExtInstruction} with <code>Rsrc</code> and <code>Rdest</code> as
 * arguments.
 */
public class RdestRsrcInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;
    public static final int INSTRUCTION_INDEX_RSRC = 2;

    private Register rdest;
    private Register rsrc;

    /**
     * Instantiates a new {@link RdestRsrcInstruction}.
     *
     * @param mnemonic        the mnemonic
     * @param opcode          the opcode
     * @param opcodeExtension the opcode extension
     */
    public RdestRsrcInstruction(String mnemonic, int opcode, int opcodeExtension) {
        super(mnemonic, opcode, opcodeExtension);
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 3) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Rdest>, <Rsrc>", mnemonic));
        }

        rdest = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RDEST]);
        rsrc = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RSRC]);
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8 | rsrc.getIndex();
    }
}
