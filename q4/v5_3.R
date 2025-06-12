pacman::p_load(here)
source(here("q2/setup.R"))


library(shiny)

ui <- fluidPage(
  tags$h3("Three-State Toggle Button"),
  
  # Button to press
  actionButton("toggle_btn", "Press Me"),
  
  # Div to change color
  tags$div(
    id = "color_box",
    style = "width: 100px; height: 100px; background-color: black; margin-top: 20px;"
  ),
  
  # JavaScript to update the div color based on R input
  tags$script(HTML("
    Shiny.addCustomMessageHandler('updateColor', function(color) {
      document.getElementById('color_box').style.backgroundColor = color;
    });
  "))
)

server <- function(input, output, session) {
  # Track the current state (0 = black, 1 = green, 2 = red)
  color_state <- reactiveVal(0)
  
  observeEvent(input$toggle_btn, {
    # Cycle the state
    new_state <- (color_state() + 1) %% 3
    color_state(new_state)
    
    # Map state to color
    color <- switch(
      as.character(new_state),
      "0" = "black",
      "1" = "green",
      "2" = "red"
    )
    
    # Send color to the frontend
    session$sendCustomMessage("updateColor", color)
  })
}

shinyApp(ui, server)
