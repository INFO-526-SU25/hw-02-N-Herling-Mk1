# Install packages if not already installed
# install.packages(c("ggplot2", "gganimate", "dplyr", "gifski"))

library(ggplot2)
library(gganimate)
library(dplyr)
library(tibble)

# --- Settings ---
n_frames <- 30
circle_start <- 20

# --- Diagonal Line Data ---
diag_data <- tibble(
  frame = 1:n_frames,
  x = 0,
  y = 0,
  xend = seq(0, 1, length.out = n_frames),
  yend = seq(0, 1, length.out = n_frames)
)

# --- Circle Data ---
circle_base <- tibble(
  angle = seq(0, 2 * pi, length.out = 100),
  x = 0.5 + 0.5 * cos(angle),
  y = 0.5 + 0.5 * sin(angle)
)

# Expand circle over frames from frame 20 to n_frames
circle_data <- bind_rows(lapply(circle_start:n_frames, function(f) {
  circle_base %>% mutate(frame = f)
}))

# --- Build Animation ---
p <- ggplot() +
  # Square
  geom_rect(aes(xmin = 0, xmax = 1, ymin = 0, ymax = 1),
            fill = "white", color = "black") +
  
  # Growing Diagonal
  geom_segment(data = diag_data, aes(x = x, y = y, xend = xend, yend = yend),
               color = "blue", size = 1.5) +
  
  # Circle (appears starting at frame 20)
  geom_path(data = circle_data, aes(x = x, y = y, group = frame),
            color = "red", size = 1.2) +
  
  coord_fixed() +
  theme_void() +
  labs(title = "Frame: {current_frame}") +
  transition_manual(frame)

# --- Render and Save ---
anim <- animate(p, nframes = n_frames, fps = 10, width = 400, height = 400, renderer = gifski_renderer())
anim_save("square_circle_diagonal.gif", animation = anim)
