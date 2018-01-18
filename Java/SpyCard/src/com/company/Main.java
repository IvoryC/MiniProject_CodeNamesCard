package com.company;

import org.apache.commons.cli.*;

public class Main {

    public static void main(String[] args) {
        // write your code here
        Options options = makeOptions();
        System.out.println(options);

        CommandLineParser parser = new DefaultParser();
        CommandLine cmd = null;
        try {
            cmd = parser.parse( options, args);
        } catch (ParseException e) {
            e.printStackTrace();
        }

        System.out.println(cmd.getOptions());

        System.out.println("Here are the args:");
        for (String arg : args) {
            System.out.println(arg);
        }
        System.out.println("The number of rows will be: " + cmd.getOptionValue("H", "22"));
        System.out.println("Thanks!");
    }

    static private Options makeOptions() {
        Options options = new Options();
        options.addOption("H", "height", true, "number of rows in grid");
        options.addOption("W", "width", true, "number of columns in grid");
        options.addOption("a", "assassin", true, "number of assassins");
        options.addOption("i", "innocents", true, "number of innocent by-stander squares");
        options.addOption("r", "red", true, "number of red team squares");
        options.addOption("b", "blue", true, "number of blue team squares");
        options.addOption("o", "outfile", true, "file name to save image");
        options.addOption("s", "set-seed", true, "set random seed to regenerate an identical card");
        return options;
    }
}
