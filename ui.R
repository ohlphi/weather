library(shiny)
library(rCharts)

shinyUI(fluidPage(
  titlePanel("Weather Data USA"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Storms and other severe weather events can cause both public health 
               and economic problems for communities and municipalities. Below
                you can find information about the economic as well as human impact 
               of storm events in the United States, between 1950-2011"),
      
      selectInput("var", 
                  label = h4("Select what impact to observe"),
                  choices = c("Crop Damage", 
                              "Property Damage",
                              "Crop & Property Damage",
                              "Fatalities",
                              "Injuries",
                              "Fatalities & Injuries"),
                  selected = "Crop & Property Damage"),
      
      
      sliderInput("range", 
                  label = "Select year or click on 'play' to see animation:", sep = "",
                  min = 1950, max = 2011, value = 1950, step = 1, locale = 'us', animate = TRUE),
      
      helpText("You can also view the data in a table. Select States, Weather 
               impact and time span you are interested in. When done, the data can be downloaded"),
      
      selectizeInput("showstate", "Select state:", choices = c("All", state.abb), 
                     multiple = TRUE, select = "All"),
      selectizeInput("showdamage", "Select impact:", choices = c("All" = "All",
                                                                 "Crop Damage" = "Crop",
                                                                 "Property Damage" = "Property",
                                                                 "Crop & Property Damage" = "Crop.Property",
                                                                 "Fatalities" = "Fatalities",
                                                                 "Injuries" = "Injuries",
                                                                 "Fatalities & Injuries" = "Fatalities.Injuries"),
                     multiple = TRUE,
                     select = "Crop.Property"),
      sliderInput("yearrange",
                  label = "Select year range:", sep = "",
                  min = 1950, max = 2011, value = c(1950,2011)),
      downloadButton("downloaddata", "Download the data")
    ),
    
    mainPanel(textOutput("text1"),
              tags$head(tags$style("#text1{font-size: 20px;
                                   font-weight: bold;
                                   text-transform: uppercase;}")),
              showOutput("mymap", "datamaps"),
              imageOutput("image", height = 150),
              br(),
              textOutput("text2"),
              tags$head(tags$style("#text2{font-size: 20px;
                                   font-weight: bold;
                                   text-transform: uppercase;}")),
#               verbatimTextOutput("ex_state"),
#               verbatimTextOutput("ex_damage"),
#               verbatimTextOutput("ex_year"),
              dataTableOutput("table"))
  )
))