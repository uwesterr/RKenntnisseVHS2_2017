library(shiny)

source("linked_scatter.R")

ui <- fixedPage(
  h2("Module example"),
  linkedScatterUI("scatters"),   # linkedScatterUI is defined in "linked_scatter.R"
  linkedScatterUI("scatters1"),  # each time linkedScatterUI is called with different id
  textOutput("summary")
)

server <- function(input, output, session) {
  df <- callModule(linkedScatter, "scatters", reactive(mpg), # linkedScatter is defined in "linked_scatter.R"
                   left = reactive(c("cty", "hwy")),
                   right = reactive(c("drv", "hwy"))
  )
  df <- callModule(linkedScatter, "scatters1", reactive(mpg), # each time linkedScatter is called with different id
                   left = reactive(c("cyl", "hwy")),  # parameters are passed as reactive expression
                   right = reactive(c("displ", "hwy"))
  )  
  output$summary <- renderText({
    sprintf("%d observation(s) selected", nrow(dplyr::filter(df(), selected_)))
  })
}

shinyApp(ui, server)