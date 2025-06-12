pacman::p_load(here)
source(here("q1_hold\\setup.R"))



#------- Data Preparation ----
# - create a new dataframe/tibble
accidents_v2 <- accidents[c("day_of_week", "time", "severity")]
accidents_v2 <- accidents[c("day_of_week", "time", "severity")]
accidents_v2 <- accidents_v2 |>
  group_by(day_of_week) |>
  mutate(is_weekend = case_when(
    day_of_week %in% c("Saturday", "Sunday") ~ "Weekend",
    TRUE ~ "Weekday"
  ))

view(accidents_v2)

#set up the color schme
color_scheme <- c("Fatal"="#aa93b0","Serious"= "#9ecac8", "Slight"="#fef39f")


#-create the 'gg' plot...
g_1 <- ggplot(accidents_v2, aes(x=time, group=severity, fill=severity))
g_1 <- g_1 + geom_density(alpha=0.7)  + facet_wrap(~is_weekend, nrow=2)
g_1 <- g_1 + 
  labs(x="Time of day", 
       y="Density", 
       title="Number of accidents throughout the day", 
       subtitle="By day of week and severity") +  
  scale_fill_manual("severity", name="Severity", 
                    values = color_scheme)

#print(g_1)

