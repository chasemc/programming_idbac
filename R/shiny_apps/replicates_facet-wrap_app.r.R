library(shiny)
library(dplyr)
library(ggplot2)


getAllSampleNames <- function(pool,
                              proteinOrSmall){

  #proteinOrSmall === ">" or "< "

  conn <- pool::poolCheckout(pool)

  a <- DBI::dbGetQuery(conn, glue::glue("SELECT DISTINCT Strain_ID
                                            FROM IndividualSpectra
                                            WHERE maxMass {proteinOrSmall} 6000"))
  pool::poolReturn(conn)

  a[ , 1]

}



plotOverlay_ui <- function(id) {
  ns <- NS(id)
  tagList(
    wellPanel(
    h3(id),
    plotOutput(ns("myggplot"), width = "100%", height = "1000px")
        )
  )
}

plotOverlay_server <- function(input, output, session, spec, specName) {

  output$myggplot <- renderPlot({


    spec %>%
      filter(mass < 15000) %>%
      ggplot()  +
      geom_line(aes(mass, intensity)) +
      theme_bw() +
      ggtitle(specName) +
      facet_wrap(~spectrum, ncol = 1L)


  })
}








# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("IDBac QC"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(

      IDBacApp::databaseSelector_UI("databaseSelector"),
      uiOutput("strainSelector")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      uiOutput("module_uis")
    )
  )
)









# Define server logic required to draw a histogram
server <- function(input, output) {

  sqlDirectory <- reactiveValues(sqlDirectory = IDBacApp::findIdbacHome())
  availableDatabases <- reactiveValues(db = NULL)

  observe({
    samps <- tools::file_path_sans_ext(list.files(sqlDirectory$sqlDirectory,
                                                  pattern = ".sqlite",
                                                  full.names = FALSE,
                                                  recursive = FALSE)
    )
    if (length(samps) == 0) {
      availableDatabases$db <- NULL
    } else {
      availableDatabases$db <- samps
    }


  })

  selectedDB <- callModule(IDBacApp::databaseSelector_server,
                           "databaseSelector",
                           h3Label = tags$h4("Select an experiment ", br(), "to work with:"),
                           availableExperiments = availableDatabases,
                           sqlDirectory = sqlDirectory)


  output$strainSelector <- renderUI({
    checkboxGroupInput("selectStrain",
                       label = "Select Strain",
                       choices = c("All", strainIds()))
  })

  strainIds <- reactive({
    req(selectedDB$userDBCon())
    getAllSampleNames(selectedDB$userDBCon(),
                      proteinOrSmall = ">")

  })



  selected_labs <- reactive({
    req(input$selectStrain)
    req(!is.null(input$selectStrain))
    labs <- input$selectStrain

    if ("All" %in% labs) {
      labs <- strainIds()
    }
    labs
  })

  spectra <- reactive({
    req(input$selectStrain)
    req(!is.null(input$selectStrain))
    con <- pool::poolCheckout(selectedDB$userDBCon())

    spec <- lapply(selected_labs(), function(x){

      spec <- IDBacApp::mquantSpecFromSQL(pool = selectedDB$userDBCon(),
                                          sampleID = x,
                                          protein = TRUE,
                                          smallmol = FALSE)



      spec <- lapply(seq_along(spec),
                     function(i){

                       spec <- cbind.data.frame(mass = spec[[i]]@mass,
                                                intensity = spec[[i]]@intensity,
                                                spectrum = i)
                     })
      if (length(spec) > 1) {

        spec <- do.call(rbind, spec)
      }
      spec

    })

    pool::poolReturn(con)

    spec

  })



  observeEvent(input$selectStrain, {
    req(!is.null(input$selectStrain))
    req(spectra())


    output$module_uis <- renderUI({

      lapply(seq_along(selected_labs()),
             function(n) {
               return(plotOverlay_ui(selected_labs()[[n]]))
             })
    })

    lapply(seq_along(selected_labs()), function(i){
      callModule(plotOverlay_server,
                 selected_labs()[[i]],
                 spec = spectra()[[i]],
                 specName = selected_labs()[[i]])
    })




  })






}

# Run the application
shinyApp(ui = ui, server = server)
