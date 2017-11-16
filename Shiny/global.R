

library(shiny)


#source("../R/CodeNamesCard.R")
# 
defaultArgs = list(height=5,
						width=5,
						assassin=1,
						help=FALSE,
						ib=NULL,
						red=4,
						blue=7,
						outfile="SpyMap.png")
# 
# doStuff <- function(input=session$input){
# 	for (nam in names(input)){
# 		args[nam] = input$`nam`
# 	}
# 	
# 	opt = processOptions(args)
# 	cardTemplate = assembleCard(opt)
# 	
# 	return(cardTemplate)
# 	
# }