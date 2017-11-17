#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# TODO - make inputs reactive, so only the permissible range is possible
# TODO - the outside boxes are always red, even when they should be blue.
# TODO - try to make the whole thing faster
# TODO - add hover note about what set seed is
# TODO - make image re-size to fill horizontal space (maybe?)
# BIG TODO - when changes are made without clicking 'new card', 
#						 modify the minimum number of spaces in the existing card, if possible animate.

library(shiny)
source("../R/CodeNamesCard_functions.R")

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
         # sliderInput("ib",
         # 						"innocent by-standers:",
         # 						min = 0,
         # 						max = 25, #output$ts,
         # 						value = 13),
         textInput("ss", "set seed", value = NA, placeholder = "enter an integer"),
      	
      	# The action button causes a new card to be made, even if no inputs have changed
      	actionButton("theButton", "New Card")
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
		
		# Take a dependency on input$theButton. This will run once initially,
		# because the value changes from NULL to 0.
		input$theButton
		
		#useArgs = defaultArgs
		useArgs = list()
		
		useArgs$height = input$height
		useArgs$width = input$width
		useArgs$assassin = input$assassin
		useArgs$help = FALSE
		useArgs$ib = NULL
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

# To deploy on shiny.io
# setwd("../Shiny/")
##### remove the "../R/" from source("../R/CodeNamesCard_functions.R")
# system("cp ../R/CodeNamesCard_functions.R .")
# deployApp(appDir = getwd(), 
# 					appFiles = c("app.R", "../R/CodeNamesCard_functions.R"),
# 					appTitle="Code Names Spy Card")
##### printed response:
# Preparing to deploy application...DONE
# Uploading bundle for application: 236603...DONE
# Deploying bundle: 1080449 for application: 236603 ...
# Waiting for task: 496343021
# building: Processing bundle: 1080449
# building: Building image: 1080580
# building: Installing packages
# building: Installing files
# building: Pushing image: 1080580
# deploying: Starting instances
# rollforward: Activating new instances
# unstaging: Stopping old instances
# Application successfully deployed to https://ivoryblak.shinyapps.io/code_names_spy_card/

