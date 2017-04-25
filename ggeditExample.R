#devtools::install_github('metrumresearchgroup/ggedit',subdir='ggedit')
# source
# https://www.r-bloggers.com/ggedit-0-1-1-shiny-module-to-interactvely-edit-ggplots-within-shiny-applications/

library(ggedit)
library(shinyAce)
server = function(input, output,session) {
  p1=ggplot(iris,aes(x=Sepal.Length,y=Sepal.Width,colour=Species))+geom_point()
  p2=ggplot(iris,aes(x=Sepal.Length,y=Sepal.Width,colour=Species))+geom_line()+geom_point()
  p3=list(p1=p1,p2=p2)
  output$p=renderPlot({p1})
  
  outp1=callModule(ggEdit,'pOut1',obj=reactive(list(p1=p1)))
  outp2=callModule(ggEdit,'pOut2',obj=reactive(p3))
  
  output$x1=renderUI({
    layerTxt=outp1()$UpdatedLayerCalls$p1[[1]]
    aceEditor(outputId = 'layerAce',value=layerTxt,
              mode = 'r', theme = 'chrome',
              height = '100px', fontSize = 12,wordWrap = T)
  })
  
  output$x2=renderUI({
    themeTxt=outp1()$UpdatedThemeCalls$p1
    aceEditor(outputId = 'themeAce',value=themeTxt,
              mode = 'r', theme = 'chrome',
              height = '100px', fontSize = 12,wordWrap = T)
  })
}

ui=fluidPage(
  conditionalPanel("input.tbPanel=='tab2'",
                   sidebarPanel(uiOutput('x1'),uiOutput('x2'))),
  mainPanel(
    tabsetPanel(id = 'tbPanel',
                tabPanel('renderPlot/plotOutput',value = 'tab1',plotOutput('p')),
                tabPanel('ggEdit/ggEditUI',value = 'tab2',ggEditUI('pOut1')),
                tabPanel('ggEdit/ggEditUI with lists of plots',value = 'tab3',ggEditUI('pOut2'))
    )))
shinyApp(ui, server)