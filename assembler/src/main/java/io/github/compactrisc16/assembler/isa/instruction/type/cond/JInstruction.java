package io.github.compactrisc16.assembler.isa.instruction.type.cond;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

/**
 * {@link JInstruction} is an {@link OpcodeExtInstruction} representing a <code>J[condition]</code> instruction with
 * <code>Rtarget</code> as an argument.
 */
public class JInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RTARGET = 1;

    private final int condition;

    private Register rtarget;

    /**
     * Instantiates a new {@link JInstruction}.
     *
     * @param mnemonic  the mnemonic
     * @param condition the condition
     */
    public JInstruction(String mnemonic, int condition) {
        super(mnemonic, 0b1111, 0b0010);
        this.condition = condition;
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 2) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Rtarget>", mnemonic));
        }

        rtarget = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RTARGET]);
    }

    @Override
    public int assemble() {
        return super.assemble() | condition << 8 | rtarget.getIndex();
    }
}
