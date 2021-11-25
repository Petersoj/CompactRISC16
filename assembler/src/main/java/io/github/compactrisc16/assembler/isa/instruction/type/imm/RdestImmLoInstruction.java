package io.github.compactrisc16.assembler.isa.instruction.type.imm;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.OpcodeExtInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;

/**
 * {@link RdestImmLoInstruction} is an {@link OpcodeExtInstruction} with <code>Rdest</code> and <code>ImmLo</code> as
 * arguments.
 */
public class RdestImmLoInstruction extends OpcodeExtInstruction {

    public static final int INSTRUCTION_INDEX_RDEST = 1;
    public static final int INSTRUCTION_INDEX_IMMLO = 2;

    private Register rdest;
    private int immLo;

    /**
     * Instantiates a new {@link RdestImmLoInstruction}.
     *
     * @param mnemonic        the mnemonic
     * @param opcode          the opcode
     * @param opcodeExtension the opcode extension
     */
    public RdestImmLoInstruction(String mnemonic, int opcode, int opcodeExtension) {
        super(mnemonic, opcode, opcodeExtension);
    }

    @Override
    public void parse(String[] assemblyInstruction) throws InstructionParseException {
        if (assemblyInstruction.length != 3) {
            throw new InstructionParseException(
                    String.format("Invalid arguments. Expected: %s <Rdest>, <ImmLo>", mnemonic));
        }

        rdest = parseRegister(assemblyInstruction[INSTRUCTION_INDEX_RDEST]);
        immLo = parseImmediate(assemblyInstruction[INSTRUCTION_INDEX_IMMLO], 0, 15);
    }

    @Override
    public int assemble() {
        return super.assemble() | rdest.getIndex() << 8 | (immLo & 0xF);
    }
}
