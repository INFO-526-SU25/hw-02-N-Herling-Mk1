#Check if pacman [package manager] is installed, if not install it.
#throw [FYI] alert either way.
if (!requireNamespace("pacman", quietly = TRUE)) {
  message("Installing 'pacman' (not found locally)...")
  install.packages("pacman")
} else {
  message("[FYI]\n'pacman' already installed — skipping install.")
}


# - install tidyverse/dsbox directly from Git Hub
# - this allows for the possible need to install on a repo. pull.
# - and, if it's already installed just thorw an alert.
if (!requireNamespace("dsbox", quietly = TRUE)) {
  message("Installing 'dsbox' from GitHub (not found locally)...")
  suppressMessages(devtools::install_github("tidyverse/dsbox"))
} else {
  message("[FYI]\n'dsbox' already installed — skipping GitHub install.")
}


# use this line for installing/loading
# pacman::p_load()
# - packages to load stored in a variable (vector)
pkgs <- c("tidyverse","glue","scales","lubridate",
          "patchwork","ggh4x","ggrepel","openintro",
          "ggridges","dsbox")
# - load from the character array/vector
pacman::p_load(char=pkgs)


# - alert to user packages loaded.
cat(paste(
  "The packages loaded:",
  paste("-", pkgs, collapse = "\n"),
  sep = "\n"
))


#---------------------------- themes

# Global R options
options(width = 65)

# knitr chunk options (only applicable in RMarkdown)
if ("knitr" %in% loadedNamespaces()) {
  knitr::opts_chunk$set(
    fig.width = 7,
    fig.asp = 0.618,
    fig.retina = 3,
    fig.align = "center",
    dpi = 300
  )
}

#.csv files..
#accidents <- read_csv("data/accidents.csv") 
