package io.github.compactrisc16.assembler.assembly;

/**
 * {@link Label} represents a <code>.label</code> assembly label. A label always points to the next instruction or
 * number in the given assembly file.
 */
public class Label {

    private String name;
    private Integer address;

    /**
     * Instantiates a new {@link Label}.
     *
     * @param name    the name
     * @param address the address
     */
    public Label(String name, Integer address) {
        this.name = name;
        this.address = address;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAddress() {
        return address;
    }

    public void setAddress(Integer address) {
        this.address = address;
    }
}
