package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

import java.util.List;

/**
 * {@link CallInstruction} is an {@link OpcodeExtInstruction} representing a <code>CALL</code> instruction with
 * <code>Rtarget</code> as an argument.
 */
public class CallInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RTARGET = 1;

    private Register rtarget;

    /**
     * Instantiates a new {@link CallInstruction}.
     */
    public CallInstruction() {
        super("CALL", 0b1111, 0b0011);
    }

    @Override
    public void parse(List<String> lineWords) throws InstructionParseException {
        if (lineWords.size() != 2) {
            throw new InstructionParseException(String.format("Invalid arguments. Expected: %s <Rtarget>", mnemonic));
        }

        rtarget = parseRegister(lineWords.get(INSTRUCTION_INDEX_RTARGET));
    }

    @Override
    public int assemble() {
        return super.assemble() | rtarget.getIndex();
    }

    public Register getRtarget() {
        return rtarget;
    }
}
