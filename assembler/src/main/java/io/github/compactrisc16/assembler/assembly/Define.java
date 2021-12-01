package io.github.compactrisc16.assembler.assembly;

/**
 * {@link Define} represents a <code>`define</code> label in assembly.
 */
public class Define {

    private final String before;
    private final String after;

    /**
     * Instantiates a new Define.
     *
     * @param before the before {@link String}
     * @param after  the after {@link String}
     */
    public Define(String before, String after) {
        this.before = before;
        this.after = after;
    }

    public String getBefore() {
        return before;
    }

    public String getAfter() {
        return after;
    }

    @Override
    public String toString() {
        return "Define{" +
                "before='" + before + '\'' +
                ", after='" + after + '\'' +
                '}';
    }
}
