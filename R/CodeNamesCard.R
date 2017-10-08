#!/usr/bin/env Rscript

# CodeNamesCard

library("optparse")

main <- function(){
	
opt = processOptions()
	
	ts = opt$width * opt$hieght

# for developemnt, print number of 
# total squares in grid, -h and -w
# assasins, red, blue, by-standers
print(paste("total squares in grid:", ts))
#cat(unlist(opt), sep='\n')
for (i in 1:length(opt)){
	print(paste0(names(opt)[i],": ", opt[[i]]))
}

attach(opt) # so we don't have to write opt$ every time

### Assign squares in grid
slotIds = sample(x=1:ts, size=ts, replace=F)
names(slotIds) = c(rep("assasin", assasin),
											 rep("ib", ib),
											 rep("blue", blue),
											 rep("red", red))
groups = split(slotIds, f=names(slotIds))
columns = slotIds %% width +1
rows = (slotIds-1) %/% width +1

colors = c(rep("black", assasin),
					 rep("tan", ib),
					 rep("blue", blue),
					 rep("red", red))


### Make image
png(filename=opt$outfile)
par(mar=rep(1,4))
symbols(x=columns, y=rows, squares=rep(.9,ts), inches=F, bg=colors)
dev.off()

# plot Grid
# for the image size, assume that each square will be 1 cm square
# and a .2 cm gap between each row and each column, 
# and that there is a 1 cm border outside of the grid itself.

# design and draw red square image


# design and draw blue square image


# if assasins >0 design and draw black square image


# if innocent >0 design and draw tan square image

system(paste("open", opt$outfile))

}

### Functions
processOptions <- function(opt){
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
	
	# Notice that the order of handling cases matters
	# first - if both blue and red are specified
	# second - if neighter are specified 
	#     (if they were specified, this is correctly skipped)
	# last (as an else from the second) - if one is null
	#     (where we can assume that the other is NOT null)
	
	# if neither -r nor -b is null
	if (!is.null(opt$blue) & !is.null(opt$red)){
		# calculate open squares, total - assasins - red - blue
		open = ts - opt$assasin - opt$blue - opt$red
		if (open < 0) {
			stop("Not enough squares in the grid.\n")
		}
		# if -i is specified,
		# if -i == open squares ---> great
		# if -i != open squares, error message
		if ( (!is.null(opt$ib)) & (opt$ib != open) ) {
			stop("This doesn't add up.")
		}
		# if -i is null, set it equal to open squares.
		if (is.null(opt$ib)){
			opt$ib = open
		}
	}
	
	
	
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
	} else {
		
		#if exactly one of red or blue is null, 
		# assign the one that is not null to be first, the other second
		# assign second to get first - 1 squares
		if (is.null(opt$blue)){
			first="red"
			second="blue"
			opt$blue = opt$red - 1
		}
		if (is.null(opt$red)){
			first="blue"
			second="red"
			opt$red = opt$blue - 1
		}
		# Calculate open squares, total - assasins - red - blue
		open = ts - opt$assasins - opt$red - opt$blue
		#if <0, error message
		if (open < 0) {
			stop("Not enough squares in the grid.\n")
		}
		if (open == 0) {
			warning("There are no inocent by-standers on this map.\n", call.=F)
		}
		# if -i is null, set -i to open squares
		if (is.null(opt$ib)){
			opt$ib = open
		}
		# if -i is specified and -i != open squares, error message
		if ( (!is.null(opt$ib)) & (opt$ib != open)){
			stop("This doesn't add up.")
		}
	}
	return(opt)
}


main()

