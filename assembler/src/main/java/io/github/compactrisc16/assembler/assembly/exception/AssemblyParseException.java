package io.github.compactrisc16.assembler.assembly.exception;

/**
 * {@link AssemblyParseException} represents a (checked) {@link Exception} thrown when an assembly parse procedure
 * produces an error.
 */
public class AssemblyParseException extends Exception {

    private final Integer lineNumber;

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param message    the message
     * @param lineNumber the line number (<code>null</code> to disregard)
     */
    public AssemblyParseException(String message, Integer lineNumber) {
        super(message);
        this.lineNumber = lineNumber;
    }

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param cause      the cause {@link Throwable}
     * @param lineNumber the line number (<code>null</code> to disregard)
     */
    public AssemblyParseException(Throwable cause, Integer lineNumber) {
        super(cause.getClass().getSimpleName() + ": " + cause.getMessage(), cause);
        this.lineNumber = lineNumber;
    }

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param message    the message
     * @param cause      the cause {@link Throwable}
     * @param lineNumber the line number (<code>null</code> to disregard)
     */
    public AssemblyParseException(String message, Throwable cause, Integer lineNumber) {
        super(message, cause);
        this.lineNumber = lineNumber;
    }

    @Override
    public String getMessage() {
        return lineNumber == null ? "" : "On line " + lineNumber + ": " + super.getMessage();
    }
}
