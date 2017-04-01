library(shiny)
library(gapminder)
library(tidyverse)
library(magrittr)
library(plotly)


# Creat models first

gapminder <- gapminder %>% mutate(year1950 = year -1950)

# Structure data such that a model per country can be generated
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

# define structure of user interface (ui) first
ui <- fluidPage(title = "Life expectancy explorer shiny app",
                navlistPanel(widths = c(2,10),
                             tabPanel("Life expectancy", 
                                      wellPanel(
                                        h1("Find countries within slected R^2 range"),
                                        code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
         geom_line(aes( alpha = 1/3))  +
         facet_wrap(~country)")
                                      ),
                                      
                                      wellPanel( # create panel with slider with default values
                                        sliderInput(inputId = "rsqSliderValue",
                                                    label = "R^2",
                                                    value = c(0,0.25), min = 0, max = 1, dragRange = TRUE, step = 0.25,
                                                    animate = animationOptions(loop = TRUE, interval = 3000, pauseButton = "Press to pause", playButton = "Press to start playing"))
                                      ),
                                      # add plot to page
                                      plotlyOutput(outputId = "LifeExp")
                             ), 
                             # define next panel
                             tabPanel("Select data and country", 
                                      wellPanel(
                                        h1("Find countries within slected R^2 range"),
                                        code("models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% ggplot(aes(year, lifeExp)) +
                  geom_line(aes( alpha = 1/3))  +
                  facet_wrap(~country)")
                                      ),
                                      wellPanel( # create well panel with three select lists
                                        column(3, offset = 1, selectInput('countrySelect', 'Country', as.character(unlist(c(models[, "country"]))),selected = "Germany")),
                                        column(3,selectInput('xcol', 'X Variable', names(unnest(models,data)), selected = "year")),
                                        column(3, selectInput('ycol', 'Y Variable', names(unnest(models,data)), selected = "pop")),
                                        br(),
                                        hr()
                                      ),
                                      # add plot to page
                                      plotlyOutput(outputId = "GDP") 
                                      
                             ),
                             tabPanel("Run bubble", 
                                      h3(("Here you can build a bubble chart like Hans did in his TED talk")),
                                      hr()
                             )
                )
                
)

server <- function(input, output) {
  
  output$LifeExp <- renderPlotly(# the ID after $ links the sever function output to the ui item
    models %>% filter((rsq < input$rsqSliderValue[2] & rsq > input$rsqSliderValue[1]))  %>% 
      #input$rsqSliderValue[1] is a reactive value from inputSlider "rsqSliderValue"
      unnest(rsq)  %>% top_n(10,rsq) %>% unnest(data) %>% 
      ggplot(aes(year, lifeExp)) + geom_line(aes( colour = continent))  +
      facet_wrap(~country) + theme(axis.text.x = element_text(angle=45))
  )
  output$GDP <- renderPlotly( # note the "get" command to get the input of the select lists which is not 
    # necessary for the filter command
    models %>% filter(country == input$countrySelect)  %>% unnest (data) %>% 
      ggplot(aes(x=get(input$xcol), y=get(input$ycol))) + geom_line())
}

shinyApp(ui = ui, server = server)