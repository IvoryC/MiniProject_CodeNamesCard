#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source("../R/CodeNamesCard_functions.R")
output = list()
output$ts = 25

# Define UI
ui <- fluidPage(
   
   # Application title
   titlePanel("Code Names Spy Card"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
      	
      	numericInput("height",
      							"Rows in grid:",
      							width = 125,
      							min = 2, max = 20, step=1,
      							value = 5),
      	numericInput("width",
      							"Columns in grid:",
      							width = 125,
      							min = 2, max = 20, step=1,
      							value = 5),
      	sliderInput("assassin",
      							"Number of assassins:",
      							min = 0,
      							max = 25, #output$ts,
      							value = 1),
         sliderInput("red",
         						"red team spaces:",
         						min = 2,
         						max = 20,
         						value = 5),#TODO make this a random selection based on output
         sliderInput("blue",
         						"blue team spaces:",
         						min = 2,
         						max = 20,
         						value = 6), #TODO make this a random selection based on output
         sliderInput("ib",
         						"innocent by-standers:",
         						min = 0,
         						max = 25, #output$ts,
         						value = 13),
         textInput("ss", "set seed", value = NA, placeholder = "enter an integer")
      ),
      
      # Code names game spy card
      mainPanel(
         imageOutput("SpyMap"),
         textOutput("inputObject")
      )
   )
)

# Define server logic required to design and draw the card
server <- function(input, output) {
	
	# for (nam in names(input)){
	# 	args[nam] = input$`nam`
	# }
	# a = input$red
	

	# opt = processOptions(args)
	# cardTemplate = assembleCard(opt)
	#cardTemplate = doStuff()
	
	args = list(height=5,
							width=5,
							assassin=1,
							help=FALSE,
							ib=13,
							red=5,
							blue=6,
							outfile="SpyMap.png")
	

	output$SpyMap <- renderImage({

		args$height = input$height
		args$width = input$width
		args$assassin = input$assassin
		args$help = input$help
		args$ib = input$ib
		args$red = input$red
		args$blue = input$blue

		opt = processOptions(args)
		cardTemplate = assembleCard(opt)
		
		outfile <- tempfile(fileext='.png')
		drawAndSaveCard(outfile, cardTemplate)
		#drawCard(cardTemplate)
		list(src = outfile,
				 alt = "This is alternate text")
		#plot(1:10, 1:10)
	})
	
	output$inputObject <- renderText({
		nam="red"
		#paste(unlist(input[nam]), collapse=" ")
		#as.character(input$`nam`)
		input$red
		})
}

# Run the application 
shinyApp(ui = ui, server = server)

