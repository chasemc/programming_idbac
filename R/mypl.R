library(shiny)

plotOverlay_ui <- function(id) {
  ns <- NS(id)
  tagList(
    wellPanel(
      h3(id),



      plotOutput(ns("mine"))
    )
  )
}

plotOverlay_server <- function(input, output, session, outside) {




  output$mine <- renderPlot({
    plot(mtcars)
  })


}


ui <- fluidPage(
  column(2,
         sliderInput("numMods","# Modules", 1, 10, 3)),
  column(10,
         uiOutput("module_uis"))
)


server <- function(input, output) {

  modd <- reactiveValues()

  observeEvent(input$numMods,{
    output$module_uis <- renderUI({ lapply(1:input$numMods, function(n) {
      return(plotOverlay_ui(n))})
    })
  })

  observe({
    modd <- reactiveValues()
    for (i in 1:input$numMods){
      modd[[as.character(i)]] <-  callModule(plotOverlay_server,
                                             as.character(i),
                                             outside = reactiveValuesToList(modd))
    }
  })



}

shinyApp(ui, server)
