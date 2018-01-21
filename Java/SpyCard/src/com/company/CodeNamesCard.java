package com.company;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Option;

import java.util.Random;

import java.util.HashMap;
import java.lang.Math;

public class CodeNamesCard {

    // in case we need one
//    public Random rand = new Random();
    public HashMap<String, Integer> opt;
    public HashMap<String, String> stringOptions;
    private int height;
    private int width;
    private int totalSquares;
    private int assassin;
    private int inocents;
    private int red;
    private int blue;
    private String first;
    private String second;


    public int getHeight() {
        return height;
    }

    public int getWidth() {
        return width;
    }

    public int getTotalSquares() {
        return totalSquares;
    }

    public int getAssassin() {
        return assassin;
    }

    public int getInocents() {
        return inocents;
    }

    public int getRed() {
        return red;
    }

    public int getBlue() {
        return blue;
    }

    public String getFirst() {
        return first;
    }

    public String getSecond() {
        return second;
    }

    CodeNamesCard(CommandLine cmd) throws Exception {
        Random rand = new Random();
        String[] rb = {"r", "b"};

        /*TODO: instead of making these HashMaps,
        just take the options directly from the commandLine object and set the fields.
        Then refactor to query the fields, not the HashMaps,
        And remove the bit at the bottom that transfers the values from the HashMaps to the fields.
         */
        HashMap<String, Integer> opt = new HashMap<String, Integer>();
        HashMap<String, String> stringOpt = new HashMap<String, String>();

        Option[] processedOpts = cmd.getOptions();
        for (Option po : processedOpts) {
//            System.out.println(po.getOpt());
//            System.out.println(po.getValue());
            opt.put(po.getOpt(), Integer.parseInt(po.getValue()));
        }

        // defaults - if it doesn't have a value, give it this value
        opt.putIfAbsent("a", 1);
        //stringOpt.putIfAbsent("o", "SpyMap.png");


        //If -s is not null (and not an empty string), set the seed.
        if (opt.containsKey("s")) {
            rand.setSeed(opt.get("s"));
        }
        //TODO: if s is not specified, pick a random int and use that---so any card can be recreated.
        //TODO: move the set seed stuff to main to be passed to CardLayout

        // if both height and width are absent, set both to 5.
        // if only one is absent, set it to match the other.
        // if both are specified, great!--do nothing.
        if (!opt.containsKey("H") && !opt.containsKey("W")) {
            opt.put("H", 5);
            opt.put("W", 5);
        } else {
            if (!opt.containsKey("H")) {
                opt.put("H", opt.get("W"));
            }
            if (!opt.containsKey("W")) {
                opt.put("W", opt.get("H"));
            }
        }

        // Calculate total squares
        opt.put("ts", (opt.get("H") * opt.get("W")));

        // Set the number of red and blue squares
        /*
        Notice that the order of handling cases matters
	    first - if both blue and red are specified
        second - if neighter are specified
	        (if they were specified, this is correctly skipped)
	    last - if either one is absent
	        (which must be exactly one, since both values would have
	        been set by now if both or neither had been specified.)
	        so we can assume that the other is NOT absent
         */

        // if neither -r nor -b is absent // ie, if both are specified
        if (opt.containsKey("b") && opt.containsKey("r")) {
            // Here, we assume that both b and r are specified.
            // the team with more squares goes first
            stringOpt.putIfAbsent("first", (opt.get("b") > opt.get("r")) ? "b" : "r");
            // if both teams have the same number, choose randomly
            //TODO: test this
            if (opt.get("b").equals(opt.get("r"))) {
                //String[] rb = {"r", "b"};
                stringOpt.putIfAbsent("first", rb[rand.nextInt(1)]);
            }
            // calculate open squares, total - assassin - red - blue
            // this should never be less than 0.
            opt.put("openSq", opt.get("ts") - opt.get("a") - opt.get("r") - opt.get("b"));
            if (opt.get("openSq") < 0) {
                throw new java.lang.Error("Not enough squares in the grid.");
            }
            // if i is also specified AND its equal to open squares --> great!
            // if i is also specified AND its not equal to open squares, then the user has tied a knot.
            if (opt.containsKey("i") && !opt.get("i").equals(opt.get("openSq"))) {
                throw new java.lang.Error("This doesn't add up.");
            }
            // if i is not specified, set it equal to open squares
            if (!opt.containsKey("i")) {
                opt.put("i", opt.get("openSq"));
            }
            //end the assumption that both b and r are specified.
        }

        // if both are absent
        if (!opt.containsKey("b") && !opt.containsKey("r")) {
            // we assume that both are absent
            // if -i is also absent, calculate i as 25% of total squares
            opt.putIfAbsent("i", (int) Math.floor(opt.get("ts") * .25));
            // calculate open squares as total - assassin - i
            opt.put("openSq", opt.get("ts") - opt.get("a") - opt.get("i"));
            // if open squares is less than 3, then you don't have room for one blue, red and assassin.
            if (opt.get("openSq") < 3) {
                throw new java.lang.Error("Not enough squares in the grid.");
            }
            /* Make sure open squares is odd
		    One team has to go first, the other team has to have
		    a -1 addvantage to make up for it.
		    If the number of open squares is even,
		    make it odd by adding or subtracting one innocent
		    */
            if (opt.get("openSq") % 2 == 0) { //if open squares is even
                if (opt.get("i") > opt.get("openSq") / 2) {
                    //take one from innocent by-standars and give it to open squares
                    opt.put("i", opt.get("i") - 1);
                    opt.put("openSq", opt.get("i") + 1);
                } else {
                    opt.put("i", opt.get("i") + 1);
                    opt.put("openSq", opt.get("openSq") - 1);
                }
            }
            // randomly pick red or blue to be "first", the other second
            int rint = rand.nextInt(2);
            stringOpt.put("first", rb[rint]);
            // make the other one second
            stringOpt.put("second", stringOpt.get("first").equals("r") ? "b" : "r");
            // assign 'first' to get open squares/2 rounded up
            opt.put(stringOpt.get("first"), (int) Math.floor(opt.get("openSq") / 2)+1 ); //not sure why ceil didn't work
            // assign 'second' to get open squares/2 rounded down
            opt.put(stringOpt.get("second"), (int) Math.floor(opt.get("openSq") / 2));
            // end the assumption that both red and blue are absent
        }

        // if exactly one is absent
        if (!opt.containsKey("r") | !opt.containsKey("b")){
            // Here we assume that one but not the other was specified
            // assign the one that is not null to be first, the other second
            // assign the second one to get first - 1 squares
            if (!opt.containsKey("b")){
                stringOpt.put("first", "r");
                stringOpt.put("second", "b");
                opt.put("b", opt.get("r") - 1);
            }else{ //ie, if blue is specified and red is not
                stringOpt.put("first", "b");
                stringOpt.put("second", "r");
                opt.put("r", opt.get("b") - 1);
            }
            // calculate open squares; this should not be less than 0
            opt.put("openSq", opt.get("ts") - opt.get("a") - opt.get("r") - opt.get("b"));
            if (opt.get("openSq") < 0) {
                throw new java.lang.Error("Not enough squares in the grid.");
            }
            if (opt.get("openSq") == 0){
                throw new java.lang.Exception("There are no inocent by-standers on this map.");
            }
            // if i is absent, set it equal to open squares
            opt.putIfAbsent("i", opt.get("openSq"));
            // if i is specified and it is not equal to open squares, that's bad
            if (opt.containsKey("i") && !opt.get("i").equals(opt.get("openSq"))) {
                throw new java.lang.Error("This doesn't add up.");
            }
        // end assumption that one but not the other was specified
        }

//        this.opt = opt;
//        this.stringOptions = stringOpt;
        this.height = opt.get("H");
        this.width = opt.get("W");
        this.totalSquares = opt.get("ts");
        this.assassin = opt.get("a");
        this.inocents = opt.get("i");
        this.red = opt.get("r");
        this.blue = opt.get("b");
        this.first = stringOpt.get("first");
        this.second = stringOpt.get("second");

    }

    @Override
    public String toString() {
        return "CodeNamesCard{" +
                "height=" + height +
                ", width=" + width +
                ", total squares=" + totalSquares +
                ", assassin=" + assassin +
                ", inocents=" + inocents +
                ", red=" + red +
                ", blue=" + blue +
                ", first='" + first + '\'' +
                ", second='" + second + '\'' +
                '}';
    }
}
