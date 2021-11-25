package io.github.compactrisc16.assembler.isa.instruction.exception;

/**
 * {@link InstructionParseException} represents a (checked) {@link Exception} thrown when an instruction parse procedure
 * produces an error.
 */
public class InstructionParseException extends Exception {

    /**
     * Instantiates a new {@link InstructionParseException}.
     *
     * @param message the message
     */
    public InstructionParseException(String message) {
        super(message);
    }

    /**
     * Instantiates a new {@link InstructionParseException}.
     *
     * @param cause the cause {@link Throwable}
     */
    public InstructionParseException(Throwable cause) {
        super(cause);
    }

    /**
     * Instantiates a new {@link InstructionParseException}.
     *
     * @param message the message
     * @param cause   the cause {@link Throwable}
     */
    public InstructionParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
