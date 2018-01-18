package com.company;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Option;
import java.util.Random;

import java.util.HashMap;

public class CodeNamesCard {

    // in case we need one
    public Random rand = new Random();

    public HashMap<String, Integer> opt;



    CodeNamesCard(CommandLine cmd){
        HashMap<String, Integer> opt = new HashMap<String, Integer>();

        Option[] processedOpts = cmd.getOptions();
        for (Option po : processedOpts){
//            System.out.println(po.getOpt());
//            System.out.println(po.getValue());
            opt.put(po.getOpt(), Integer.parseInt(po.getValue()));
        }
        this.opt = opt;

        //If -s is not null (and not an empty string), set the seed.
        if (opt.containsKey("s")){
            rand.setSeed(opt.get("s"));
        }
        //TODO: if s is not specified, pick a random int and use that---so any card can be recreated.



        
    }
}
