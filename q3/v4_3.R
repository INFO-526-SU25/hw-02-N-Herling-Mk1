pacman::p_load(here)
source(here("q2/setup.R"))

library(ggplot2)
library(ggforce)  # for geom_circle()

# Define circles for the Target logo
circles <- data.frame(
  x0 = 0, y0 = 0,
  r = c(1, 0.7),
  fill = c("red", "white")
)

# Plot the logo + "TARGET" + ®
g1 <- ggplot() +
  # Draw the rings
  geom_circle(data = circles, aes(x0 = x0, y0 = y0, r = r, fill = fill), color = NA) + 
  # Solid center circle
  geom_point(aes(x = 0, y = 0), shape = 21, size = 30, fill = "red") +  
  # Add the word 'TARGET' below the logo
  annotate("text", x = 0, y = -1.4, label = "TARGET", color = "red", size = 10, fontface = "bold") +
  # Add the ® symbol offset to the bottom right of 'TARGET'
  annotate("text", x = 0.60, y = -1.50, label = "®", color = "red", size = 8) +
  # Style the plot
  scale_fill_identity() +
  coord_fixed() +
  theme_void()

plot(g1)
