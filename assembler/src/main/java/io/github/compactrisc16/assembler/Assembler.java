package io.github.compactrisc16.assembler;

import com.beust.jcommander.ParameterException;
import com.google.common.base.Splitter;
import com.google.common.collect.Sets;
import io.github.compactrisc16.assembler.argument.Arguments;
import io.github.compactrisc16.assembler.assembly.Define;
import io.github.compactrisc16.assembler.assembly.Label;
import io.github.compactrisc16.assembler.assembly.Line;
import io.github.compactrisc16.assembler.assembly.exception.AssemblyParseException;
import io.github.compactrisc16.assembler.isa.instruction.AbstractInstruction;
import io.github.compactrisc16.assembler.isa.instruction.exception.InstructionParseException;
import io.github.compactrisc16.assembler.isa.instruction.type.cond.BInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.imm.CalldInstruction;
import io.github.compactrisc16.assembler.isa.instruction.type.r.RdestRsrcInstruction;
import io.github.compactrisc16.assembler.isa.register.Register;
import io.github.compactrisc16.assembler.isa.register.Registers;
import io.github.compactrisc16.assembler.util.BasedNumberParser;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static io.github.compactrisc16.assembler.isa.instruction.Instructions.B_INSTRUCTIONS;
import static io.github.compactrisc16.assembler.isa.instruction.Instructions.CALL;
import static io.github.compactrisc16.assembler.isa.instruction.Instructions.CALLD;
import static io.github.compactrisc16.assembler.isa.instruction.Instructions.INSTRUCTIONS_OF_MNEMONICS;
import static io.github.compactrisc16.assembler.isa.instruction.Instructions.J_INSTRUCTIONS;
import static io.github.compactrisc16.assembler.isa.instruction.Instructions.MOV;
import static java.util.function.Predicate.not;

/**
 * {@link Assembler} is used to assemble assembly code for the CompactRISC16 (CR16) CPU for the Computer Design
 * Laboratory ECE 3710 class at The University of Utah.
 */
public class Assembler {

    private static final Splitter WHITESPACE_SPLITTER = Splitter.onPattern("\\s+");
    private static final String COMMENT_DELIMITER = "#";
    private static final String DEFINE_DESIGNATOR = "`define";
    private static final String LABEL_PREFIX = ".";
    private static final Splitter LABEL_LOADING_REGISTER_SPLITTER = Splitter.onPattern("\\$");
    private static final Register PARSE_TEST_DUMMY_REGISTER = Registers.R0;

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
        arguments = new Arguments(argumentStrings);
        try {
            arguments.parse();
        } catch (ParameterException exception) {
            exception.usage();
            return;
        } catch (IllegalArgumentException exception) {
            printException(exception);
            return;
        }

        try {
            List<String> lineStrings = Files.readAllLines(arguments.getAssemblyFile().toPath());
            List<Line> lines = cleanAssembly(lineStrings);
            processDefines(lines);
            processLabels(lines);
            assembleAndWriteOutput(lines);
        } catch (Exception exception) {
            printException(exception);
        }
    }

    /**
     * Cleans the given {@link List} of assembly code line {@link String}s. This will split assembly lines using the
     * {@link #WHITESPACE_SPLITTER}, remove comments (the {@link #COMMENT_DELIMITER}), and remove blank lines.
     *
     * @param lineStrings the {@link List} of raw assembly code line {@link String}s
     *
     * @return a {@link List} of assembly {@link Line}s
     */
    private List<Line> cleanAssembly(List<String> lineStrings) {
        final List<Line> cleanAssembly = new ArrayList<>();
        for (int lineNumber = 0, size = lineStrings.size(); lineNumber < size; lineNumber++) {
            String lineString = lineStrings.get(lineNumber);
            // Split 'lineStrings' by whitespace or comma followed by whitespace
            List<String> lineWords = WHITESPACE_SPLITTER.splitToList(lineString).stream()
                    .filter(not(String::isBlank)) // Remove blank strings
                    .collect(Collectors.toList());

            // Remove everything on assembly line after comment
            for (int index = 0; index < lineWords.size(); index++) {
                if (lineWords.get(index).startsWith(COMMENT_DELIMITER)) {
                    int removedIndex = lineWords.size() - 1;
                    while (removedIndex >= index) {
                        lineWords.remove(removedIndex--);
                    }
                    break;
                }
            }

            // Skip blank lineStrings
            if (lineWords.size() == 0) {
                continue;
            }

            cleanAssembly.add(new Line(lineWords, lineNumber + 1));
        }

        return cleanAssembly;
    }

    /**
     * Processes (applies and removes) {@link Define}s in the given assembly {@link Line}s.
     *
     * @param lines the assembly {@link Line}s (must be return value from {@link #cleanAssembly(List)})
     *
     * @throws AssemblyParseException thrown for {@link AssemblyParseException}s
     */
    private void processDefines(List<Line> lines) throws AssemblyParseException {
        // Index all '`define' statements in the 'lines'
        final List<Define> defines = new ArrayList<>();
        final List<Integer> removeIndices = new ArrayList<>();
        for (int lineIndex = 0, size = lines.size(); lineIndex < size; lineIndex++) {
            Line line = lines.get(lineIndex);
            List<String> lineWords = line.getLineWords();

            if (lineWords.get(0).equalsIgnoreCase(DEFINE_DESIGNATOR)) {
                if (lineWords.size() != 3) {
                    throw new AssemblyParseException(DEFINE_DESIGNATOR + " can only contain 2 arguments. Got: " +
                            String.join(" ", lineWords), line.getSourceLineNumber());
                }

                Define define = new Define(lineWords.get(1), lineWords.get(2));

                if (defines.stream().map(Define::getBefore).anyMatch(s -> s.equals(define.getBefore()))) {
                    throw new AssemblyParseException(String.join(" ", lineWords) + " already exists.",
                            line.getSourceLineNumber());
                }

                defines.add(define);
                removeIndices.add(lineIndex);
            }
        }

        // Remove all 'removeIndices'
        removeIndices.stream().sorted(Comparator.reverseOrder())
                .mapToInt(Integer::intValue)
                .forEachOrdered(lines::remove);

        // Apply all 'define's
        final Map<String, Define> definesOfBeforeStrings = defines.stream()
                .collect(Collectors.toMap(Define::getBefore, Function.identity()));
        for (Line line : lines) {
            List<String> lineWords = line.getLineWords();
            for (int wordIndex = 0, size = lineWords.size(); wordIndex < size; wordIndex++) {
                String word = lineWords.get(wordIndex);
                Define defineOfWord = definesOfBeforeStrings.get(word);
                if (defineOfWord != null) {
                    lineWords.set(wordIndex, defineOfWord.getAfter());
                }
            }
        }
    }

    /**
     * Processes (applies and removes) {@link Label}s in the given assembly lines.
     *
     * @param lines the assembly {@link Line}s (must be return value from {@link #cleanAssembly(List)})
     *
     * @throws AssemblyParseException thrown for {@link AssemblyParseException}s
     */
    private void processLabels(List<Line> lines) throws AssemblyParseException {
        // Index all 'Label' definitions
        final List<Label> labels = new ArrayList<>();
        final List<Integer> removeIndices = new ArrayList<>();
        for (int lineIndex = 0, size = lines.size(); lineIndex < size; lineIndex++) {
            Line line = lines.get(lineIndex);
            List<String> lineWords = line.getLineWords();
            String labelWord = lineWords.get(0);

            if (labelWord.startsWith(LABEL_PREFIX)) {
                if (lineWords.size() != 1) {
                    throw new AssemblyParseException(LABEL_PREFIX + "label must contain one word per line. Got: " +
                            String.join(" ", lineWords), line.getSourceLineNumber());
                } else if (labelWord.length() <= 1) {
                    throw new AssemblyParseException(LABEL_PREFIX + "label must contain a name. Got: " +
                            String.join(" ", lineWords), line.getSourceLineNumber());
                }

                // Create a label that points to the next assembly line
                Label label = new Label(labelWord, lines.get(lineIndex + 1));

                if (labels.stream().map(Label::getName).anyMatch(s -> s.equals(label.getName()))) {
                    throw new AssemblyParseException(label.getName() + " already exists.", line.getSourceLineNumber());
                }

                labels.add(label);
                removeIndices.add(lineIndex);
            }
        }

        // Remove all 'removeIndices'
        removeIndices.stream().sorted(Comparator.reverseOrder())
                .mapToInt(Integer::intValue)
                .forEachOrdered(lines::remove);

        // Expand lines containing labels to 'MOVIL' and 'MOVIU' instructions
        final Map<String, Label> labelsOfLabelNames = labels.stream()
                .collect(Collectors.toMap(Label::getName, Function.identity()));
        final Map<Entry<Line, AbstractInstruction>, Label> labelsOfJOrCalldInstructionLines = new HashMap<>();
        final Map<Entry<Line, Line>, Label> labelsOfMovLowerUpperImmediateLines = new HashMap<>();
        final List<Label> usedLabels = new ArrayList<>();
        for (int lineIndex = 0; lineIndex < lines.size(); lineIndex++) {
            Line line = lines.get(lineIndex);
            List<String> lineWords = line.getLineWords();

            // Loop through 'lineWords' and check for any labels
            Label label = null;
            Register loadingRegister = null;
            Integer wordIndexOfLabel = null;
            for (int wordIndex = 0, size = lineWords.size(); wordIndex < size; wordIndex++) {
                String word = lineWords.get(wordIndex);
                if (word.startsWith(LABEL_PREFIX)) {
                    if (label != null) {
                        throw new AssemblyParseException("Only one label reference per line is allowed.",
                                line.getSourceLineNumber());
                    }

                    List<String> labelAndLoadingRegister = LABEL_LOADING_REGISTER_SPLITTER.splitToList(word);
                    if (labelAndLoadingRegister.size() > 2) {
                        throw new AssemblyParseException("A label reference can only contain a label or a label and " +
                                "a loading register. Got: " + word, line.getSourceLineNumber());
                    }

                    label = labelsOfLabelNames.get(labelAndLoadingRegister.get(0));
                    if (label == null) {
                        throw new AssemblyParseException("Undefined label reference: " + word,
                                line.getSourceLineNumber());
                    }
                    wordIndexOfLabel = wordIndex;

                    if (labelAndLoadingRegister.size() == 2) {
                        try {
                            loadingRegister = AbstractInstruction.parseRegister(labelAndLoadingRegister.get(1));
                        } catch (InstructionParseException exception) {
                            throw new AssemblyParseException(exception, line.getSourceLineNumber());
                        }
                    }
                }
            }

            // Move on to next instruction if no label was found
            if (label == null) {
                continue;
            }

            AbstractInstruction lineInstruction = INSTRUCTIONS_OF_MNEMONICS.get(lineWords.get(0));

            if (lineInstruction == null) {
                throw new AssemblyParseException("Unknown instruction with label: " + String.join(" ", lineWords),
                        line.getSourceLineNumber());
            }

            // Temporarily replace label with dummy register to validate line parsing
            try {
                String labelString = lineWords.get(wordIndexOfLabel);
                lineWords.set(wordIndexOfLabel, PARSE_TEST_DUMMY_REGISTER.getName());

                lineInstruction.parse(lineWords);

                lineWords.set(wordIndexOfLabel, labelString);
            } catch (InstructionParseException exception) {
                throw new AssemblyParseException(exception, line.getSourceLineNumber());
            }

            // Assign 'rdest' accordingly for 'movilLine' and 'moviuLine' added below
            final int moveLineInsertionIndex = lineIndex;
            final Register rdest;
            if (lineInstruction == MOV) {
                try {
                    rdest = AbstractInstruction.parseRegister(
                            lineWords.get(RdestRsrcInstruction.INSTRUCTION_INDEX_RDEST));
                } catch (InstructionParseException exception) {
                    throw new AssemblyParseException(exception, line.getSourceLineNumber());
                }

                lines.remove(lineIndex); // Remove this 'MOV' instruction since only 'MOVIL' and 'MOVIU' are needed
                lineIndex++; // Skip one of the 'movilLine' and 'moviuLine' lines added below
            } else if (J_INSTRUCTIONS.contains(lineInstruction) || lineInstruction == CALL) {
                if (loadingRegister == null) {
                    throw new AssemblyParseException("A label reference for a J[condition] or CALL instruction must " +
                            "contain a loading register (the intermediary register used to load a label address in " +
                            "the event that the equivalent displacement immediate instruction cannot be used due " +
                            "to the label address offset being greater than the range of the immediate). " +
                            "e.g. .label$r1",
                            line.getSourceLineNumber());
                }

                rdest = loadingRegister;

                Line jOrCalldLineWithRdest = new Line(List.of(lineInstruction.getMnemonic(), rdest.getName()),
                        line.getSourceLineNumber());
                labelsOfJOrCalldInstructionLines.put(Map.entry(jOrCalldLineWithRdest, lineInstruction), label);

                lines.remove(lineIndex);
                lines.add(lineIndex, jOrCalldLineWithRdest);
                lineIndex += 2; // Skip the 'movilLine' and 'moviuLine' added below
            } else {
                throw new AssemblyParseException("Label now allowed with instruction: " +
                        String.join(" ", lineWords) +
                        ". Labels are only allowed for MOV, J[condition], and CALL instructions. " +
                        "Note that J[condition] and CALL instructions will become a B[condition] or CALLD " +
                        "instruction respectively if their label address is less than the maximum immediate " +
                        "range for the given displacement immediate instruction.",
                        line.getSourceLineNumber());
            }

            // Insert 'MOVIL' and 'MOVIU' instructions to load in the label address into the desired register
            // at 'moveLineInsertionIndex' in 'lines'

            Line movilLine = new Line(List.of("MOVIL", rdest.getName(), label.getName()), line.getSourceLineNumber());
            lines.add(moveLineInsertionIndex, movilLine);

            replaceLabelLine(labels, line, movilLine);

            Line moviuLine = new Line(List.of("MOVIU", rdest.getName(), label.getName()), line.getSourceLineNumber());
            lines.add(moveLineInsertionIndex + 1, moviuLine);

            labelsOfMovLowerUpperImmediateLines.put(Map.entry(movilLine, moviuLine), label);
            usedLabels.add(label);
        }

        // Loop through all 'labelsOfJOrCalldInstructionLines' and determine if it should be replaced with the
        // equivalent displacement immediate instruction.
        final Map<Line, Label> labelsOfPlaceholderLinesToDisplace = new HashMap<>();
        for (Entry<Entry<Line, AbstractInstruction>, Label> entry : labelsOfJOrCalldInstructionLines.entrySet()) {
            final Line jOrCalldLineWithRdest = entry.getKey().getKey();
            final AbstractInstruction jOrCalldLineInstruction = entry.getKey().getValue();
            final Label label = entry.getValue();

            computeLabelAddress(lines, label);
            int lineIndex = lines.indexOf(jOrCalldLineWithRdest);
            int labelAddress = label.getAddress();
            // Compute 'displacementValue' and subtract 1 since CR16 ISA states that 'B[condition]' and 'CALLD' displace
            // to immediate + 1
            int displacementValue = labelAddress - lineIndex - 1;

            // Assign displacement min and max (inclusive) and 'displacementImmediateInstructionMnemonic'
            // based on 'jInstructionsIndex'
            final int jInstructionsIndex = J_INSTRUCTIONS.indexOf(jOrCalldLineInstruction);
            final int minDisplacement;
            final int maxDisplacement;
            final String displacementImmediateInstructionMnemonic;
            if (jInstructionsIndex != -1) {
                minDisplacement = BInstruction.MIN_DISPLACEMENT_IMM;
                maxDisplacement = BInstruction.MAX_DISPLACEMENT_IMM;
                displacementImmediateInstructionMnemonic = B_INSTRUCTIONS.get(jInstructionsIndex).getMnemonic();
            } else {
                minDisplacement = CalldInstruction.MIN_DISPLACEMENT_IMM;
                maxDisplacement = CalldInstruction.MAX_DISPLACEMENT_IMM;
                displacementImmediateInstructionMnemonic = CALLD.getMnemonic();
            }

            // If 'displacementValue' is in range of immediate, remove 'movilLine' and 'moviuLine' lines and add
            // the equivalent 'displacementImmediateLinePlaceholder'
            if (displacementValue >= minDisplacement && displacementValue <= maxDisplacement) {
                int oldMovilLineIndex = lineIndex - 2;
                int oldMoviuLineIndex = lineIndex - 1;

                Line displacementImmediateLinePlaceholder = new Line(List.of(displacementImmediateInstructionMnemonic,
                        label.getName()), jOrCalldLineWithRdest.getSourceLineNumber());

                replaceLabelLine(labels, lines.get(oldMovilLineIndex), displacementImmediateLinePlaceholder);

                lines.remove(lineIndex);
                lines.remove(oldMoviuLineIndex);
                lines.remove(oldMovilLineIndex);
                lines.add(oldMovilLineIndex, displacementImmediateLinePlaceholder);

                labelsOfPlaceholderLinesToDisplace.put(displacementImmediateLinePlaceholder, label);
            }
        }

        // Loop through 'labelsOfPlaceholderLinesToDisplace' and recompute and replace the placeholder line with
        // the 'displacementValue' containing the correct displacement immediate
        for (Entry<Line, Label> entry : labelsOfPlaceholderLinesToDisplace.entrySet()) {
            final Line displacementImmediateLinePlaceholder = entry.getKey();
            final int lineIndex = lines.indexOf(displacementImmediateLinePlaceholder);
            final Label label = entry.getValue();

            computeLabelAddress(lines, label);
            int displacementValue = label.getAddress() - lineIndex - 1;

            Line displacementImmediateLine =
                    new Line(List.of(displacementImmediateLinePlaceholder.getLineWords().get(0),
                            Integer.toString(displacementValue)),
                            displacementImmediateLinePlaceholder.getSourceLineNumber());

            replaceLabelLine(labels, displacementImmediateLinePlaceholder, displacementImmediateLine);

            lines.remove(lineIndex);
            lines.add(lineIndex, displacementImmediateLine);
        }

        // TODO: for the above 'for' loops, there potentially can be more "equivalent displacement instruction"
        //  opportunities in the event that removing the 'movilLine' and 'moviuLine' for an arbitrary label-loading
        //  instruction causes its 'displacementValue' to become in-range for 'B[condition]'/'CALLD' instructions.

        // Now loop through all 'labelsOfMovLowerUpperImmediateLines' and compute/insert label addresses
        final int movImmediateWordIndex = 2;
        for (Entry<Entry<Line, Line>, Label> entry : labelsOfMovLowerUpperImmediateLines.entrySet()) {
            final Line movilLine = entry.getKey().getKey();
            final Line moviuLine = entry.getKey().getValue();
            final Label label = entry.getValue();

            // Disregard this 'entry' if 'movilLine' and 'moviuLine' no longer exist due to becoming their equivalent
            // displacement immediate instruction
            if (!lines.contains(movilLine) || !lines.contains(moviuLine)) {
                continue;
            }

            computeLabelAddress(lines, label);

            final String lowerLabelImmediate = "0x" + Integer.toHexString(label.getAddress() & 0xFF);
            final String upperLabelImmediate = "0x" + Integer.toHexString(label.getAddress() >> 8 & 0xFF);
            movilLine.getLineWords().set(movImmediateWordIndex, lowerLabelImmediate);
            moviuLine.getLineWords().set(movImmediateWordIndex, upperLabelImmediate);
        }

        // Print out unused labels
        Sets.difference(new HashSet<>(labels), new HashSet<>(usedLabels))
                .forEach(label -> System.err.println("Warning: Unused label: " + label.getName()));
    }

    /**
     * Replaces the {@link Label#getLine()} with <code>newLine</code>, if found in the given <code>labels</code> {@link
     * List}.
     *
     * @param labels  the {@link List} of {@link Label}s
     * @param oldLine the old {@link Line}
     * @param newLine the new {@link Line}
     */
    private void replaceLabelLine(List<Label> labels, Line oldLine, Line newLine) {
        for (Label label : labels) {
            if (label.getLine().equals(oldLine)) {
                label.setLine(newLine);
                break;
            }
        }
    }

    /**
     * Computes a {@link Label#getAddress()} (gets index of {@link Label#getLine()} in the given {@link Line}s).
     *
     * @param lines the {@link List} of assembly {@link Line}s
     * @param label the {@link Label}
     *
     * @throws AssemblyParseException thrown for {@link AssemblyParseException}s
     */
    private void computeLabelAddress(List<Line> lines, Label label) throws AssemblyParseException {
        int labelAddress = lines.indexOf(label.getLine());
        if (labelAddress == -1) {
            throw new AssemblyParseException("Cannot get address for label: " + label.getName() +
                    ". An instruction or number must come after a label.",
                    label.getLine().getSourceLineNumber());
        }
        label.setAddress(labelAddress);
    }

    /**
     * Assembles and writes output files according to given {@link Arguments}.
     *
     * @param lines the assembly {@link Line}s (must be return value from {@link #cleanAssembly(List)})
     *
     * @throws AssemblyParseException thrown for {@link AssemblyParseException}s
     * @throws IOException            thrown for {@link IOException}s
     */
    private void assembleAndWriteOutput(List<Line> lines) throws AssemblyParseException, IOException {
        // Write processed assembly lines as needed
        if (arguments.getProcessedOutputFile() != null) {
            try (FileWriter processedFileWriter = new FileWriter(arguments.getProcessedOutputFile())) {
                for (Line line : lines) {
                    String formattedLine = String.format("%-5s %-3s %s", IntStream.range(0, 3)
                            .mapToObj(index -> index < line.getLineWords().size() ? line.getLineWords().get(index) : "")
                            .toArray()).trim() + "\n";
                    processedFileWriter.write(formattedLine);
                }
            }
        }

        // Write assembled lines to binary file
        List<String> machineCodeLines = new ArrayList<>();
        for (Line line : lines) {
            List<String> lineWords = line.getLineWords();
            AbstractInstruction lineInstruction = INSTRUCTIONS_OF_MNEMONICS.get(lineWords.get(0));

            if (lineInstruction != null) { // Parse line as an instruction
                try {
                    lineInstruction.parse(lineWords);
                } catch (InstructionParseException exception) {
                    throw new AssemblyParseException(exception, line.getSourceLineNumber());
                }
                machineCodeLines.add(formatMachineCodeString(lineInstruction.assemble()));
            } else { // Try to parse line as a number
                try {
                    int number = BasedNumberParser.parseInt(lineWords.get(0));
                    machineCodeLines.add(formatMachineCodeString(number));
                } catch (NumberFormatException exception) {
                    throw new AssemblyParseException("Unknown instruction or assembly number: " +
                            String.join(" ", lineWords), line.getSourceLineNumber());
                }

                if (lineWords.size() > 1) {
                    throw new AssemblyParseException("Only one assembly number per line is allowed.",
                            line.getSourceLineNumber());
                }
            }
        }
        try (FileWriter binaryFileWriter = new FileWriter(arguments.getOutputFile())) {
            for (String machineCodeLine : machineCodeLines) {
                binaryFileWriter.write(machineCodeLine);
            }
        }

        // Append padding lines to binary file
        int linesToPad = arguments.getMaxPaddingLine() - lines.size();
        if (linesToPad > 0) {
            String paddingLine = formatMachineCodeString(arguments.getMaxPaddingLineValue());
            try (FileWriter binaryFileAppender = new FileWriter(arguments.getOutputFile(), true)) {
                for (int lineIndex = linesToPad; lineIndex < arguments.getMaxPaddingLine(); lineIndex++) {
                    binaryFileAppender.write(paddingLine);
                }
            }
        }
    }

    /**
     * Formats <code>number</code> using {@link Arguments#getNumberBaseConverter()} and {@link
     * Arguments#getNumberBasePadding()} (and upper-cases hex letters if they exist)
     *
     * @param number the number
     *
     * @return the formatted machine code {@link String}
     */
    private String formatMachineCodeString(int number) {
        String machineCodeString = arguments.getNumberBaseConverter().apply(number);
        machineCodeString = arguments.getNumberBasePadding().substring(machineCodeString.length()) + machineCodeString;
        machineCodeString = machineCodeString.toUpperCase() + "\n";
        return machineCodeString;
    }

    /**
     * Prints an {@link Exception}.
     *
     * @param exception the {@link Exception}
     */
    private void printException(Exception exception) {
        if (arguments != null && arguments.isDebug()) {
            exception.printStackTrace();
        } else {
            System.err.println(exception.getClass().getSimpleName() + ": " + exception.getMessage());
        }
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
