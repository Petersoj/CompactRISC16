package io.github.compactrisc16.assembler.util;

/**
 * {@link BasedNumberParser} contains utility methods to parse numbers with various base indicators given in a {@link
 * String}.
 */
public final class BasedNumberParser {

    /**
     * Parses a {@link String} into an int. If the given <code>number</code> starts with <code>0b</code>, then {@link
     * Integer#parseInt(String, int)} with <code>radix</code> of <code>2</code> is called, otherwise {@link
     * Integer#decode(String)} is called.
     *
     * @param number the number {@link String}
     *
     * @return the int
     *
     * @throws NumberFormatException thrown for {@link NumberFormatException}s
     */
    public static int parseInt(String number) throws NumberFormatException {
        number = number.replace("_", "");

        if (number.toLowerCase().startsWith("0b")) {
            return Integer.parseUnsignedInt(number.substring(2), 2);
        } else {
            return Integer.decode(number);
        }
    }
}
