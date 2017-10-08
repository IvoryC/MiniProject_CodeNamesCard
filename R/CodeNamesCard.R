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
							help="number of innocent by-stander squares"),
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

# If either -h or -w is NULL, 
# if both hieght and width are null, set both to 5.
# if only one is NULL, set it to match the other.

# Calculate total squares
# Calculate open squares

# if both are null, 
	#if -i is null, calculate -i as 25% of total squares
	#if i + 3 < open squares then print error message
		# else update open squares
	## Make sure open squares is odd
	# if open squares mod 2 == 0 # if the number of open squares is even
		# if -i is >= open squares / 2, subtract one from -i and add 1 to open squares
			# else, add 1 to -i and subtract one from open squares
	# randomly pick red or blue to be "first", the other second
	# assign first to get open squares /2 rounded up
	# assign second to get open squares /2 roudned down
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






