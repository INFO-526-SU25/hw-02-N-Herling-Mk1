pacman::p_load(here)
source(here("q2/setup.R"))

# Step 0: Load Required Libraries
library(tidyverse)
library(janitor)
library(fs)
library(scales)
library(crayon)

# - dataframe -> tibble
# - column ----> variable
# - row -------> observation

# Step 0: Load file list
cat("\n\n", blue("Loading files:..."))
list_of_files <- dir_ls(path = "data", regexp = "Foreign Connected PAC")

# Task 1: - Print how many files were detected
cat("\n\n.-----File Data ------>>\n")
cat("Number of files detected:", length(list_of_files), "\n")
cat("<<---------------------.\n")

# Task 2: - combine the files into one .csv file.
pac <- read_csv(list_of_files, id = "year") |> clean_names()

# Write cleaned dataframe to CSV
output_dir <- here("output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

write_csv(pac, file.path(output_dir, "pac_Tx1.csv"))
cat(green("✅ Data saved to 'output/pac_Tx1csv'\n"))
View(pac)
cat(green("✅ Data saved to 'output/pac_cleaned.csv'\n"))
#############################################################<-- files merged.

#-- explore data.
library(stringr)

classify_dollar <- function(x) {
  x <- str_trim(x)
  case_when(
    str_detect(x, "^\\$\\d[\\d,]*$") ~ "+$",
    str_detect(x, "^-\\$\\d[\\d,]*$") ~ "-$",
    TRUE ~ "Other"
  )
}

cols_to_check <- c("total", "dems", "repubs")
all_levels <- c("+$", "-$", "Other")

cat("\n\n.----- Value Type Counts ------>>\n")
for (col in cols_to_check) {
  cat("\nColumn:", col, "\n")
  
  result <- pac %>%
    mutate(class = factor(classify_dollar(.data[[col]]), levels = all_levels)) %>%
    count(class, .drop = FALSE)
  
  result <- bind_rows(result, tibble(class = "SUM", n = sum(result$n)))
  
  print(result)
}
cat("<<-----------------------------.\n")

# Extract year and separate columns
pac <- pac %>%
  mutate(year = str_extract(year, "\\d{4}(?=\\.csv$)") %>% as.integer()) %>%
  separate(country_of_origin_parent_company,
           into = c("country", "parent_company"),
           sep = "/", 
           fill = "right", 
           extra = "merge") %>%
  mutate(across(c(dems, repubs), ~ {
    x <- str_replace_all(., "[\\$,]", "")
    as.numeric(x)
  })) %>%
  select(year, pac_name_affiliate, country, parent_company, dems, repubs)

write_csv(pac, file.path(output_dir, "pac_Tx_final.csv"))
cat(green("✅ Data saved to 'output/ppac_Tx_final.csv\n"))
print(glimpse(pac))

classify_sign <- function(x) {
  case_when(
    is.na(x)       ~ "Other",
    x >= 0         ~ "+",
    x < 0          ~ "-",
    TRUE           ~ "Other"
  )
}

counts_by_year <- pac %>%
  pivot_longer(cols = c(dems, repubs), names_to = "party", values_to = "amount") %>%
  mutate(class = factor(classify_sign(amount), levels = c("+", "-", "Other"))) %>%
  group_by(year, party, class) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(year, party, class)

cat("\n\n", crayon::blue("===== Counts of points by Year, Party, and Category ====="), "\n")
print(counts_by_year, n = Inf)
cat("===========================================================\n\n")

yearly_lists <- pac %>%
  group_by(year) %>%
  summarise(
    dem_values = list(dems[!is.na(dems)]),
    repub_values = list(repubs[!is.na(repubs)])
  ) %>%
  arrange(year)

cat("\n\n", crayon::yellow("===== Lists of Individual Values per Year ====="), "\n")
print(yearly_lists, n = Inf)

for(i in seq_len(nrow(yearly_lists))) {
  cat("\nYear:", yearly_lists$year[i], "\n")
  cat("Dem values:\n")
  print(yearly_lists$dem_values[[i]])
  cat("Repub values:\n")
  print(yearly_lists$repub_values[[i]])
  cat("---------------------------------------------------\n")
}

triplets_labeled <- pac %>%
  pivot_longer(
    cols = c(dems, repubs),
    names_to = "party",
    values_to = "amount"
  ) %>%
  filter(!is.na(amount)) %>%
  mutate(party = if_else(party == "dems", "dem", "repubs")) %>%
  select(year, parent_company, party, amount) %>%
  arrange(year, parent_company, party)

unique_years <- sort(unique(triplets_labeled$year))

for (yr in unique_years) {
  cat(crayon::green$bold(paste0("\n====== Year: ", yr, " ======\n")))
  
  print(triplets_labeled %>% filter(year == yr), n = Inf)
  
  cat(crayon::silver$italic("\nPress [Enter] to continue to next year...\n"))
  readline()
}

cols_to_check <- c("dems", "repubs")
all_levels <- c("+", "-", "Other")

cat("\n\n.----- Value Type Counts ------>>\n")
for (col in cols_to_check) {
  cat("\nColumn:", col, "\n")
  
  result <- pac %>%
    mutate(class = factor(classify_sign(.data[[col]]), levels = all_levels)) %>%
    count(class, .drop = FALSE)
  
  result <- bind_rows(result, tibble(class = "SUM", n = sum(result$n)))
  
  print(result)
}
cat("<<-----------------------------.\n")

# Step 1: Summarize totals by year for UK only
yearly_totals <- pac %>%
  filter(country == "UK") %>%
  pivot_longer(cols = c(dems, repubs), names_to = "party", values_to = "amount") %>%
  filter(!is.na(amount)) %>%
  group_by(year, party) %>%
  summarise(amount = sum(amount), .groups = "drop")

write_csv(yearly_totals, file.path(output_dir, "yearly_totals.csv"))
cat(green("✅ yearly_totals saved to 'output/yearly_totals.csv'\n"))

# Plot with data point labels
g2a <- ggplot(yearly_totals, aes(x = year, y = amount, color = party)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  geom_text(aes(label = scales::dollar(amount, scale = 1e-6, suffix = "M")), 
            vjust = -0.5, size = 3.5, show.legend = FALSE) +
  scale_y_continuous(
    name = "Total amount",
    labels = label_dollar(scale = 1e-6, suffix = "M"),
    breaks = c(1e6, 2e6, 3e6),
    position = "left"
  ) +
  scale_x_continuous(
    name = "Year",
    breaks = c(2000, 2005, 2010, 2015, 2020),
    position = "bottom"
  ) +
  scale_color_manual(
    values = c("dems" = "blue", "repubs" = "red"),
    labels = c("Democrats", "Republicans"),
    name = NULL
  ) +
  labs(title = "the graph") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.title.y = element_text(vjust = -2),
    axis.title.x = element_text(hjust = 1.1),
    legend.position = "bottom",
    legend.justification = "right"
  )

print(g2a)
