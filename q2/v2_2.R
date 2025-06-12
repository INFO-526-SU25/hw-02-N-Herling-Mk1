pacman::p_load(here)
source(here("q2/setup.R"))

library(ggflags)  # For flag support
library(ggplot2)
library(dplyr)
library(readr)
library(stringr)
library(tidyr)
library(fs)
library(janitor)
library(scales)

list_of_files <- fs::dir_ls(path = "data", regexp = "Foreign Connected PAC")

pac <- read_csv(list_of_files, id = "year") |> 
  clean_names() |>
  mutate(year = str_extract(year, "\\d{4}(?=\\.csv$)") |> as.integer()) |>
  separate(country_of_origin_parent_company,
           into = c("country", "parent_company"),
           sep = "/", fill = "right", extra = "merge") |>
  mutate(across(c(dems, repubs), ~ as.numeric(str_replace_all(., "[\\$,]", "")))) |>
  select(year, pac_name_affiliate, country, parent_company, dems, repubs)

pac_long <- pac |>
  pivot_longer(cols = c(dems, repubs),
               names_to = "party",
               values_to = "amount") |>
  mutate(party = recode(party,
                        "dems" = "Democrat",
                        "repubs" = "Republican"))

yearly_totals <- pac_long |>
  filter(country == "Sweden", !is.na(amount)) |>
  group_by(year, party) |>
  summarise(amount = sum(amount), .groups = "drop")

# Swiss flag iso code is "ch" for ggflags and must be lowercase
# Create a data frame with coordinates and year range for the background flag
flag_bg <- tibble(
  year = seq(min(yearly_totals$year), max(yearly_totals$year)),
  amount = max(yearly_totals$amount) * 1.1,  # place flag slightly above max y
  party = "Democrat",  # dummy party just for color
  country = "ch"
)

g2a <- ggplot() +
  # Swiss flag as a faint background
  geom_flag(data = flag_bg, aes(x = year, y = amount, country = country),
            size = 20, alpha = 0.2) + 
  
  # Lines for Democrat and Republican contributions
  geom_line(data = yearly_totals, aes(x = year, y = amount, color = party), linewidth = 1.2) +  
  
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
  labs(title = "Contributions to US political parties from Sweden-connected PACs") +
  theme(
    legend.position = c(0.9, 0.15),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 0)
  )

print(g2a)















