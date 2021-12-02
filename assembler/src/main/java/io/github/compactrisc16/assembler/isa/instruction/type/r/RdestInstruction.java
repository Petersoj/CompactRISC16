package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

import java.util.List;

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
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 2) {
            throw new InstructionParseException(formatInstructParseExceptionMessage(lineWords, "<Rdest>"));
        }

        rdest = parseRegister(lineWords.get(INSTRUCTION_INDEX_RDEST));
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8;
    }

    public Register getRdest() {
        return rdest;
    }
}
