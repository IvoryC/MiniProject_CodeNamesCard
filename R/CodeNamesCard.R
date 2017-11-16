#!/usr/bin/env Rscript

# CodeNamesCard


library("optparse")
source("CodeNamesCard_functions.R")

main <- function(){
	
  args = getArgs()
	opt = processOptions(args)
	
	#ts = opt$width * opt$height
	
	# for developemnt, print number of 
	# total squares in grid, -h and -w
	# assassin, red, blue, by-standers
	#print(paste("total squares in grid:", ts))
	#cat(unlist(opt), sep='\n')
	for (i in 1:length(opt)){
		print(paste0(names(opt)[i],": ", opt[[i]]))
	}
	# TODO add printed statement indicating who should go first
	
	cardTemplate = assembleCard(opt)
	
	drawAndSaveCard(opt$outfile, cardTemplate)

	# Show the saved image (works on unix, not sure if this works on windows)
	system(paste("open", opt$outfile))
	
}

# functions requireing the optparse library are defined here, to minimize the library load in _functions.R
getArgs <- function(){
	option_list = list(
		h=make_option(opt_str=c("-H", "--height"), type="integer", default=NULL, 
									help="number of rows in grid"),
		w=make_option(opt_str=c("-W", "--width"), type="integer", default=NULL, 
									help="number of columns in grid"),
		a=make_option(opt_str=c("-a", "--assassin"), type="integer", 
									default=1, 
									help="number of assissins"),
		i=make_option(opt_str=c("-i", "--inocents"), type="integer", default=NULL, 
									help="number of innocent by-stander squares", dest="ib"),
		r=make_option(opt_str=c("-r", "--red"), type="integer", default=NULL, 
									help="number of red team squares"),
		b=make_option(opt_str=c("-b", "--blue"), type="integer", default=NULL, 
									help="number of blue team squares"),
		o=make_option(opt_str=c("-o", "--outfile"), type="character", 
									default="SpyMap.png", 
									help="file name to save image"),
		s=make_option(opt_str=c("-s", "--set-seed"), type="integer", default=NULL, 
									help="set random seed to regenerate an identical card", dest="ss")
	); 
	opt_parser = OptionParser(option_list=option_list)
	opt = parse_args(opt_parser)
	
	return(opt)
}


main()

