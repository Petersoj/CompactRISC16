package io.github.compactrisc16.assembler.assembly;

/**
 * {@link Label} represents a <code>.label</code> assembly label. A label always points to the next instruction or
 * number in the given assembly file.
 */
public class Label {

    private final String name;

    private Line line;
    private Integer address;

    /**
     * Instantiates a new {@link Label}.
     *
     * @param name the name
     * @param line the {@link Line}
     */
    public Label(String name, Line line) {
        this.name = name;
        this.line = line;
    }

    public String getName() {
        return name;
    }

    public Line getLine() {
        return line;
    }

    public void setLine(Line line) {
        this.line = line;
    }

    public Integer getAddress() {
        return address;
    }

    public void setAddress(Integer address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "Label{" +
                "name='" + name + '\'' +
                ", line=" + line +
                ", address=" + address +
                '}';
    }
}
