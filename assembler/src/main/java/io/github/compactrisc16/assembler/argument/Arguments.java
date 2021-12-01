package io.github.compactrisc16.assembler.argument;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import com.beust.jcommander.converters.FileConverter;
import io.github.compactrisc16.assembler.Assembler;

import java.io.File;
import java.util.Arrays;

/**
 * {@link Arguments} contains the arguments parsed from the command line to be used for the {@link Assembler}.
 */
public class Arguments {

    private final String[] argumentStrings;

    @Parameter(description = "<assembly code file path>", converter = FileConverter.class, required = true)
    private File assemblyFile;

    @Parameter(names = {"-o", "--output"},
            description = "The output binary file path. Defaults to <input assembly file>.dat.")
    private File output;

    @Parameter(names = {"-b", "--number-base"}, description = "The number base of the output binary.")
    private NumberBase numberBase = NumberBase.HEX;

    @Parameter(names = {"-p", "--max-padding-line"},
            description = "The line number to which padding lines should be added to an output binary.")
    private int maxPaddingLine = 0;

    @Parameter(names = {"-v", "--max-padding-line-value"}, description = "The decimal value of the padding lines.")
    private int maxPaddingLineValue = 0;

    @Parameter(names = {"-d", "--debug"}, description = "Turns on debug mode.")
    private boolean debug = false;

    /**
     * Instantiates a new {@link Arguments}.
     *
     * @param argumentStrings the input argument {@link String}s
     */
    public Arguments(String[] argumentStrings) {
        this.argumentStrings = argumentStrings;
    }

    /**
     * Parses the arguments.
     *
     * @throws ParameterException       thrown for {@link ParameterException}s from {@link JCommander}
     * @throws IllegalArgumentException thrown for {@link IllegalArgumentException}s which occurs when parsing
     *                                  succeeded, but the arguments parsed are illegal
     */
    public void parse() throws ParameterException, IllegalArgumentException {
        JCommander.newBuilder()
                .programName("assembler")
                .addObject(this)
                .build()
                .parse(argumentStrings);

        if (!assemblyFile.exists() || !assemblyFile.isFile()) {
            throw new IllegalArgumentException(String.format("\"%s\" is not a valid file.", assemblyFile.toString()));
        }

        if (output == null) {
            int lastIndexOfPeriod = assemblyFile.getName().lastIndexOf('.');
            output = new File(assemblyFile.getParentFile(),
                    (lastIndexOfPeriod == -1 ? assemblyFile.getName() :
                     assemblyFile.getName().substring(0, lastIndexOfPeriod)) + ".dat");
        }
    }

    public String[] getArgumentStrings() {
        return argumentStrings;
    }

    public File getAssemblyFile() {
        return assemblyFile;
    }

    public File getOutput() {
        return output;
    }

    public NumberBase getNumberBase() {
        return numberBase;
    }

    public int getMaxPaddingLine() {
        return maxPaddingLine;
    }

    public int getMaxPaddingLineValue() {
        return maxPaddingLineValue;
    }

    public boolean isDebug() {
        return debug;
    }

    @Override
    public String toString() {
        return "Arguments{" +
                "argumentStrings=" + Arrays.toString(argumentStrings) +
                ", assemblyFile=" + assemblyFile +
                ", output=" + output +
                ", numberBase=" + numberBase +
                ", maxPaddingLine=" + maxPaddingLine +
                ", maxPaddingLineValue=" + maxPaddingLineValue +
                '}';
    }
}
