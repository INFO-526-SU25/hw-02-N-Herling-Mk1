pacman::p_load(here)
source(here("q1/setup.R"))

#library(dsbox)
data(package = "dsbox")

# Load the dataset
data("edibnb")

# Quick look at the structure
glimpse(edibnb)

#library(ggridges)
#?geom_density_ridges


# 1. Calculate median review scores by neighborhood
median_scores <- edibnb |>
  group_by(neighbourhood) |>
  summarize(median_score = median(review_scores_rating, na.rm = TRUE)) |>
  arrange(median_score)

# 2. Reorder neighbourhood factor by median score
edibnb <- edibnb |>
  mutate(neighbourhood = factor(neighbourhood, levels = median_scores$neighbourhood))

# 3. Plot ridge plot with geom_density_ridges()
g1 <- ggplot(edibnb, aes(x = review_scores_rating, y = neighbourhood, fill = neighbourhood)) +
  geom_density_ridges(alpha = 0.7, scale = 1.2) +
  scale_x_continuous(name = "Review Scores Rating", limits = c(0, 150)) +
  labs(
    title = "Distribution of Airbnb Review Scores by Edinburgh Neighborhood",
    y = "Neighborhood (ordered by median review score)",
    fill = "Neighborhood"
  ) +
  theme_ridges() +
  theme(legend.position = "none")

plot(g1)