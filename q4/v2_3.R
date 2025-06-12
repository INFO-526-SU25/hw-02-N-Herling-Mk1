pacman::p_load(here)
source(here("q2/setup.R"))

library(shiny)
library(ggplot2)
library(ggforce)

# Define Target red
target_red <- "#e82118"

# Define rings
circles <- data.frame(
  x0 = 0, y0 = 0,
  r = c(1, 0.7),
  fill = c(target_red, "white")
)

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      #logo_plot {
        opacity: 0;
        transition: opacity 2s ease-in-out;
      }
      #logo_plot.shown {
        opacity: 1;
      }
    "))
  ),
  titlePanel("Target Logo Reveal"),
  actionButton("reveal_btn", "Press me"),
  tags$br(), tags$br(),
  tags$div(
    id = "logo_plot_container",
    plotOutput("logo_plot", height = "400px")
  )
)

# Define Server
server <- function(input, output, session) {
  # Generate plot once
  target_plot <- ggplot() +
    geom_circle(data = circles, aes(x0 = x0, y0 = y0, r = r, fill = fill), color = NA) +
    geom_circle(aes(x0 = 0, y0 = 0, r = 0.3), fill = target_red, color = NA) +
    annotate("text", x = 0, y = -1.4, label = "TARGET", color = target_red, size = 10, fontface = "bold") +
    annotate("text", x = 0.6, y = -1.52, label = "®", color = target_red, size = 8) +
    scale_fill_identity() +
    coord_fixed() +
    theme_void()
  
  output$logo_plot <- renderPlot({
    input$reveal_btn  # reactively trigger rendering
    target_plot
  })
  
  # Trigger fade-in via JavaScript
  observeEvent(input$reveal_btn, {
    session$sendCustomMessage(type = "fadeInLogo", message = list())
  })
  
  # JS to toggle opacity class
  shiny::addCustomMessageHandler("fadeInLogo", function(message) {
    shinyjs::runjs("document.getElementById('logo_plot').classList.add('shown');")
  })
}

# Run the App
shinyApp(ui, server)
