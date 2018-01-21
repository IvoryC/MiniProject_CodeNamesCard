package com.company;

import org.apache.commons.cli.*;

public class Main {
    static Options options;
    static CommandLineParser parser;
    static CommandLine cmd = null;;

    public static void main(String[] args) throws Exception {
        // write your code here
        options = makeOptions();

        parser = new DefaultParser();

        try {
            cmd = parser.parse( options, args);
        } catch (ParseException e) {
            e.printStackTrace();
            showHelp(options);
        }

        System.out.println("Here are the args:");
        for (String arg : args) {
            System.out.println(arg);
        }
        System.out.println("The number of rows will be: " + cmd.getOptionValue("H", "22"));
        System.out.println("Thanks!");

        if (cmd.hasOption("h")){
            showHelp(options);
        }


        // Use the command line options to creat a Spy Card
        CodeNamesCard cnc = new CodeNamesCard(cmd);
//        System.out.println(cnc.opt);
//        System.out.println(cnc.stringOptions);
        System.out.println(cnc);

        // TODO: grab the outfile option here, it doesn't belong in the CodeNamesCard object.

        //TODO: move the set seed stuff to main to be passed to CardLayout


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
        options.addOption("h", "help", false, "print help message");
        return options;
    }

    static private void showHelp(Options ops){
        // automatically generate the help statement
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp( "java -jar CodeNamesCard.jar [-W,H,-a,-i,-r,-b,-o,-s,-h]", ops);
    }
}
