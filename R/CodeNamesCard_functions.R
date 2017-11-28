### Functions for CodeNamesCard.R
# These are defined here so that the shiny app can source the functions without running main.
# This code can be used with iether the CodeNamesCard.R script or the app.R shiny interface.

library("grid")

# Take in the options given by the user (which must already be collected into a list by some parser)
# and fill in all remaining options with default values.
# Many of the defaults are set dynamically based on the constraints imposed by the user selections.
processOptions <- function(opt){ # function(opt){
	# Take arguments from the command line
	#args <- commandArgs(trailingOnly = T)
	
	# for development
	# opt
	# save("opt", file="testing.Rdata")
	
	# If -s is not null (and not an empty string), set the seed.
	if (!(is.null(opt$ss) || opt$ss=="")){
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
		# The team with more squares goes first
		opt$first = ifelse(opt$blue >= opt$red, "blue", "red")
		# if they have the same number, randomly pick one
		if (opt$blue == opt$red){
			opt$first = sample(c("blue", "red"), size=1)
		}
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


# This function determines the type for each grid square, 
# and the properties associeated with that type, such as color and symbol.
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
	
	# because the added traits in the order: assassin, ib, blue, red
	# we know that the last item in the color vector is red, and the (assassin+ib+1)th is blue.
	firstCol = ifelse(first=="blue", colors[assassin+ib+1], colors[ts])
	
	innerCol = rep(NA, ts)
	for (i in 1:ts){
		innerCol[i] = makeTransparent(colors[i], .7)
	}
	
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
											firstCol=firstCol,
											innerCol=innerCol,
											pchs=pchs)
	return(cardTemplate)
}

makeTransparent <- function(color, alpha=.5){
	matrix = t(col2rgb(color, alpha=T))
	matrix = matrix/255
	matrix[,"alpha"] = alpha
	return(rgb(red=matrix[,"red"], green=matrix[,"green"], blue=matrix[,"blue"], alpha=matrix[,"alpha"]))
}

drawAndSaveCard <- function(fname, cardTemplate){
	
	plotProperties = setPlotProperties(cardTemplate)
	
	png(filename=fname, 
			width = plotProperties$xMax, height = plotProperties$yMax, units = "in", res=100)
	drawCard(cardTemplate, plotProperties)
	dev.off()
}

# Properties for the individual grid squares are set in the assembleCard function.
# All other properties, such as overall size, border widths and colors, are specified here.
# No actions are taken here, just setting values.
# The actions using these values are handled by the draw functions, orchestrated by drawCard.
setPlotProperties <- function(cardTemplate, 
												 bg.inner = "#211F1F",
												 bg.mid = "#836E66",
												 bg.outer = "#9A8984"){
	
	suppressMessages(attach(cardTemplate))
	suppressMessages(attach(opt))
	
	# The border is everything from the edge of the outer grid squares to the edge of the card
	# because it is easiest to draw the grid squares centered at x=1 for row=1, with grid space allotment of 1,
	# there is automatically a 1/2 grid space given to the border.
	# In the example card image, it looks like the border is about 1.2 times a single grid space width.
	# Border SPaCe controls how much space is added, it should account for the sizes that are hard coded below.
	# It should allow for the 3/5 inch outer border, the 2/5 inch middle, and the 1/2 inch inner border. (.6 + .4 + .5 - .5(given)) = 1 
	bspc=1 #bspc for border space
	xMin=0
	xMax=width+1+2*bspc
	xMid=mean(c(xMin, xMax))
	yMin=0
	yMax=height+1+2*bspc
	yMid=mean(c(yMin, yMax))
	short=.2 # the short dimension of the little boxes on the border
	long=.85 
	
	# border widths
	# The outermost border is drawn by adding a rounded rectangle the same size as the entire card.
	# The width of this "border" is 1/2 the difference between the size of this rectangle and the middle one. 
	outer.sizeX = xMax
	outer.sizeY = yMax
	# The width of the outer border should be 3/5ths the width of one grid square, which is my 1 inch unit.
	# So the mid border's rectangle should be the same dimensions as the outer one, less 2 * (3/5)
	mid.sizeX = outer.sizeX - (6/5)
	mid.sizeY = outer.sizeY - (6/5)
	# The width of the middle border should be 2/5ths the width of one grid square.
	inner.sizeX = mid.sizeX - (4/5) # max(width+.2, mid.sizeX - (4/5)) # set inner.sizeX and Y so that it is never smaller than the area of the map spaces
	inner.sizeY = mid.sizeY - (4/5) # max(height+.2, mid.sizeY - (4/5))
	# distance from the middle border layer to the outer edge (xMax, yMax)
	fromEdgeSmall = (outer.sizeX - mid.sizeX)/2 
	fromEdgeBig = fromEdgeSmall + short
	
	plotProperties = list(
		bspc=bspc, 
		xMin=xMin,  xMax=xMax, xMid=xMid,
		yMin=yMin,  yMax=yMax, yMid=yMid,
		short=short, long=long, 
		bg.inner=bg.inner, bg.mid=bg.mid, bg.outer=bg.outer,
		# border widths
		outer.sizeX=outer.sizeX, outer.sizeY=outer.sizeY,
		mid.sizeX=mid.sizeX, mid.sizeY=mid.sizeY,
		inner.sizeX=inner.sizeX, inner.sizeY=inner.sizeY,
		fromEdgeSmall=fromEdgeSmall, fromEdgeBig=fromEdgeBig
	)

	return(plotProperties)
}

drawCard <- function(cardTemplate, plotProperties){
	suppressMessages(attach(cardTemplate))
	suppressMessages(attach(opt))
	suppressMessages(attach(plotProperties))
	
	### Make image
	# plot Grid
	# for the image size, assume that each square will be 1 cm square
	# and a .2 cm gap between each row and each column, 
	# and that there is a 1 cm border outside of the grid itself.
	par(mar=rep(0,4))

	# create blank plot
	grid.newpage()
	vp=viewport(x = unit(0, "in"), y = unit(0, "in"),
							width = unit(xMax, "in"), height = unit(yMax, "in"),
							default.units = "in", just = c(0,0))
	
	# draw the stylized backround and borders
	drawSpyBackground(plotProperties,vp)
	
	# draw grid squares
	drawGridSquares(cardTemplate, vp)
	
	## Add the symbols inside each box
	drawSymbols(cardTemplate, vp=vp)
	
	# draw border boxes indicating which team goes first by adding colored rectangles at the border
	drawBorderBoxes(plotProperties, vp=vp)
	
}

drawSpyBackground <- function(plotProperties, vp){
	suppressMessages(attach(plotProperties))
	# outermost border, drawn as a rectangle
	grid.roundrect(x=xMid, y=yMid, width=outer.sizeX, height=outer.sizeY, 
								 default.units="in",just="centre", 
								 r=unit(0.4, "in"),
								 gp=gpar(fill=bg.outer, col=NA), vp=vp)
	# middle border
	grid.roundrect(x=xMid, y=yMid, width=mid.sizeX, height=mid.sizeY, 
								 default.units="in",just="centre", 
								 r=unit(0.3, "in"),
								 gp=gpar(fill=bg.mid, col="black"), vp=vp)
	# inner border
	grid.roundrect(x=xMid, y=yMid, width=inner.sizeX, height=inner.sizeY, 
								 default.units="in",just="centre", 
								 r=unit(0.15, "in"),
								 gp=gpar(fill=bg.inner, col=NA), vp=vp)
	# Polygons to make the outer border appear to cut into the middle border
	gp.outer=gpar(fill=bg.outer, col=bg.outer, lwd=2.2)
	# right side
	rightX = xMid+(mid.sizeX/2) + c(0,-short, -short, 0) #c(xMid+(mid.sizeX/2), xMid+(mid.sizeX/2)-short, xMid+(mid.sizeX/2)-short, xMid+(mid.sizeX/2))
	rightY = c(bspc+1, bspc+1+short, yMax-(bspc+1+short), yMax-(bspc+1))
	grid.polygon(x=rightX, 
							 y=rightY,
							 gp=gp.outer, 
							 default.units="in", vp=vp)
	grid.lines(x=rightX, 
						 y=rightY,
						 gp=gpar(col="black", lwd=1), 
						 default.units="in", vp=vp)
	# left side
	leftX = xMid-(mid.sizeX/2) + c(0, short, short, 0) 
	#leftY = c(bspc+1, bspc+1+short, yMax-(bspc+1+short), yMax-(bspc+1)) # Y values are the same as the other side.
	grid.polygon(x=leftX, 
							 y=rightY,
							 gp=gp.outer, 
							 default.units="in", vp=vp)
	grid.lines(x=leftX, 
						 y=rightY,
						 gp=gpar(col="black", lwd=1), 
						 default.units="in", vp=vp)
	# top side
	topX = c(bspc+1, bspc+1+short, xMax-(bspc+1+short), xMax-(bspc+1))
	topY = yMid+(mid.sizeY/2) + c(0,-short, -short, 0)
	grid.polygon(x=topX, 
							 y=topY,
							 gp=gp.outer, 
							 default.units="in", vp=vp)
	grid.lines(x=topX, 
						 y=topY,
						 gp=gpar(col="black", lwd=1), 
						 default.units="in", vp=vp)
	# bottom side
	# botX = same as topX
	botY = yMid-(mid.sizeY/2) + c(0, short, short, 0)
	grid.polygon(x=topX, 
							 y=botY,
							 gp=gp.outer, 
							 default.units="in", vp=vp)
	grid.lines(x=topX, 
						 y=botY,
						 gp=gpar(col="black", lwd=1), 
						 default.units="in", vp=vp)
}

drawGridSquares <- function(cardTemplate, vp){
	# draw grid squares
	for (i in 1:ts){
		grid.roundrect(x=columns[i]+bspc, 
									 y=rows[i]+bspc, 
									 width=.95, height=.95,
									 gp=gpar(fill=colors[i], col=NA),
									 default.units="in", just="centre", vp=vp)
	}
}

drawSymbols <- function(cardTemplate, vp){
	suppressMessages(attach(cardTemplate))
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
}

drawBorderBoxes <- function(plotProperties, vp){
	# draw border boxes indicating which team goes first by adding colored rectangles at the border
	suppressMessages(attach(plotProperties))
	# Set locations and sizes
	# For all vectors use: left, top, right, bottom
	fromEdgeMid = mean(c(fromEdgeSmall,fromEdgeBig))
	locX=c(xMin+fromEdgeMid, xMid, xMax-fromEdgeMid, xMid) 
	locY=c(yMid, yMax-fromEdgeMid, yMid, yMin+fromEdgeMid) 
	bord.w=c(short, long, short, long) 
	bord.h=c(long, short, long, short) 
	# draw the boxes
	grid.rect(x=locX, y=locY,
						width=unit(bord.w,"in"), 
						height=unit(bord.h, "in"),
						default.units="in", just="centre",
						gp=gpar(fill=firstCol, col="black", lwd=1), vp=vp)
	# To get the glow effect, layer on some white (so the transparent will show), 
	# then the transparaent version of the color, then white again for a bright little core
	for (i in 1:4){ # round rect only does one at a time, so we have to use a loop.
		# first white layer
		f=.6 # scaling factor relative to the sizes above for the entire rectangle
		grid.roundrect(x=locX[i], y=locY[i], r=unit(0.05, "in"),
									 width=unit(bord.w*f,"in")[i],
									 height=unit(bord.h*f, "in")[i],
									 default.units="in", just="centre",
									 gp=gpar(fill="white", col=NA, lwd=1), vp=vp)
		# light color layer
		grid.roundrect(x=locX[i], y=locY[i], r=unit(0.05, "in"),
									 width=unit(bord.w*f,"in")[i],
									 height=unit(bord.h*f, "in")[i],
									 default.units="in", just="centre",
									 gp=gpar(fill=makeTransparent(firstCol,.7), col=NA, lwd=1), vp=vp)
		# final white layer
		f=.4
		grid.roundrect(x=locX[i], y=locY[i], r=unit(0.05, "in"),
									 width=unit(bord.w*f,"in")[i],
									 height=unit(bord.h*f, "in")[i],
									 default.units="in", just="centre",
									 gp=gpar(fill="white", col=NA, lwd=1), vp=vp)
	}
}

