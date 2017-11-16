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

# defaultArgs is defined in global.R

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
      							value = defaultArgs$height),
      	numericInput("width",
      							"Columns in grid:",
      							width = 125,
      							min = 2, max = 20, step=1,
      							value = defaultArgs$width),
      	sliderInput("assassin",
      							"Number of assassins:",
      							min = 0,
      							max = 25, #output$ts,
      							value = defaultArgs$assassin),
         sliderInput("red",
         						"red team spaces:",
         						min = 2,
         						max = 20,
         						value = defaultArgs$red),#TODO make this a random selection based on output
         sliderInput("blue",
         						"blue team spaces:",
         						min = 2,
         						max = 20,
         						value = defaultArgs$blue), #TODO make this a random selection based on output
         sliderInput("ib",
         						"innocent by-standers:",
         						min = 0,
         						max = 25, #output$ts,
         						value = defaultArgs$ib),
         textInput("ss", "set seed", value = NA, placeholder = "enter an integer"),
      	submitButton("New Card")
      ),
      
      # Code names game spy card
      mainPanel(
         imageOutput("SpyMap")
      )
   )
)

# Define server logic required to design and draw the card
server <- function(input, output) {

	output$SpyMap <- renderImage({

		useArgs = defaultArgs
		
		useArgs$height = input$height
		useArgs$width = input$width
		useArgs$assassin = input$assassin
		useArgs$help = input$help
		useArgs$ib = input$ib
		useArgs$red = input$red
		useArgs$blue = input$blue

		opt = processOptions(useArgs)
		cardTemplate = assembleCard(opt)
		
		outfile <- tempfile(fileext='.png')
		drawAndSaveCard(outfile, cardTemplate)

				list(src = outfile,
				 alt = "This is alternate text")
	})
}

# Run the application 
shinyApp(ui = ui, server = server)

