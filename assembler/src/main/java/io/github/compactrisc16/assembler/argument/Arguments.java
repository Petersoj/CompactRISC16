package io.github.compactrisc16.assembler.argument;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.Parameter;
import com.beust.jcommander.ParameterException;
import com.beust.jcommander.converters.FileConverter;
import io.github.compactrisc16.assembler.Assembler;

import java.io.File;
import java.util.Arrays;
import java.util.function.Function;

/**
 * {@link Arguments} contains the arguments parsed from the command line to be used for the {@link Assembler}.
 */
public class Arguments {

    private final String[] argumentStrings;

    @Parameter(description = "<assembly code file path>", converter = FileConverter.class, required = true)
    private File assemblyFile;

    @Parameter(names = {"-o", "--output"},
            description = "The output binary file path. Defaults to <input assembly file>.dat.")
    private File outputFile;

    @Parameter(names = {"-s", "--output-processed"},
            description = "True to write the processed assembly to <output binary file path>.processed.asm.")
    private boolean outputProcessed = false;
    private File processedOutputFile;

    @Parameter(names = {"-b", "--number-base"}, description = "The number base of the output binary.")
    private NumberBase numberBase = NumberBase.HEX;
    private Function<Integer, String> numberBaseConverter;
    private String numberBasePadding;

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
    @SuppressWarnings("ResultOfMethodCallIgnored")
    public void parse() throws ParameterException, IllegalArgumentException {
        JCommander.newBuilder()
                .programName("assembler")
                .addObject(this)
                .build()
                .parse(argumentStrings);

        if (!assemblyFile.exists() || !assemblyFile.isFile()) {
            throw new IllegalArgumentException(String.format("\"%s\" is not a valid file.", assemblyFile.toString()));
        }

        if (outputFile == null) {
            int lastPeriodIndex = assemblyFile.getName().lastIndexOf('.');
            outputFile = new File(assemblyFile.getParentFile(),
                    (lastPeriodIndex == -1 ? assemblyFile.getName() :
                     assemblyFile.getName().substring(0, lastPeriodIndex)) + ".dat");
        }
        outputFile.getParentFile().mkdirs(); // Recursively create parent directories for 'outputFile'

        if (outputProcessed) {
            int lastPeriodIndex = outputFile.getName().lastIndexOf('.');
            processedOutputFile = new File(outputFile.getParentFile(),
                    (lastPeriodIndex == -1 ? outputFile.getName() :
                     outputFile.getName().substring(0, lastPeriodIndex)) + ".processed.asm");
        }

        // Create a number base converter that takes in an integer and converts it to the desired output number base
        switch (numberBase) {
            case BINARY:
                numberBaseConverter = Integer::toBinaryString;
                numberBasePadding = "0000000000000000";
                break;
            case DECIMAL:
                numberBaseConverter = Object::toString;
                numberBasePadding = "00000";
                break;
            case HEX:
                numberBaseConverter = Integer::toHexString;
                numberBasePadding = "0000";
                break;
            default:
                throw new UnsupportedOperationException();
        }
    }

    public String[] getArgumentStrings() {
        return argumentStrings;
    }

    public File getAssemblyFile() {
        return assemblyFile;
    }

    public File getOutputFile() {
        return outputFile;
    }

    public boolean isOutputProcessed() {
        return outputProcessed;
    }

    public File getProcessedOutputFile() {
        return processedOutputFile;
    }

    public NumberBase getNumberBase() {
        return numberBase;
    }

    public Function<Integer, String> getNumberBaseConverter() {
        return numberBaseConverter;
    }

    public String getNumberBasePadding() {
        return numberBasePadding;
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
                ", outputFile=" + outputFile +
                ", outputProcessed=" + outputProcessed +
                ", processedOutputFile=" + processedOutputFile +
                ", numberBase=" + numberBase +
                ", numberBaseConverter=" + numberBaseConverter +
                ", numberBasePadding='" + numberBasePadding + '\'' +
                ", maxPaddingLine=" + maxPaddingLine +
                ", maxPaddingLineValue=" + maxPaddingLineValue +
                ", debug=" + debug +
                '}';
    }
}
