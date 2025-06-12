pacman::p_load(here)
source(here("q1_hold\\setup.R"))

accidents <- read_csv("data/accidents.csv") 


accidents_mk2 <- accidents[c("day_of_week", "time", "severity")]
accidents_mk2 <- accidents2 %>% group_by(day_of_week) %>% mutate(is_weekend = if(any(day_of_week=='Sunday' 
                                                                                  | day_of_week == 'Saturday'))  "Weekend" else "Weekday")
view(accidents_mk2)


ggplot(accidents_mk2, aes(x = time, group = severity, fill = severity)) +
  geom_density(alpha = 0.6) +
  facet_wrap(~is_weekend, nrow=2) +
  scale_fill_manual(values = severity_colors) +
  scale_x_continuous(breaks = seq(0, 24, by = 4), limits = c(0, 24)) +
  labs(
    title = "Density of Accidents Throughout the Day\nBy Day of Week and Severity",
    x = "Time of Day (Hour)",
    y = "Density",
    fill = "Severity"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    strip.text = element_text(face = "bold")
  )
