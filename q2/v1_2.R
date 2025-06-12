pacman::p_load(here)
source(here("q1/setup.R"))

library(fs)
library(readr)
library(janitor)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)
library(scales)

# ==================
# Load and Clean Data
# ==================

list_of_files <- fs::dir_ls(path = "data", regexp = "Foreign Connected PAC")

pac <- read_csv(list_of_files, id = "year") |> 
  clean_names() |>
  
  # Extract year from filename
  mutate(year = str_extract(year, "\\d{4}(?=\\.csv$)") |> as.integer()) |>
  
  # Split 'country_of_origin_parent_company' into 'country' and 'parent_company'
  separate(country_of_origin_parent_company,
           into = c("country", "parent_company"),
           sep = "/", 
           fill = "right", 
           extra = "merge") |>
  
  # Remove $ and , from numeric columns and convert to numeric
  mutate(across(c(dems, repubs), ~ as.numeric(str_replace_all(., "[\\$,]", "")))) |>
  
  # Keep only needed columns
  select(year, pac_name_affiliate, country, parent_company, dems, repubs)

# ==================
# Export Unique Countries to CSV
# ==================
# Summarize contributions by country and party
country_party_totals <- pac |>
  pivot_longer(cols = c(dems, repubs), names_to = "party", values_to = "amount") |>
  filter(!is.na(country), !is.na(amount)) |>
  group_by(country, party) |>
  summarise(amount = sum(amount), .groups = "drop") |>
  pivot_wider(names_from = party, values_from = amount, values_fill = 0) |>
  mutate(total = dems + repubs) |>
  arrange(desc(total))

# Write to CSV
write_csv(country_party_totals, "country_contributions_summary.csv")

# ==================
# Data Wrangle - Pivot and Summarize
# ==================

pac_long <- pac |>
  pivot_longer(
    cols = c(dems, repubs),
    names_to = "party",
    values_to = "amount"
  ) |>
  mutate(party = recode(party,
                        "dems" = "Democrat",
                        "repubs" = "Republican"))

yearly_totals <- pac_long |>
  filter(country == "UK", !is.na(amount)) |>
  group_by(year, party) |>
  summarise(amount = sum(amount), .groups = "drop")

# ==================
# Create the Plot
# ==================

g2a <- ggplot(yearly_totals, aes(x = year, y = amount, color = party)) +
  geom_line(linewidth = 1.2) +
  scale_y_continuous(
    name = "Total amount",
    labels = label_dollar(scale = 1e-6, suffix = "M")
  ) +
  scale_x_continuous(
    name = "Year",
    breaks = scales::pretty_breaks()
  ) +
  scale_color_manual(
    values = c("Democrat" = "blue", "Republican" = "red"),
    labels = c("Democrat", "Republican"),
    name = "Party"
  ) +
  labs(title = "Contributions to US political parties from UK-connected PACs") +
  theme(
    legend.position = c(0.9, 0.15),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 0)
  )

# Show the plot
print(g2a)
