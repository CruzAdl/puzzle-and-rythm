library(shiny)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  
  # Hidden Rhythm Guide Toggle (Bottom Right Corner)
  absolutePanel(
    bottom = 0, right = 0, fixed = TRUE, width = "50px", height = "50px",
    checkboxInput("aid_toggle", label = NULL, value = FALSE),
    style = "opacity: 0; z-index: 1000;" # Completely invisible but clickable
  ),

  # Visual aid element
  div(id = "pulse", style = "width: 20px; height: 20px; background: limegreen; border-radius: 50%; margin: 0 auto; opacity: 0.2; transition: opacity 0.1s;"),
  
  h3(textOutput("timer"), style = "text-align: center; color: blue;"),
  verbatimTextOutput("info"),
  plotOutput("plot", height = "500px", width = "100%", click = "plot_click")
)

server <- function(input, output) {
  v <- reactiveValues(r = 1, col = "red", active = TRUE, done_time = NULL, 
                      w = c(1, 1, 1, 1), last_clk = Sys.time(), msg = "Random") 
  
  # Rhythm guide pulse
  observe({
    req(input$aid_toggle)
    invalidateLater(1000)
    runjs("document.getElementById('pulse').style.opacity = '1'; 
           setTimeout(() => { document.getElementById('pulse').style.opacity = '0.2'; }, 200);")
  })
  
  observeEvent(input$plot_click, {
    if (!v$active) return()
    
    now <- Sys.time()
    diff <- as.numeric(now - v$last_clk)
    v$last_clk <- now
    
    # Rhythm logic (0.85s - 1.15s window)
    if (diff >= 0.85 && diff <= 1.15) {
      v$r <- v$r + 2
      v$msg <- "Rhythm Bonus!"
    } else {
      # Random weights: [Small Grow, Big Grow, Shrink, Nothing]
      change <- sample(c(1.5, 4, -2, 0), 1, prob = v$w)
      v$r <- max(1, v$r + change)
      v$msg <- "Random"
    }
    
    # Completion logic
    if (v$r >= 50) {
      v$col <- "blue"; v$active <- FALSE; v$done_time <- Sys.time()
      
      delay(sample(1000:3000, 1), {
        v$r <- 1; v$col <- "red"; v$active <- TRUE; v$done_time <- NULL;
        v$w <- runif(4) # New random personality
      })
    }
  })
  
  output$info <- renderText({ paste("Mode:", v$msg, "| Current Weights:", paste(round(v$w, 2), collapse = ", ")) })
  
  output$timer <- renderText({
    if (is.null(v$done_time)) return("")
    invalidateLater(100)
    paste("Resetting in...", round(difftime(Sys.time(), v$done_time, units = "secs"), 1))
  })
  
  output$plot <- renderPlot({
    symbols(0, 0, circles = v$r, inches = FALSE, xlim = c(-50, 50), ylim = c(-50, 50), bg = v$col)
  })
}

shinyApp(ui, server)