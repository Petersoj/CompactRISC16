package io.github.compactrisc16.assembler.isa.register;

/**
 * {@link Register} represents a CR16 register.
 */
public class Register {

    private final String name;
    private final int index;

    /**
     * Instantiates a new {@link Register}.
     *
     * @param name  the name
     * @param index the index
     */
    protected Register(String name, int index) {
        this.name = name;
        this.index = index;
    }

    public String getName() {
        return name;
    }

    public int getIndex() {
        return index;
    }
}
