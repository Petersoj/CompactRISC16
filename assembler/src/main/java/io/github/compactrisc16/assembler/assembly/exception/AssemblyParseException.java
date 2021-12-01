package io.github.compactrisc16.assembler.assembly.exception;

/**
 * {@link AssemblyParseException} represents a (checked) {@link Exception} thrown when an assembly parse procedure
 * produces an error.
 */
public class AssemblyParseException extends Exception {

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param message    the message
     * @param lineNumber the line number (<code>null</code> to disregard)
     */
    public AssemblyParseException(String message, Integer lineNumber) {
        super((lineNumber == null ? "" : "On line " + lineNumber + ": ") + message);
    }

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param cause the cause {@link Throwable}
     */
    public AssemblyParseException(Throwable cause) {
        super(cause);
    }

    /**
     * Instantiates a new {@link AssemblyParseException}.
     *
     * @param message the message
     * @param cause   the cause {@link Throwable}
     */
    public AssemblyParseException(String message, Throwable cause) {
        super(message, cause);
    }
}
