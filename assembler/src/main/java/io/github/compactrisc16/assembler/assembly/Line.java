package io.github.compactrisc16.assembler.assembly;

import java.util.ArrayList;
import java.util.List;

/**
 * {@link Line} represents a line of assembly code.
 */
public class Line {

    private List<String> lineWords;
    private int sourceLineNumber;

    /**
     * Instantiates a new {@link Line}.
     *
     * @param lineWords        the line words
     * @param sourceLineNumber the visual line number
     */
    public Line(List<String> lineWords, int sourceLineNumber) {
        this.lineWords = new ArrayList<>(lineWords); // Copy constructor to ensure list mutability
        this.sourceLineNumber = sourceLineNumber;
    }

    public List<String> getLineWords() {
        return lineWords;
    }

    public void setLineWords(List<String> lineWords) {
        this.lineWords = lineWords;
    }

    public int getSourceLineNumber() {
        return sourceLineNumber;
    }

    public void setSourceLineNumber(int sourceLineNumber) {
        this.sourceLineNumber = sourceLineNumber;
    }

    @Override
    public String toString() {
        return "Line{" +
                "lineWords=" + lineWords +
                ", visualLineNumber=" + sourceLineNumber +
                '}';
    }
}
