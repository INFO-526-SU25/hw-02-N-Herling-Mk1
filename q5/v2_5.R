pacman::p_load(here)
source(here("q1/setup.R"))

library(ggplot2)
library(ggforce)

# Target red
target_red <- "#e82118"

# Define rings
circles <- data.frame(
  x0 = 0, y0 = 0,
  r = c(1, 0.7),
  fill = c(target_red, "white")
)

# Plot
g1 <- ggplot() +
  # Outer red and white rings
  geom_circle(data = circles, aes(x0 = x0, y0 = y0, r = r, fill = fill), color = NA) +
  # Inner solid red circle
  geom_circle(aes(x0 = 0, y0 = 0, r = 0.3), fill = target_red, color = NA) +
  # Add 'TARGET' text
  annotate("text", x = 0, y = -1.4, label = "TARGET", color = target_red, size = 10, fontface = "bold") +
  # Add ® symbol
  annotate("text", x = 0.6, y = -1.52, label = "®", color = target_red, size = 8) +
  # Aesthetic adjustments
  scale_fill_identity() +
  coord_fixed() +
  theme_void()

# Display
plot(g1)
