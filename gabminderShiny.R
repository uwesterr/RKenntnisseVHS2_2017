library(shiny)
library(gapminder)
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(broom)
library(purrr)
library(magrittr)

ui <- fluidPage(title = "Life expectancy explorer shiny app",
  navlistPanel(
    tabPanel("Life expectancy", 
  wellPanel(
    h1("Find countries within slected R^2 range"),
    code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
         geom_line(aes( alpha = 1/3))  +
         facet_wrap(~country)"),
    br(),
    hr()

  ),

  wellPanel(
    sliderInput(inputId = "rsqSliderValue",
                label = "R^2",
                value = c(0,0.25), min = 0, max = 1, dragRange = TRUE, step = 0.25)
  ),
  
  plotOutput("LifeExp")
    ),
  tabPanel("GDP per cap", 
           wellPanel(
             h1("Find countries within slected R^2 range"),
             code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
                  geom_line(aes( alpha = 1/3))  +
                  facet_wrap(~country)"),
             br(),
             hr()
             ),
          wellPanel( 
          column(3, offset = 1, selectInput('countrySelect', 'Country', as.character(unlist(c(models[, "country"]))),selected = "Germany")),
           column(3,selectInput('xcol', 'X Variable', names(unnest(models,data)), selected = "year")),
           column(3, selectInput('ycol', 'Y Variable', names(unnest(models,data)), selected = "pop")),
          br(),
          hr()
          ),
          
          plotOutput("GDP") 
           
           )
)
  
)

server <- function(input, output) {
  
  output$LifeExp <- renderPlot(
    
    models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
      geom_line(aes( colour = continent))  +
      facet_wrap(~country)
    
  )
 
  output$GDP <- renderPlot(
    
    models %>% filter(country == input$countrySelect)  %>% unnest (data) %>% ggplot(aes(x=get(input$xcol), y=get(input$ycol))) + geom_line()
  )
   

  
}
  
shinyApp(ui = ui, server = server)