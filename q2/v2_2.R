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
# read all files and row bind them
# keeping track of the file name in a new column called 'year' (very Noice!)
pac <- read_csv(list_of_files, id = "year")

# pac <- pac %>%
#   mutate(across(where(is.character), ~ {
#     x <- str_trim(.)
#     x <- na_if(x, "NA")
#     x <- na_if(x, "")
#     x
#   }))

# Write cleaned dataframe to CSV
output_dir <- here("output")
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

write_csv(pac, file.path(output_dir, "pac_Tx1.csv"))
cat(green("✅ Data saved to 'output/pac_Tx1csv'\n"))
View(pac)
cat(green("✅ Data saved to 'output/pac_cleaned.csv'\n"))

# Count how many cells contain the exact string "NA" (not missing NA)
na_string_count <- pac %>%
  mutate(across(everything(), as.character)) %>%  # Convert all columns to character
  unlist() %>%                                    # Flatten to a vector
  {sum(. == "NA", na.rm = TRUE)}                  # Count how many equal "NA"

cat("Number of 'NA' strings found in data:", na_string_count, "\n")

# Task 3: - clean the column names..
# Lowercasing all letters
# Replacing spaces and special characters with underscores (_)
# Removing or simplifying punctuation
# Ensuring names are valid R identifiers (e.g., no starting with numbers)
# Making names unique if duplicates exist
# ----
pac <- pac |> clean_names()
cat("\n", green$bold$underline("✅ Names cleaned successfully!"), "\n")


# Step 3: Extract year from file name (e.g., 1999-2000.csv → 2000 as integer)
# Four digits, then dash, then four digits.
pac <- pac |> 
  mutate(
    year = str_extract(year, "\\d{4}-\\d{4}") |> 
      str_sub(6, 9) |> 
      as.integer()
  )

# Step 4: Split country_of_origin_parent_company into two columns
pac <- pac |> 
  separate(
    country_of_origin_parent_company,
    into = c("country", "parent_company"),
    sep = "/",
    fill = "right",
    extra = "merge"
  )

# Step 5: Keep only relevant columns, reorder
pac <- pac |> 
  select(year, pac_name_affiliate, country, parent_company, dems, repubs)

# Step 6: Remove dollar signs and convert to numeric
pac <- pac |>
  mutate(across(c(dems, repubs), parse_number))

# Final message
cat("\n", green$bold$underline("✅ PAC data cleaned and formatted!"), "\n")

# Optional: Preview the tibble
print(pac, n = 10)

# Task 2: check for any 'NA' or "" present.
# for (file in list_of_files) {
#   cat("\nChecking file:", file, "\n")
#   
#   # Read the file (adjust depending on format)
#   data <- read.csv(file, stringsAsFactors = FALSE)
#   
#   # Find NA or empty entries
#   na_or_empty <- sapply(data, function(col) sum(is.na(col) | col == ""))
#   
#   # Report results
#   if (any(na_or_empty > 0)) {
#     cat("NA or empty entries found:\n")
#     print(na_or_empty[na_or_empty > 0])
#   } else {
#     cat("No NA or empty entries found.\n")
#   }
# }


######################- DON'T DELETE -########################
##################### info on tibble #########################
# # - tibble dimensions..
# dim(pac_raw)
# # - column names..
# cat(".-------------\n")
# cat("[Column Names]\n")
# cat("--------------\n")
# cat(paste0(seq_along(names(pac_clean)), ". ", names(pac_clean)), sep = "\n")
# cat("--------------\n")
# - view the df in a window with the IDE
#View(pac_raw)
############################################################
#-> check:
# how many files
# if all column names match.
#

# Task 2: Get and print column names of each file
# column_lists <- map(list_of_files, function(file) {
#   col_names <- names(read_csv(file, n_max = 0, show_col_types = FALSE))
#   cat("File:", file, "\n")
#   cat("Columns:", paste(col_names, collapse = ", "), "\n\n")
#   return(col_names)
# })

# Task 3: Check if all column names are the same
# Compare all elements in the list to the first one
# reference_cols <- column_lists[[1]]
# all_match <- all(map_lgl(column_lists, ~ identical(., reference_cols)))

# Output result
# if (all_match) {
#   cat("✅ All files have the same column names.\n")
# } else {
#   cat("❌ Some files have different column names.\n")
# }

###############################################################


#print(summary(pac))
#print(names(pac))
#View(pac)















