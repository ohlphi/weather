library(shiny)
library(rCharts)
library(plyr)
library(dplyr)
library(RColorBrewer)
library(png)
library(reshape2)
source("helper.R")



storm <- read.csv("data//finalstorm.csv", header = TRUE, sep = ",")

shinyServer(
  function(input, output) {
    
    output$text1 <- renderText({ 
      paste(input$var, "in", input$range)
    })
    
    output$text2 <- renderText({
      paste("Table to check Weather impact per state and year")
    })
    
    output$image <- renderImage({
      if (input$var == "Crop Damage" | input$var == "Property Damage" | input$var == "Crop & Property Damage") {
        return(list(
          src = "images/damage.png",
          contentType = "image/png",
          height = 130,
          width = 400,
          alt = "Damage"
        ))
      } else if (input$var == "Fatalities" | input$var == "Injuries" | input$var == "Fatalities & Injuries") {
        return(list(
          src = "images/public.png",
          filetype = "image/png",
          height = 130,
          width = 400,
          alt = "Public"
        ))
      }
      
    }, deleteFile = FALSE)
    
    output$mymap <- renderChart({
      data <- switch(input$var,
                   "Crop Damage" = "Crop",
                   "Property Damage" = "Property",
                   "Crop & Property Damage" = "Crop.Property",
                   "Fatalities" = "Fatalities",
                   "Injuries" = "Injuries",
                   "Fatalities & Injuries" = "Fatalities.Injuries")
    
      df <- subset(storm, variable == data & Year == input$range)
    
      #df<- subset(storm, variable == "Fatalities.Injuries")
      df <- mutate(df, type = ifelse(variable == "Crop" | variable == "Property" | variable == "Crop.Property", 1, 2))
    
      df <- mutate(df, fillKey = ifelse(type == 1 & value <= 1000000, "0-1 M$",
                                    ifelse(type == 1 & value <= 10000000, "1-10 M$",
                                    ifelse(type == 1 & value <= 100000000, "10-100 M$",
                                    ifelse(type == 1 & value <= 1000000000, "100-1,000 M$",
                                    ifelse(type == 1 & value >= 1000000000, ">1,000 M$",
                                    ifelse(type == 2 & value <= 10, "0-10",
                                    ifelse(type == 2 & value <= 50, "11-50",
                                    ifelse(type == 2 & value <= 100, "51-100",
                                    ifelse(type == 2 & value <= 500, "101-500", ">500"))))))))))
    
      df$fillKey <- if(sum(df$type)/length(df$type)==1){
        df$fillKey <- ordered(df$fillKey, levels = c("0-1 M$",
                                                   "1-10 M$",
                                                   "10-100 M$",
                                                   "100-1,000 M$",
                                                   ">1,000 M$"))
      } else {
        df$fillKey <- ordered(df$fillKey, levels = c("0-10",
                                                   "11-50",
                                                   "51-100",
                                                   "101-500",
                                                   ">500"))
      }
    
      df$State <- as.character(df$State)
    
    
    
      mymap <- ichoropleth2(value~State, pal="PuRd", data = df)
      mymap$addParams(dom = 'mymap')
      return(mymap)
    })
    
    output$ex_state <- renderPrint({
      if("All" %in% input$showstate == TRUE) {
        state.abb
      } else {
        input$showstate
      }
      #str(input$showstate)
    })
    output$ex_damage <- renderPrint({
      if("All" %in% input$showdamage == TRUE) {
        c("Crop Damage", "Property Damage", "Crop & Property Damage", "Fatalities", "Injuries", "Fatalities & Injuries")
      } else {
        input$showdamage
      }
    })
    output$ex_year <- renderPrint({
      paste("Year", input$yearrange[1], "to", input$yearrange[2])
    })
    
    output$table <- renderDataTable({
      if("All" %in% input$showstate == TRUE) {
        state1 <- state.abb
      } else {
        state1 <- input$showstate
      }
      
      if("All" %in% input$showdamage == TRUE) {
        impact1 <- c("Crop", "Property", "Crop.Property", "Fatalities", "Injuries", "Fatalities.Injuries")
      } else {
        impact1 <- input$showdamage
      }
      
      
      table1 <- subset(storm, State %in% state1 & variable %in% impact1 & Year >= input$yearrange[1] & Year <= input$yearrange[2])
      table1 <- select(table1, State, Year, variable, value)
      names(table1) <- c("State", "Year", "Impact", "Value")
      table1 <- dcast(table1, State+Year ~ Impact)
 
      return(table1)
    })
    
    table2 <- reactive({
      if("All" %in% input$showstate == TRUE) {
        state1 <- state.abb
      } else {
        state1 <- input$showstate
      }
      
      if("All" %in% input$showdamage == TRUE) {
        impact1 <- c("Crop", "Property", "Crop.Property", "Fatalities", "Injuries", "Fatalities.Injuries")
      } else {
        impact1 <- input$showdamage
      }
      
      
      table1 <- subset(storm, State %in% state1 & variable %in% impact1 & Year >= input$yearrange[1] & Year <= input$yearrange[2])
      table1 <- select(table1, State, Year, variable, value)
      names(table1) <- c("State", "Year", "Impact", "Value")
      table1 <- dcast(table1, State+Year ~ Impact)
      return(table1)
    })
    
    output$downloaddata <- downloadHandler(
      filename = function() {"stormdata.csv"},
    content = function(file) {
      write.csv(table2(), file, row.names = FALSE)
    })

  }
)