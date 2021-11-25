package io.github.compactrisc16.assembler.isa.instruction.type.r;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

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
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 2) {
            throw new InstructionParseException(String.format("Invalid arguments. Expected: %s <Rtarget>", mnemonic));
        }

        rtarget = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RTARGET]);
    }

    @Override
    public int assemble() {
        return super.assemble() | rtarget.getIndex();
    }
}
