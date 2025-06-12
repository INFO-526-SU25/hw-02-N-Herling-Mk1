library(ggplot2)

g1 <- ggplot() +
  annotate("text", x = 0, y = 0, label = "®", color = "red", size = 10) +
  xlim(-1, 1) +
  ylim(-1, 1) +
  theme_void()

plot(g1)