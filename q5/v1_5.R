library(plotly)
library(palmerpenguins)
library(magick)
library(reticulate)

# Ensure Kaleido is installed in Python environment (run once)
# reticulate::py_install("kaleido", pip = TRUE)

# Clean penguin data
penguins_clean <- na.omit(penguins)

# Normalize helper function
normalize <- function(x) (x - min(x)) / (max(x) - min(x))

# Normalize penguin variables
x_norm <- normalize(penguins_clean$bill_length_mm)
y_norm <- normalize(penguins_clean$flipper_length_mm)
z_norm <- normalize(penguins_clean$body_mass_g)

# Convert to spherical coordinates
theta <- 2 * pi * x_norm
phi <- pi * y_norm
r <- 1 + 0.3 * (z_norm - 0.5)

# Convert spherical to Cartesian coordinates
x_sphere <- r * sin(phi) * cos(theta)
y_sphere <- r * sin(phi) * sin(theta)
z_sphere <- r * cos(phi)

# Base 3D scatter plot
base_plot <- plot_ly() %>%
  add_trace(
    type = "scatter3d",
    mode = "markers",
    x = x_sphere,
    y = y_sphere,
    z = z_sphere,
    color = penguins_clean$species,
    colors = c("darkorange", "dodgerblue", "forestgreen"),
    marker = list(size = 4)
  ) %>%
  layout(
    scene = list(
      xaxis = list(title = "X", range = c(-1.5, 1.5)),
      yaxis = list(title = "Y", range = c(-1.5, 1.5)),
      zaxis = list(title = "Z", range = c(-1.5, 1.5)),
      aspectmode = "cube"
    ),
    title = "Penguin Data on Rotating Sphere"
  )

# Create folder for frames
dir.create("frames", showWarnings = FALSE)

# Number of frames in animation
n_frames <- 60
angles <- seq(0, 2 * pi, length.out = n_frames)

# Loop to generate and save each frame using Kaleido with progress tracker
for (i in seq_along(angles)) {
  angle <- angles[i]
  cam <- list(eye = list(x = 2 * cos(angle), y = 2 * sin(angle), z = 0.7))
  
  # Update plot with dynamic camera movement
  frame_plot <- base_plot %>%
    layout(scene = list(camera = cam))
  
  # Generate filename for frame
  filename <- sprintf("frames/frame_%03d.png", i)
  
  # Save image using Kaleido
  frame_plot %>%
    plotly::save_image(filename, format = "png", width = 800, height = 600)
  
  # Progress tracker
  progress <- round((i / n_frames) * 100, 1)
  message("Saved frame ", i, "/", n_frames, " (", progress, "% done)")
}

# Read frames and create GIF with magick
img_files <- list.files("frames", full.names = TRUE, pattern = "frame_\\d+\\.png$")
imgs <- image_read(img_files)
anim <- image_animate(imgs, fps = 20)
image_write(anim, "rotating_penguins_sphere.gif")

message("🎉 GIF saved as rotating_penguins_sphere.gif")
