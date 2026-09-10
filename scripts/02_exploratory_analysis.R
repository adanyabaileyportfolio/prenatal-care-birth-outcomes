#Project: Prenatal Care and Adverse Birth Outcomes
#Author: Adanya Bailey 

library(tidyverse)
library(here)

#Load cleaned dataset
natality_clean <- read_rds(
  here("data", "processed", "natality_2024_clean.rds")
)

cat("Total records loaded:", nrow(natality_clean), "\n")

glimpse(natality_clean)

#Validation
validation_summary <- tibble(
  variable = c(
    "Gestational age",
    "Birth weight",
    "Prenatal-care initiation",
    "Prenatal visits",
    "Race and ethnicity",
    "Education",
    "Smoking status",
    "Birth type"
  ),
  
  missing_records = c(
    sum(is.na(natality_clean$gestational_age)),
    sum(is.na(natality_clean$birth_weight_grams)),
    sum(is.na(natality_clean$prenatal_care_group)),
    sum(is.na(natality_clean$prenatal_visits)),
    sum(is.na(natality_clean$race_ethnicity)),
    sum(is.na(natality_clean$education)),
    sum(is.na(natality_clean$smoking_status)),
    sum(is.na(natality_clean$birth_type))
  )
) %>%
  mutate(
    total_records = nrow(natality_clean),
    missing_percent = round(
      100 * missing_records / total_records,
      2
    )
  )

print(validation_summary)

write_csv(
  validation_summary,
  here("output", "tables", "validation_summary.csv")
)

#Overall Outcomes 
overall_summary <- natality_clean %>%
  summarise(
    total_births = n(),
    
    preterm_births = sum(
      preterm_birth == "Yes",
      na.rm = TRUE
    ),
    
    preterm_birth_rate = round(
      100 * mean(preterm_birth == "Yes", na.rm = TRUE),
      2
    ),
    
    low_birth_weight_births = sum(
      low_birth_weight == "Yes",
      na.rm = TRUE
    ),
    
    low_birth_weight_rate = round(
      100 * mean(low_birth_weight == "Yes", na.rm = TRUE),
      2
    ),
    
    first_trimester_care_rate = round(
      100 * mean(
        prenatal_care_group == "First trimester",
        na.rm = TRUE
      ),
      2
    )
  )

print(overall_summary)

write_csv(
  overall_summary,
  here("output", "tables", "overall_summary.csv")
)

print(overall_summary, width = Inf)

#Group comparisons function
calculate_group_rates <- function(data, group_variable) {
  
  data %>%
    filter(!is.na({{ group_variable }})) %>%
    group_by({{ group_variable }}) %>%
    summarise(
      total_births = n(),
      
      valid_preterm_records = sum(!is.na(preterm_birth)),
      
      preterm_births = sum(
        preterm_birth == "Yes",
        na.rm = TRUE
      ),
      
      preterm_birth_rate = round(
        100 * mean(preterm_birth == "Yes", na.rm = TRUE),
        2
      ),
      
      valid_birth_weight_records = sum(!is.na(low_birth_weight)),
      
      low_birth_weight_births = sum(
        low_birth_weight == "Yes",
        na.rm = TRUE
      ),
      
      low_birth_weight_rate = round(
        100 * mean(low_birth_weight == "Yes", na.rm = TRUE),
        2
      ),
      
      .groups = "drop"
    )
}
#Comparison Tables 
prenatal_care_summary <- calculate_group_rates(
  natality_clean,
  prenatal_care_group
)

maternal_age_summary <- calculate_group_rates(
  natality_clean,
  maternal_age_group
)

race_ethnicity_summary <- calculate_group_rates(
  natality_clean,
  race_ethnicity
)

education_summary <- calculate_group_rates(
  natality_clean,
  education
)

smoking_summary <- calculate_group_rates(
  natality_clean,
  smoking_status
)

birth_type_summary <- calculate_group_rates(
  natality_clean,
  birth_type
)
print(prenatal_care_summary, width = Inf)
print(maternal_age_summary, width = Inf)
print(race_ethnicity_summary, width = Inf)
print(education_summary, width = Inf)
print(smoking_summary, width = Inf)
print(birth_type_summary, width = Inf)

#Export 
write_csv(
  prenatal_care_summary,
  here("output", "tables", "prenatal_care_summary.csv")
)

write_csv(
  maternal_age_summary,
  here("output", "tables", "maternal_age_summary.csv")
)

write_csv(
  race_ethnicity_summary,
  here("output", "tables", "race_ethnicity_summary.csv")
)

write_csv(
  education_summary,
  here("output", "tables", "education_summary.csv")
)

write_csv(
  smoking_summary,
  here("output", "tables", "smoking_summary.csv")
)

write_csv(
  birth_type_summary,
  here("output", "tables", "birth_type_summary.csv")
)

print(prenatal_care_summary, width = Inf)
print(race_ethnicity_summary, width = Inf)
print(smoking_summary, width = Inf)

#Theme

villanova_navy <- "#00205B"
villanova_blue <- "#418FDE"
villanova_white <- "#FFFFFF"
villanova_gray <- "#E5E7EB"
villanova_text <- "#1F2937"

outcome_colors <- c(
  "Preterm birth" = villanova_navy,
  "Low birth weight" = villanova_blue
)

theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.background = element_rect(
        fill = villanova_white,
        color = NA
      ),
      panel.background = element_rect(
        fill = villanova_white,
        color = NA
      ),
      plot.title = element_text(
        color = villanova_navy,
        face = "bold",
        size = 16
      ),
      plot.subtitle = element_text(
        color = villanova_text,
        size = 11
      ),
      plot.caption = element_text(
        color = "gray40",
        size = 9
      ),
      axis.title = element_text(
        color = villanova_navy,
        face = "bold"
      ),
      axis.text = element_text(
        color = villanova_text
      ),
      panel.grid.major = element_line(
        color = villanova_gray,
        linewidth = 0.3
      ),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      legend.text = element_text(
        color = villanova_text
      )
    )
)

#Figure 1 - Gestational-age distribution 

gestational_age_plot <- natality_clean %>%
  filter(!is.na(gestational_age)) %>%
  ggplot(aes(x = gestational_age)) +
  geom_histogram(
    binwidth = 1,
    boundary = 0,
    fill = villanova_navy,
    color = villanova_white
  ) +
  geom_vline(
    xintercept = 37,
    color = villanova_blue,
    linewidth = 1.2,
    linetype = "dashed"
  ) +
  labs(
    title = "Distribution of Gestational Age",
    subtitle = paste(
      "The dashed line marks the preterm threshold",
      "of 37 completed weeks"
    ),
    x = "Gestational age (weeks)",
    y = "Number of births",
    caption = paste(
      "Source: CDC 2024 U.S. Natality Public-Use File.",
      "Preterm birth is defined as birth before 37 completed weeks."
    )
  ) +
  scale_y_continuous(labels = scales::comma)

gestational_age_plot

ggsave(
  filename = here(
    "output",
    "figures",
    "gestational_age_distribution.png"
  ),
  plot = gestational_age_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

#Figure 2 - Outcomes by parental-care inititation 
prenatal_plot_data <- prenatal_care_summary %>%
  select(
    prenatal_care_group,
    preterm_birth_rate,
    low_birth_weight_rate
  ) %>%
  pivot_longer(
    cols = c(
      preterm_birth_rate,
      low_birth_weight_rate
    ),
    names_to = "outcome",
    values_to = "rate"
  ) %>%
  mutate(
    outcome = recode(
      outcome,
      preterm_birth_rate = "Preterm birth",
      low_birth_weight_rate = "Low birth weight"
    ),
    
    prenatal_care_group = factor(
      prenatal_care_group,
      levels = c(
        "First trimester",
        "Second trimester",
        "Third trimester",
        "No prenatal care"
      )
    )
  )
prenatal_care_plot <- ggplot(
  prenatal_plot_data,
  aes(
    x = prenatal_care_group,
    y = rate,
    fill = outcome
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  geom_text(
    aes(label = paste0(rate, "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.4,
    size = 3.5,
    color = villanova_text
  ) +
  scale_fill_manual(values = outcome_colors) +
  scale_y_continuous(
    limits = c(0, 27),
    breaks = seq(0, 25, 5),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Birth Outcomes by Prenatal-Care Initiation",
    subtitle = paste(
      "Births with no reported prenatal care had the highest",
      "observed adverse-outcome rates"
    ),
    x = "When prenatal care began",
    y = "Observed birth outcome rate",
    fill = NULL,
    caption = paste(
      "Associations do not establish causation.",
      "Source: CDC 2024 U.S. Natality Public-Use File."
    )
  ) +
  theme(
    axis.text.x = element_text(
      angle = 20,
      hjust = 1
    )
  )

prenatal_care_plot

ggsave(
  filename = here(
    "output",
    "figures",
    "outcomes_by_prenatal_care.png"
  ),
  plot = prenatal_care_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

#Figure 3: Outcomes by race and ethnicity 
race_plot_data <- race_ethnicity_summary %>%
  select(
    race_ethnicity,
    preterm_birth_rate,
    low_birth_weight_rate
  ) %>%
  pivot_longer(
    cols = c(
      preterm_birth_rate,
      low_birth_weight_rate
    ),
    names_to = "outcome",
    values_to = "rate"
  ) %>%
  mutate(
    outcome = recode(
      outcome,
      preterm_birth_rate = "Preterm birth",
      low_birth_weight_rate = "Low birth weight"
    )
  )

race_ethnicity_plot <- ggplot(
  race_plot_data,
  aes(
    x = reorder(race_ethnicity, rate),
    y = rate,
    fill = outcome
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.7
  ) +
  coord_flip() +
  scale_fill_manual(values = outcome_colors) +
  scale_y_continuous(
    limits = c(0, 17),
    breaks = seq(0, 16, 2),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Birth Outcomes by Maternal Race and Ethnicity",
    subtitle = paste(
      "Observed preterm and low-birth-weight rates",
      "differed across demographic groups"
    ),
    x = NULL,
    y = "Observed birth outcome rate",
    fill = NULL,
    caption = paste(
      "Associations do not establish causation.",
      "Source: CDC 2024 U.S. Natality Public-Use File."
    )
  )

race_ethnicity_plot

ggsave(
  filename = here(
    "output",
    "figures",
    "outcomes_by_race_ethnicity.png"
  ),
  plot = race_ethnicity_plot,
  width = 10,
  height = 7,
  dpi = 300,
  bg = "white"
)

#Figure 4 - Outcomes by smoking status 
smoking_plot_data <- smoking_summary %>%
  select(
    smoking_status,
    preterm_birth_rate,
    low_birth_weight_rate
  ) %>%
  pivot_longer(
    cols = c(
      preterm_birth_rate,
      low_birth_weight_rate
    ),
    names_to = "outcome",
    values_to = "rate"
  ) %>%
  mutate(
    outcome = recode(
      outcome,
      preterm_birth_rate = "Preterm birth",
      low_birth_weight_rate = "Low birth weight"
    )
  )

smoking_plot <- ggplot(
  smoking_plot_data,
  aes(
    x = smoking_status,
    y = rate,
    fill = outcome
  )
) +
  geom_col(
    position = position_dodge(width = 0.8),
    width = 0.65
  ) +
  geom_text(
    aes(label = paste0(rate, "%")),
    position = position_dodge(width = 0.8),
    vjust = -0.4,
    size = 4,
    color = villanova_text
  ) +
  scale_fill_manual(values = outcome_colors) +
  scale_y_continuous(
    limits = c(0, 20),
    breaks = seq(0, 20, 5),
    labels = function(x) paste0(x, "%")
  ) +
  labs(
    title = "Birth Outcomes by Smoking Status",
    subtitle = paste(
      "Smoking during pregnancy was associated with higher",
      "observed preterm and low-birth-weight rates"
    ),
    x = NULL,
    y = "Observed birth outcome rate",
    fill = NULL,
    caption = paste(
      "Associations do not establish causation.",
      "Source: CDC 2024 U.S. Natality Public-Use File."
    )
  )

smoking_plot

ggsave(
  filename = here(
    "output",
    "figures",
    "outcomes_by_smoking_status.png"
  ),
  plot = smoking_plot,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

#Save 
saved_figures <- list.files(
  here("output", "figures"),
  pattern = "\\.png$",
  full.names = FALSE
)

print(saved_figures)
