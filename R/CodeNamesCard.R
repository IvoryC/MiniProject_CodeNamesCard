#!/usr/bin/env Rscript

# CodeNamesCard

library("optparse")

# Take arguments from the command line
#args <- commandArgs(trailingOnly = T)
option_list = list(
	make_option(opt_str=c("-h", "--hieght"), type="integer", default=NULL, 
							help="number of rows in grid"),
	make_option(opt_str=c("-w", "--width"), type="integer", default=NULL, 
							help="number of columns in grid"),
	make_option(opt_str=c("-a", "--assasin"), type="integer", 
							default=1, 
							help="number of assisins"),
	make_option(opt_str=c("-i", "--inocents"), type="integer", default=NULL, 
							help="number of innocent by-stander squares", dest="ib"),
	make_option(opt_str=c("-r", "--red"), type="integer", default=NULL, 
							help="number of red team squares"),
	make_option(opt_str=c("-b", "--blue"), type="integer", default=NULL, 
							help="number of blue team squares"),
	make_option(opt_str=c("-o", "--outfile"), type="character", 
							default="SpyMap.png", 
							help="file name to save image"),
	make_option(opt_str=c("-s", "--set-seed"), type="integer", default=NULL, 
							help="file name to save image", dest="ss")
); 
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

# for development
opt
save("opt", file="testing.Rdata")

# If -s is not null, set the seed.
if (!is.null(opt$ss)){
	set.seed(opt$ss)
}

# if both hieght and width are null, set both to 5.
# if only one is NULL, set it to match the other.
if (is.null(opt$hieght) & is.null(opt$width)){
	opt$hieght=5
	opt$width=5
} else {
	if (is.null(opt$hieght)) {
		opt$hieght = opt$width
	}
	if (is.null(opt$width)) {
		opt$width = opt$hieght
	}
}

# Calculate total squares
ts = opt$width * opt$hieght


# if both are null, 
if (is.null(opt$blue) & is.null(opt$red)){
	#if -i is null, calculate -i as 25% of total squares
	if (is.null(opt$ib)){
		opt$ib = floor(ts * .25)
	}
	# Calculate open squares
	open = ts - opt$assasin - opt$ib
	#if open squares < 3 then print error message
	if (open < 3){
		stop("Not enough squares in the grid.\n")
	}
	## Make sure open squares is odd
	# One team has to go first, the other team has to have 
	# a -1 addvantage to make up for it.
	# If the number of open squares is even, 
	# make it odd by adding or subtracting one innocent
	if (open %% 2 == 0){
		if (opt$ib > open/2){
			opt$ib = opt$ib - 1
			open = open + 1
		} else {
			opt$ib = opt$ib + 1
			open = open - 1
		}
	}
	# randomly pick red or blue to be "first", the other second
	sample = sample(c("blue", "red"), size=2, replace = F)
	first = sample[1]
	second = sample[2]
	# assign first to get open squares /2 rounded up
	opt[[first]] = ceiling(open/2)
	# assign second to get open squares /2 roudned down
	opt[[second]] = floor(open/2)
}
#if exactly one of red or blue is null, 
	# assign the one that is not null to be first, the other second
	# assign second to get first - 1 squares
	# Calculate open squares, total - assasins - red - blue; if <0, error message
	# if -i is null, set -i to open squares
	# if -i is specified, 
		# if -i != open squares, error message

# if neither -r nor -b is null
	# calculate open squares, total - assasins - red - blue
	# if -i is specified,
		# if -i == open squares ---> great
		# if -i != open squares, error message
	# if -i is null, set it equal to open squares.


# for developemnt, print number of 
# total squares in grid, -h and -w
# assasins, red, blue, by-standers

### Assign squares in grid

# assign squares to grid locaitons, random


### Make image

# plot Grid
# for the image size, assume that each square will be 1 cm square
# and a .2 cm gap between each row and each column, 
# and that there is a 1 cm border outside of the grid itself.

# design and draw red square image


# design and draw blue square image


# if assasins >0 design and draw black square image


# if innocent >0 design and draw tan square image






