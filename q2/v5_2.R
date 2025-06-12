pacman::p_load(here)
source(here("q2/setup.R"))

# Step 0: Load file list
cat("\n\n", blue("Loading files:..."))
list_of_files <- dir_ls(path = "data", regexp = "Foreign Connected PAC")
list_of_files
# read all files and row bind them
# keeping track of the file name in a new column called year
pac <- read_csv(list_of_files, id = "year")
pac <- pac |>
  janitor::clean_names() |> 
  mutate(
    year = str_extract(year, "\\d{4}-\\d{4}"),  # This extracts the year range like '1999-2000'
    year = str_extract(year, "\\d{4}$"),  # This extracts the last year in the range
    year = as.numeric(year)) |>
  separate(country_of_origin_parent_company, into = c("country_of_origin", "parent_company"), sep = "\\/", extra = "merge") |>
  select(-total) |>
  mutate(
    dems = str_remove(dems, "\\$"),
    repubs = str_remove(repubs, "\\$"),
    dems = as.numeric(dems),
    repubs = as.numeric(repubs)
  )

pac_longer <- pac |>
  pivot_longer(
    cols = c(dems, repubs),
    names_to = "party",
    values_to = "amount"
  ) |>
  mutate(party = if_else(party == "dems", "Democrat", "Republican"))

country_yearly_totals <- pac_longer |>
  filter(country_of_origin == "UK") |>
  group_by(year, party) |>
  summarise(total_amount = sum(amount), .groups = "drop")


pac_plot <- ggplot(country_yearly_totals, aes(x = year, y = total_amount, color = party)) +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("blue", "red")) +
  scale_y_continuous(labels = label_dollar(scale = 1/1000000, suffix = "M")) +
  labs(
    x = "Year",
    y = "Total amount",
    color = "Party",
    title = "Contributions to US political parties from UK-connected PACs",
    caption = "Source: OpenSecrets.org"
  ) +
  theme_minimal() +
  theme(
    legend.position = c(0.9, 0.15),
    axis.title.x = element_text(hjust = 0),
    axis.title.y = element_text(hjust = 0)
  )

print(pac_plot)
