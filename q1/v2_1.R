# pacman::p_load(here)
# source(here("q2/setup.R"))
# 
# # Step 0: Load Required Libraries
# library(tidyverse)
# library(janitor)
# library(fs)
# library(scales)
# 
# # - dataframe -> tibble
# # - column ----> variable
# # - row -------> observation
# 
# # Step 1: Load and Combine the Data
# list_of_files <- dir_ls(path = "data", regexp = "Foreign Connected PAC")
# pac_raw <- read_csv(list_of_files, id = "year")
# 
# # Loop through each file, read just the headers, and print the column names
# for (file in list_of_files) {
#   cat("File:", file, "\n")
#   col_names <- names(read_csv(file, n_max = 0))
#   cat("Columns:", paste(col_names, collapse = ", "), "\n\n")
# }
# 
# ######################- DON'T DELETE -########################
# # - tibble dimensions..
# dim(pac_raw)
# # - column names..
# cat("--------------\n")
# cat("[Column Names]\n")
# cat("--------------\n")
# cat(paste0(seq_along(names(pac_clean)), ". ", names(pac_clean)), sep = "\n")
# cat("--------------\n")
# # - view the df in a window with the IDE
# View(pac_raw)
# ############################################################
# # Step 2: Clean column names
# pac_clean <- pac_raw %>%
#   clean_names()
# 
# # Step 3: Extract year from filename and convert to integer
# pac_clean <- pac_clean %>%
#   mutate(year = str_extract(year, "\\d{4}"),
#          year = as.integer(year))
# 
# # Step 4: Select relevant columns
# pac_selected <- pac_clean %>%
#   select(year,
#          pac_name_affiliate,
#          country_of_origin,
#          parent_company,
#          dems,
#          repubs)
# 
# # Step 5: Clean numeric columns (remove any commas/dollar signs and convert to numeric)
# pac_selected <- pac_selected %>%
#   mutate(
#     dems = as.numeric(gsub("[^0-9.]", "", dems)),
#     repubs = as.numeric(gsub("[^0-9.]", "", repubs))
#   )
# 
# # Step 6: Pivot longer to get party and amount columns
# pac_long <- pac_selected %>%
#   pivot_longer(cols = c(dems, repubs),
#                names_to = "party",
#                values_to = "amount") %>%
#   mutate(party = case_when(
#     party == "dems" ~ "Democrat",
#     party == "repubs" ~ "Republican"
#   ))
# 
# # Step 7: Filter for UK-origin PACs and summarize contributions by year and party
# uk_contributions <- pac_long %>%
#   filter(country_of_origin == "UK") %>%
#   group_by(year, party) %>%
#   summarise(total_contribution = sum(amount, na.rm = TRUE), .groups = "drop")
# 
# # 🔹 Step 8: Plot the Results
# g1 <- ggplot(uk_contributions, aes(x = year, y = total_contribution, fill = party)) +
#   geom_col(position = "dodge") +
#   scale_fill_manual(values = c("Democrat" = "red", "Republican" = "blue")) +
#   scale_x_continuous(breaks = c(2000, 2005, 2010, 2015, 2020),
#                      limits = c(2000, 2024)) +
#   scale_y_continuous(labels = dollar_format(scale = 1e-6, suffix = "M"),
#                      breaks = c(1e6, 2e6, 3e6),
#                      limits = c(1e6, 4e6)) +
#   labs(title = "UK Foreign-Connected PAC Contributions to US Political Parties",
#        x = "Election Year",
#        y = "Total Contributions (USD)",
#        fill = "Party") +
#   theme_minimal()
# 
# 
# print(g1)