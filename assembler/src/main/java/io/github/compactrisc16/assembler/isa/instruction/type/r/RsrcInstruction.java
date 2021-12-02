package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

import java.util.List;

/**
 * {@link RsrcInstruction} is an {@link OpcodeExtInstruction} with <code>Rdest</code> as an argument.
 */
public class RsrcInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;

    private Register rsrc;

    /**
     * Instantiates a new {@link RsrcInstruction}.
     *
     * @param mnemonic        the mnemonic
     * @param opcode          the opcode
     * @param opcodeExtension the opcode extension
     */
    public RsrcInstruction(String mnemonic, int opcode, int opcodeExtension) {
        super(mnemonic, opcode, opcodeExtension);
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 2) {
            throw new InstructionParseException(formatInstructParseExceptionMessage(lineWords, "<Rsrc>"));
        }

        rsrc = parseRegister(lineWords.get(INSTRUCTION_INDEX_RDEST));
    }

    @Override
    public int assemble() {
        return super.assemble() | rsrc.getIndex();
    }

    public Register getRsrc() {
        return rsrc;
    }
}
