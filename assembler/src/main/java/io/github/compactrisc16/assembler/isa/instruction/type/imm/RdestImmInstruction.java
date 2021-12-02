package io.github.compactrisc16.assembler.isa.instruction.type.imm;

import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.register.Register;

import java.util.List;

/**
 * {@link RdestImmInstruction} is an {@link AbstractInstruction} with <code>Rdest</code> and <code>Imm</code> as
 * arguments.
 */
public class RdestImmInstruction extends AbstractInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;
    public static final int INSTRUCTION_INDEX_IMM = 2;

    private Register rdest;
    private int imm;

    /**
     * Instantiates a new {@link RdestImmInstruction}.
     *
     * @param mnemonic the mnemonic
     * @param opcode   the opcode
     */
    public RdestImmInstruction(String mnemonic, int opcode) {
        super(mnemonic, opcode);
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 3) {
            throw new InstructionParseException(formatInstructParseExceptionMessage(lineWords, "<Rdest> <Imm>"));
        }

        rdest = parseRegister(lineWords.get(INSTRUCTION_INDEX_RDEST));
        // Note that the maximum allowable value is '0xFF' because the assembly can contain unsigned integers, and it's
        // up to the programmer to determine if the number should be interpreted as unsigned or signed numbers at
        // CR16 runtime.
        imm = parseImmediate(lineWords.get(INSTRUCTION_INDEX_IMM), Byte.MIN_VALUE, 0xFF);
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8 | (imm & 0xFF);
    }

    public Register getRdest() {
        return rdest;
    }

    public int getImm() {
        return imm;
    }
}
