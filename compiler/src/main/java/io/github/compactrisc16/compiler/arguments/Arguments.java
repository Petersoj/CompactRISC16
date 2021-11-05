package io.github.compactrisc16.compiler.arguments;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import com.beust.jcommander.converters.FileConverter;
import io.github.compactrisc16.compiler.Compiler;

import java.io.File;
import java.util.Arrays;

/**
 * {@link Arguments} contains the arguments parsed from the command line to be used for the {@link Compiler}.
 */
public class Arguments {

    private final String[] argumentStrings;

    @Parameter(description = "<assembly code file path>", converter = FileConverter.class, required = true)
    private File assemblyFile;

    @Parameter(names = {"-o", "--output"},
            description = "The output binary file path. Defaults to <input assembly file>.bin.")
    private File output;

    @Parameter(names = {"-b", "--number-base"}, description = "The number base of the output binary.")
    private NumberBase numberBase = NumberBase.HEX;

    @Parameter(names = {"-p", "--max-padding-line"},
            description = "The line number to which padding lines should be added to an output binary.")
    private int maxPaddingLine = 0;

    @Parameter(names = {"-v", "--max-padding-line-value"}, description = "The decimal value of the padding lines.")
    private int maxPaddingLineValue = 0;

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
     * @throws ParameterException thrown for {@link ParameterException}s
     */
    public void parse() throws ParameterException {
        JCommander.newBuilder()
                .programName("compiler")
                .addObject(this)
                .build()
                .parse(argumentStrings);

        if (!assemblyFile.exists() || !assemblyFile.isFile()) {
            System.err.printf("%s is not a valid file.\n", assemblyFile.toString());
            return;
        }

        if (output == null) {
            int lastIndexOfPeriod = assemblyFile.getName().lastIndexOf('.');
            output = new File(assemblyFile.getParentFile(),
                    (lastIndexOfPeriod == -1 ? assemblyFile.getName() :
                     assemblyFile.getName().substring(0, lastIndexOfPeriod)) + ".bin");
        }
    }

    /**
     * Gets {@link #assemblyFile}.
     *
     * @return the {@link #assemblyFile}
     */
    public File getAssemblyFile() {
        return assemblyFile;
    }

    /**
     * Gets {@link #argumentStrings}.
     *
     * @return the {@link #argumentStrings}
     */
    public String[] getArgumentStrings() {
        return argumentStrings;
    }

    /**
     * Gets {@link #output}.
     *
     * @return the {@link #output}
     */
    public File getOutput() {
        return output;
    }

    /**
     * Gets {@link #numberBase}.
     *
     * @return the {@link #numberBase}
     */
    public NumberBase getNumberBase() {
        return numberBase;
    }

    /**
     * Gets {@link #maxPaddingLine}.
     *
     * @return the {@link #maxPaddingLine}
     */
    public int getMaxPaddingLine() {
        return maxPaddingLine;
    }

    /**
     * Gets {@link #maxPaddingLineValue}.
     *
     * @return the {@link #maxPaddingLineValue}
     */
    public int getMaxPaddingLineValue() {
        return maxPaddingLineValue;
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
