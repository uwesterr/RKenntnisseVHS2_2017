library(shiny)
library(ggplot2)

linkedScatterUI <- function(id) { # define the linkedScatterUI as item with two plots in a fluidRow
  ns <- NS(id)
  
  fluidRow(
    column(6, plotOutput(ns("plot1"), brush = ns("brush"))),
    column(6, plotOutput(ns("plot2"), brush = ns("brush")))
  )
}

linkedScatter <- function(input, output, session, data, left, right) {
  # Yields the data frame "dataWithSelection" with an additional column "selected_"
  # that indicates whether that observation is brushed
  dataWithSelection <- reactive({
    # returns df with extra column "selected_"
    brushedPoints(data(), input$brush, allRows = TRUE) 

  })
  
  output$plot1 <- renderPlot({
    scatterPlot(dataWithSelection(), left())
  })
  
  output$plot2 <- renderPlot({
    scatterPlot(dataWithSelection(), right())
  })
  
  return(dataWithSelection)
}

scatterPlot <- function(data, cols) {
  ggplot(data, aes_string(x = cols[1], y = cols[2])) +
    geom_point(aes(color = selected_, shape = selected_)) +
    scale_color_manual(values = c("black", "#66D65C"), guide = FALSE)
}