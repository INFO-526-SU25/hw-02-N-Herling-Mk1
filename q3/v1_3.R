pacman::p_load(here)
source(here("q1/setup.R"))

# Define circles: center (0,0) and different radii
circles <- data.frame(
  x0 = 0, y0 = 0,  # Center of all circles
  r = c(1, 0.7),   # Outer rings
  fill = c("red", "white")  # Ring colors
)

# Plot
g1 <- ggplot() +
  geom_circle(data = circles, aes(x0 = x0, y0 = y0, r = r, fill = fill), color = NA) + 
  geom_point(aes(x = 0, y = 0), shape = 21, size = 30, fill = "red") +  # Solid center
  scale_fill_identity() +
  coord_fixed() +
  theme_void()

plot(g1)