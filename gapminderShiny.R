library(shiny)
library(gapminder)
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(broom)
library(purrr)
library(magrittr)
library(plotly)


# Creat first the models

gapminder <- gapminder %>% mutate(year1950 = year -1950)
# Nested data -------------------------------------------------------------

by_country <- gapminder  %>%
  group_by(continent, country) %>%
  nest()
# Fit models --------------------------------------------------------------

country_model <- function(df){
  lm(lifeExp  ~  year1950, data=df)  
}

models <- by_country %>%
  mutate(
    model = map(data, country_model)
  )

models <- models %>%
  mutate(
    glance  = map(model, broom::glance),
    rsq     = glance %>% map_dbl("r.squared"),
    tidy    = map(model, broom::tidy),
    augment = map(model, broom::augment)
  )


ui <- fluidPage(title = "Life expectancy explorer shiny app",
                navlistPanel(widths = c(2,10),
                             tabPanel("Life expectancy", 
                                      wellPanel(
                                        h1("Find countries within slected R^2 range"),
                                        code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
         geom_line(aes( alpha = 1/3))  +
         facet_wrap(~country)")

                                        
                                      ),
                                      
                                      wellPanel(
                                        sliderInput(inputId = "rsqSliderValue",
                                                    label = "R^2",
                                                    value = c(0,0.25), min = 0, max = 1, dragRange = TRUE, step = 0.25,
                                                    animate = animationOptions(loop = TRUE, interval = 3000, pauseButton = "Press to pause", playButton = "Press to start playing"))
                                      ),
                                      
                                      plotlyOutput("LifeExp")
                             ),
                             tabPanel("Select data and country", 
                                      wellPanel(
                                        h1("Find countries within slected R^2 range"),
                                        code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
                  geom_line(aes( alpha = 1/3))  +
                  facet_wrap(~country)")
                                      ),
                                      wellPanel( 
                                        column(3, offset = 1, selectInput('countrySelect', 'Country', as.character(unlist(c(models[, "country"]))),selected = "Germany")),
                                        column(3,selectInput('xcol', 'X Variable', names(unnest(models,data)), selected = "year")),
                                        column(3, selectInput('ycol', 'Y Variable', names(unnest(models,data)), selected = "pop")),
                                        br(),
                                        hr()
                                      ),
                                      
                                      plotlyOutput("GDP") 
                                      
                             ),
                             tabPanel("Run bubble", 
                                      hr()
                             )
                )
                
)

server <- function(input, output) {
  
  output$LifeExp <- renderPlotly(
    models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% 
      unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% 
      ggplot(aes(year, lifeExp)) + geom_line(aes( colour = continent))  +
      facet_wrap(~country) + theme(axis.text.x = element_text(angle=45))
  )
  
  output$GDP <- renderPlotly(
    models %>% filter(country == input$countrySelect)  %>% unnest (data) %>% 
      ggplot(aes(x=get(input$xcol), y=get(input$ycol))) + geom_line()  )
}

shinyApp(ui = ui, server = server)