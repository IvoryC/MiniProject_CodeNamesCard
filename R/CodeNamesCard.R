#!/usr/bin/env Rscript

# CodeNamesCard

library("optparse")
library("grid")

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
	
	drawCard(cardTemplate)

	# Show the saved image (works on unix, not sure if this works on windows)
	system(paste("open", opt$outfile))
	
}

### Functions

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

processOptions <- function(opt){ # function(opt){
	# Take arguments from the command line
	#args <- commandArgs(trailingOnly = T)
	
	# for development
	opt
	save("opt", file="testing.Rdata")
	
	# If -s is not null, set the seed.
	if (!is.null(opt$ss)){
		set.seed(opt$ss)
	}
	
	# if both height and width are null, set both to 5.
	# if only one is NULL, set it to match the other.
	if (is.null(opt$height) & is.null(opt$width)){
		opt$height=5
		opt$width=5
	} else {
		if (is.null(opt$height)) {
			opt$height = opt$width
		}
		if (is.null(opt$width)) {
			opt$width = opt$height
		}
	}
	
	# Calculate total squares
	opt$ts = opt$width * opt$height
	
	# Notice that the order of handling cases matters
	# first - if both blue and red are specified
	# second - if neighter are specified 
	#     (if they were specified, this is correctly skipped)
	# last - if either one is null 
	#     (which must be exactly one, since both values would have 
	#     been set by now if both or neither had been specified.)
	#     so we can assume that the other is NOT null
	
	# if neither -r nor -b is null
	if (!is.null(opt$blue) & !is.null(opt$red)){
		# calculate open squares, total - assassin - red - blue
		openSq = opt$ts - opt$assassin - opt$blue - opt$red
		if (openSq < 0) {
			stop("Not enough squares in the grid.\n")
		}
		# if -i is specified,
		# if -i == open squares ---> great
		# if -i != open squares, error message
		if ( (!is.null(opt$ib)) && (opt$ib != openSq) ) {
			stop("This doesn't add up.")
		}
		# if -i is null, set it equal to open squares.
		if (is.null(opt$ib)){
			opt$ib = openSq
		}
	}
	
	
	
	# if both are null, 
	if (is.null(opt$blue) & is.null(opt$red)){
		#if -i is null, calculate -i as 25% of total squares
		if (is.null(opt$ib)){
			opt$ib = floor(opt$ts * .25)
		}
		# Calculate open squares
		openSq = opt$ts - opt$assassin - opt$ib
		#if open squares < 3 then print error message
		if (openSq < 3){
			stop("Not enough squares in the grid.\n")
		}
		## Make sure open squares is odd
		# One team has to go first, the other team has to have 
		# a -1 addvantage to make up for it.
		# If the number of open squares is even, 
		# make it odd by adding or subtracting one innocent
		if (openSq %% 2 == 0){
			if (opt$ib > openSq/2){
				opt$ib = opt$ib - 1
				openSq = openSq + 1
			} else {
				opt$ib = opt$ib + 1
				openSq = openSq - 1
			}
		}
		# randomly pick red or blue to be "first", the other second
		sample = sample(c("blue", "red"), size=2, replace = F)
		opt$first = sample[1]
		opt$second = sample[2]
		# assign first to get open squares /2 rounded up
		opt[[opt$first]] = ceiling(openSq/2)
		# assign second to get open squares /2 roudned down
		opt[[opt$second]] = floor(openSq/2)
	}
	
	#if exactly one of red or blue is null, 
	# assign the one that is not null to be first, the other second
	# assign second to get first - 1 squares
	if (is.null(opt$blue) | is.null(opt$red)){
		if (is.null(opt$blue)){
			opt$first="red"
			opt$second="blue"
			opt$blue = opt$red - 1
		} else { # in other words if (is.null(opt$red)){
			opt$first="blue"
			opt$second="red"
			opt$red = opt$blue - 1
		}
		# Calculate open squares
		openSq = opt$ts - opt$assassin - opt$red - opt$blue
		#if <0, error message
		if (openSq < 0) {
			stop("Not enough squares in the grid.\n")
		}
		if (openSq == 0) {
			warning("There are no inocent by-standers on this map.\n", call.=F)
		}
		# if -i is null, set -i to open squares
		if (is.null(opt$ib)){
			opt$ib = openSq
		}
		# if -i is specified and -i != open squares, error message
		if ( (!is.null(opt$ib)) && (opt$ib != openSq)){
			stop("This doesn't add up.")
		}
	}
	return(opt)
}


assembleCard <- function(opt){
  suppressMessages(attach(opt)) # so we don't have to write opt$ every time
  
  ### Assign squares in grid
  slotIds = sample(x=1:ts, size=ts, replace=F)
  names(slotIds) = c(rep("assassin", assassin),
                     rep("ib", ib),
                     rep("blue", blue),
                     rep("red", red))
  groups = split(slotIds, f=names(slotIds))
  columns = slotIds %% width +1
  rows = (slotIds-1) %/% width +1
  
  colors = c(rep("#5B5852", assassin), #dark gray
             rep("#EFEEC7", ib), # tan
             rep("#017ED7", blue), # blue
             rep("#FE5148", red)) # red
  
  pchs = c(rep(4, assassin), # X
           rep(NA, ib), # no symbol
           rep(21, blue), # circle
           rep(23, red)) # diamond
  
  cardTemplate = list(opt=opt,
                      slotIds=slotIds,
                      groups=groups,
                      columns=columns,
                      rows=rows,
                      colors=colors,
                      pchs=pchs)
  return(cardTemplate)
}

drawCard <- function(cardTemplate,  
                     bg.inner = "#211F1F",
                     bg.mid = "#836E66",
                     bg.outer = "#9A8984"){
  suppressMessages(attach(cardTemplate))
  suppressMessages(attach(opt))
  
  ### Make image
  # plot Grid
  # for the image size, assume that each square will be 1 cm square
  # and a .2 cm gap between each row and each column, 
  # and that there is a 1 cm border outside of the grid itself.
  png(filename=opt$outfile)
  par(mar=rep(0,4))
  
  bspc=.5 #bspc for border space
  xMin=0
  xMax=width+1+2*bspc
  xMid=mean(c(xMin, xMax))
  yMin=0
  yMax=height+1+2*bspc
  yMid=mean(c(yMin, yMax))
  
  # create blank plot
  grid.newpage()
  #plot(rows,columns, xlim=c(xMin,xMax), ylim=c(yMin,yMax),xaxt="n", yaxt="n", type="n")
  vp=viewport(x = unit(-.18, "in"), y = unit(-.18, "in"),
              width = unit(xMax, "in"), height = unit(yMax, "in"),
              default.units = "in", just = c(0,0))
  grid.roundrect(x=xMid, y=yMid, width=xMax*.94, height=yMax*.94, 
                 default.units="in",just="centre", 
                 r=unit(0.4, "in"),
                 gp=gpar(fill=bg.outer, col=NA), vp=vp)
  grid.roundrect(x=xMid, y=yMid, width=xMax*.85, height=yMax*.85, 
                 default.units="in",just="centre", 
                 r=unit(0.3, "in"),
                 gp=gpar(fill=bg.mid, col=NA), vp=vp)
  grid.roundrect(x=xMid, y=yMid, width=xMax*.77, height=yMax*.77, 
                 default.units="in",just="centre", 
                 r=unit(0.15, "in"),
                 gp=gpar(fill=bg.inner, col=NA), vp=vp)
  #polygon()
  # draw grid squares
  # symbols(x=columns+bspc, y=rows+bspc,
  #         xlim=c(xMin,xMax), ylim=c(yMin,yMax),
  #         squares=rep(.9,ts), inches=T, bg=colors,
  #         xaxt="n", yaxt="n")
  innerCol = rep(NA, ts)
  for (i in 1:ts){
    grid.roundrect(x=columns[i]+bspc, 
                   y=rows[i]+bspc, 
                   width=.95, height=.95,
                   gp=gpar(fill=colors[i], col=NA),
                   default.units="in", just="centre", vp=vp)
    innerCol[i] = makeTransparent(colors[i], .7)
  }
  
  ## Add the symbols inside each box
  # add white glow layer
  grid.points(x=columns+bspc, y=rows+bspc, size=unit(3.8, "char"),
              pch=pchs, gp=gpar(fill="white", col="white", lwd=11),
              default.units="in", vp=vp)
  grid.points(x=columns+bspc, y=rows+bspc, size=unit(3.8, "char"),
              pch=pchs, gp=gpar(fill=NA, col=innerCol, lwd=11),
              default.units="in", vp=vp)
  grid.points(x=columns+bspc, y=rows+bspc, size=unit(3.8, "char"),
              pch=pchs, gp=gpar(fill=NA, col="white", lwd=2), 
              default.units="in", vp=vp)
  # add black outline and inner fill
  grid.points(x=columns+bspc, y=rows+bspc, size=unit(3.7, "char"),
              pch=pchs, gp=gpar(fill=colors, col="black", lwd=.6),
              default.units="in", vp=vp)
  # the assassin X needs some extra help. Recall that assassin is the first group
  asns = 1:assassin
  grid.points(x=columns[asns]+bspc, y=rows[asns]+bspc, size=unit(3.7, "char"),
              pch=pchs[asns], gp=gpar(fill=colors, col="black", lwd=5),
              default.units="in", vp=vp)
  # draw border
  # # indicate which team goes first by adding colored rectangles at the border
  # locX=c(xMin, xMid, xMax, xMid) #left, top, right, bottom
  # locY=c(yMid, yMax, yMid, yMin) #left, top, right, bottom
  # short=.2
  # long=.5
  # # symbols(x=locX, y=locY, xpd=T, add=T, inches=T, bg=c(first),
  # #         rectangles=matrix(nrow=4, ncol=2, 
  # #                           data=cbind(c(short, long, short, long), 
  # #                                      c(long, short, long, short)))
  # # )
  dev.off()
  
}

makeTransparent <- function(color, alpha=.5){
  matrix = t(col2rgb(color, alpha=T))
  matrix = matrix/255
  matrix[,"alpha"] = alpha
  return(rgb(red=matrix[,"red"], green=matrix[,"green"], blue=matrix[,"blue"], alpha=matrix[,"alpha"]))
}


main()

