package io.github.compactrisc16.compiler;

import com.beust.jcommander.ParameterException;
import io.github.compactrisc16.compiler.arguments.Arguments;

/**
 * {@link Compiler} is used to compile assembly code for the CompactRISC16 (CR16) CPU for the Computer Design Laboratory
 * ECE 3710 class at The University of Utah.
 */
public class Compiler {

    private final String[] argumentStrings;
    private Arguments arguments;

    /**
     * Instantiates a new {@link Compiler}.
     *
     * @param argumentStrings the input argument {@link String}s
     */
    public Compiler(String[] argumentStrings) {
        this.argumentStrings = argumentStrings;
    }

    public void run() {
        arguments = new Arguments(argumentStrings);
        try {
            arguments.parse();
        } catch (ParameterException exception) {
            exception.usage();
            return;
        }

        // TODO implement compiler
        System.out.println(arguments);
    }

    /**
     * The entry point of application.
     *
     * @param args the input arguments
     */
    public static void main(String[] args) {
        Compiler compiler = new Compiler(args);
        compiler.run();
    }
}
