package io.github.compactrisc16.assembler.isa.instruction;

import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.register.Register;
import io.github.compactrisc16.assembler.isa.register.Registers;
import io.github.compactrisc16.assembler.util.BasedNumberParser;

import java.util.List;

import static io.github.compactrisc16.assembler.isa.register.Registers.REGISTERS_OF_NAMES;

/**
 * {@link AbstractInstruction} represents an abstract CR16 instruction.
 */
public abstract class AbstractInstruction {

    protected final String mnemonic;
    protected final int opcode;

    /**
     * Instantiates a new {@link AbstractInstruction}.
     *
     * @param mnemonic the mnemonic
     * @param opcode   the opcode
     */
    public AbstractInstruction(String mnemonic, int opcode) {
        this.mnemonic = mnemonic;
        this.opcode = opcode;
    }

    /**
     * Parses an assembly instruction {@link String}.
     *
     * @param lineWords the assembly code line word {@link String}s
     *
     * @throws InstructionParseException thrown for {@link InstructionParseException}s
     */
    public abstract void parse(List<String> lineWords) throws InstructionParseException;

    /**
     * Parses the given <code>registerString</code> (which is confined to {@link Register#getName()} in {@link
     * Registers}}) to a {@link Register}.
     *
     * @param registerString the register {@link String}
     *
     * @return the {@link Register}
     *
     * @throws InstructionParseException thrown for {@link InstructionParseException}s
     */
    public static Register parseRegister(String registerString) throws InstructionParseException {
        Register register = REGISTERS_OF_NAMES.get(registerString);
        if (register == null) {
            throw new InstructionParseException("Unrecognized register: " + registerString);
        }
        return register;
    }

    /**
     * Parses the given <code>immediateString</code> to an int.
     *
     * @param immediateString the immediate {@link String}
     * @param min             the minimum allowable value
     * @param max             the maximum allowable value
     *
     * @return the immediate int
     *
     * @throws InstructionParseException thrown for {@link InstructionParseException}s
     */
    public static int parseImmediate(String immediateString, int min, int max) throws InstructionParseException {
        int immediate;

        try {
            immediate = BasedNumberParser.parseInt(immediateString);
        } catch (NumberFormatException exception) {
            throw new InstructionParseException("Could not parse immediate value: " +
                    exception.getMessage(), exception);
        }

        if (immediate < min) {
            throw new InstructionParseException("Immediate value cannot be less than: " + min +
                    " (" + Integer.toBinaryString(min) + " in binary)");
        } else if (immediate > max) {
            throw new InstructionParseException("Immediate value cannot be greater than: " + max +
                    " (" + Integer.toBinaryString(max) + " in binary)");
        }

        return immediate;
    }

    /**
     * Formats a {@link String} for the {@link InstructionParseException#getMessage()}.
     *
     * @param lineWords         the {@link List} of line words
     * @param expectedArguments the expected arguments {@link String}
     *
     * @return a formatted {@link String}
     */
    protected String formatInstructParseExceptionMessage(List<String> lineWords, String expectedArguments) {
        return String.format("Invalid arguments. Expected: %s%s. Got: %s",
                mnemonic, expectedArguments.length() != 0 ? " " + expectedArguments : "", String.join(" ", lineWords));
    }

    /**
     * Assembles an assembly instruction {@link String} into the equivalent machine code.
     *
     * @return the machine code 16-bit-masked {@link Integer}
     */
    public int assemble() {
        return opcode << 12;
    }

    public String getMnemonic() {
        return mnemonic;
    }

    public int getOpcode() {
        return opcode;
    }
}
