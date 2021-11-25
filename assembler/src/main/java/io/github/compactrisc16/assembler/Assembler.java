package io.github.compactrisc16.assembler;

import com.beust.jcommander.ParameterException;
import io.github.compactrisc16.assembler.argument.Arguments;
import io.github.compactrisc16.assembler.util.BasedNumberParser;

/**
 * {@link Assembler} is used to assemble assembly code for the CompactRISC16 (CR16) CPU for the Computer Design
 * Laboratory ECE 3710 class at The University of Utah.
 */
public class Assembler {

    private final String[] argumentStrings;
    private Arguments arguments;

    /**
     * Instantiates a new {@link Assembler}.
     *
     * @param argumentStrings the input argument {@link String}s
     */
    public Assembler(String[] argumentStrings) {
        this.argumentStrings = argumentStrings;
    }

    public void run() {
        System.out.println(BasedNumberParser.parseInt(argumentStrings[0]));
        System.out.println(Integer.toBinaryString(BasedNumberParser.parseInt(argumentStrings[0])));

        arguments = new Arguments(argumentStrings);
        try {
            arguments.parse();
        } catch (ParameterException exception) {
            exception.usage();
            return;
        } catch (IllegalArgumentException exception) {
            if (arguments.isDebug()) {
                exception.printStackTrace();
            } else {
                System.err.println(exception.getMessage());
            }
            return;
        }

        // TODO implement assembler
        System.out.println(arguments);
    }

    /**
     * The entry point of application.
     *
     * @param args the input arguments
     */
    public static void main(String[] args) {
        Assembler assembler = new Assembler(args);
        assembler.run();
    }
}
