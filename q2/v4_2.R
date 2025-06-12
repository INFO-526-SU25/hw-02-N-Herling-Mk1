pacman::p_load(here)
source(here("q2/setup.R"))

library(tidyverse)
library(janitor)
library(here)
library(scales)

# Load and combine data
list_of_files <- fs::dir_ls(path = "data", regexp = "Foreign Connected PAC")

pac <- read_csv(list_of_files, id = "year") |> 
  clean_names() |>
  mutate(year = str_extract(year, "\\d{4}(?=\\.csv$)") |> as.integer()) |>
  separate(country_of_origin_parent_company,
           into = c("country", "parent_company"),
           sep = "/", 
           fill = "right", 
           extra = "merge") |>
  mutate(across(c(dems, repubs), ~ as.numeric(str_replace_all(., "[\\$,]", "")))) |>
  select(year, pac_name_affiliate, country, parent_company, dems, repubs)

# Summarize totals by year for UK only
yearly_totals <- pac |>
  filter(country == "UK") |>
  pivot_longer(cols = c(dems, repubs), names_to = "party", values_to = "amount") |>
  filter(!is.na(amount)) |>
  group_by(year, party) |>
  summarise(amount = sum(amount), .groups = "drop")

# Plot
g2a <- ggplot(yearly_totals, aes(x = year, y = amount, color = party)) +
  geom_line(size = 1.2) +     # Keep line only
  # geom_point(size = 2)      # Removed points
  
  # Removed geom_text() for labels (still commented out)
  # geom_text(aes(label = scales::dollar(amount, scale = 1e-6, suffix = "M")), 
  #           vjust = -0.5, size = 3.5, show.legend = FALSE) +
  
  scale_y_continuous(
    name = "Total amount",
    labels = label_dollar(scale = 1e-6, suffix = "M")
  ) +
  
  scale_x_continuous(
    name = "Year",
    breaks = scales::pretty_breaks()
  ) +
  
  scale_color_manual(
    values = c("dems" = "blue", "repubs" = "red"),
    labels = c("Democrats", "Republicans"),
    name = NULL
  ) +
  
  labs(title = "Contributions to US political parties from UK-connected PACs") +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    
    # Axis titles: tweak so they stay visible
    legend.position = c(0.9, 0.15),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 0),
    
    legend.justification = c("right", "bottom"),
    legend.background = element_rect(fill = scales::alpha("white", 0.8), color = NA),
    legend.box.background = element_rect(color = "black"),
    legend.box.margin = margin(6, 6, 6, 6)
  )

print(g2a)
