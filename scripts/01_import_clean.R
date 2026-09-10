#==================================================
#Project: Prenatal Care and Adverse Birth Outcomes
#Author: Adanya Bailey 
#==================================================

library(tidyverse)
library(here)

#Locate .txt file 

raw_files <- list.files(
  here("data", "raw"),
  pattern = "\\.txt$",
  full.names = TRUE,
  ignore.case = TRUE
)

if(length(raw_files) == 0)
{
  stop("No .txt file was found in data/raw.")
}

if(length(raw_files) > 1)
{
  stop("more than one .txt file was found in data/raw.")
}

raw_file <- raw_files[1]

print(raw_file)

#Locate selected variables 
cdc_positions <- fwf_positions(
  start = c(
    75,   # MAGER
    117,  # MRACEHISP
    124,  # MEDUC
    224,  # PRECARE
    227,  # PRECARE5
    238,  # PREVIS
    269,  # CIG_REC
    454,  # DPLURAL
    499,  # OEGest_Comb
    503,  # OEGest_R3
    504   # DBWT
  ),
  end = c(
    76,
    117,
    124,
    225,
    227,
    239,
    269,
    454,
    500,
    503,
    507
  ),
  col_names = c(
    "MAGER",
    "MRACEHISP",
    "MEDUC",
    "PRECARE",
    "PRECARE5",
    "PREVIS",
    "CIG_REC",
    "DPLURAL",
    "OEGest_Comb",
    "OEGest_R3",
    "DBWT"
  )
)

#Read file 
natality_raw <- read_fwf(
  file = raw_file,
  col_positions = cdc_positions,
  col_types = cols(.default = col_character()),
  trim_ws = TRUE,
  progress = TRUE
)

glimpse(natality_raw)

#Clean 

natality_clean <- natality_raw %>%
  transmute(
    maternal_age = as.integer(MAGER),
    
    gestational_age = if_else(
      OEGest_Comb == "99",
      NA_integer_,
      as.integer(OEGest_Comb)
    ),
    
    birth_weight_grams = if_else(
      DBWT == "9999",
      NA_integer_,
      as.integer(DBWT)
    ),
    
    prenatal_visits = if_else(
      PREVIS == "99",
      NA_integer_,
      as.integer(PREVIS)
    ),
    
    prenatal_care_month = case_when(
      PRECARE == "00" ~ 0L,
      PRECARE == "99" ~ NA_integer_,
      TRUE ~ as.integer(PRECARE)
    ),
    
    # Birth outcomes
    preterm_birth = case_when(
      OEGest_R3 == "1" ~ "Yes",
      OEGest_R3 == "2" ~ "No",
      TRUE ~ NA_character_
    ),
    
    low_birth_weight = case_when(
      is.na(birth_weight_grams) ~ NA_character_,
      birth_weight_grams < 2500 ~ "Yes",
      birth_weight_grams >= 2500 ~ "No"
    ),
    
    # Prenatal-care 
    prenatal_care_group = case_when(
      PRECARE5 == "1" ~ "First trimester",
      PRECARE5 == "2" ~ "Second trimester",
      PRECARE5 == "3" ~ "Third trimester",
      PRECARE5 == "4" ~ "No prenatal care",
      TRUE ~ NA_character_
    ),
    
    # Maternal age 
    maternal_age_group = case_when(
      maternal_age < 20 ~ "Under 20",
      maternal_age <= 24 ~ "20–24",
      maternal_age <= 29 ~ "25–29",
      maternal_age <= 34 ~ "30–34",
      maternal_age <= 39 ~ "35–39",
      maternal_age >= 40 ~ "40 and older",
      TRUE ~ NA_character_
    ),
    
    # Race and ethnicity
    race_ethnicity = case_when(
      MRACEHISP == "1" ~ "Non-Hispanic White",
      MRACEHISP == "2" ~ "Non-Hispanic Black",
      MRACEHISP == "3" ~ "Non-Hispanic AIAN",
      MRACEHISP == "4" ~ "Non-Hispanic Asian",
      MRACEHISP == "5" ~ "Non-Hispanic NHOPI",
      MRACEHISP == "6" ~ "Non-Hispanic Multiracial",
      MRACEHISP == "7" ~ "Hispanic",
      TRUE ~ NA_character_
    ),
    
    # Maternal education
    education = case_when(
      MEDUC == "1" ~ "8th grade or less",
      MEDUC == "2" ~ "Some high school, no diploma",
      MEDUC == "3" ~ "High school graduate or GED",
      MEDUC == "4" ~ "Some college, no degree",
      MEDUC == "5" ~ "Associate degree",
      MEDUC == "6" ~ "Bachelor's degree",
      MEDUC == "7" ~ "Master's degree",
      MEDUC == "8" ~ "Doctorate or professional degree",
      TRUE ~ NA_character_
    ),
    
    # Smoking during pregnancy
    smoking_status = case_when(
      CIG_REC == "Y" ~ "Smoked during pregnancy",
      CIG_REC == "N" ~ "Did not smoke during pregnancy",
      TRUE ~ NA_character_
    ),
    
    # Singleton versus multiple birth
    birth_type = case_when(
      DPLURAL == "1" ~ "Singleton",
      DPLURAL %in% c("2", "3", "4") ~ "Multiple birth",
      TRUE ~ NA_character_
    )
  )

glimpse(natality_clean)

cat("Total births:", nrow(natality_clean), "\n")

summary(natality_clean$maternal_age)
summary(natality_clean$gestational_age)
summary(natality_clean$birth_weight_grams)
summary(natality_clean$prenatal_visits)

table(natality_clean$preterm_birth, useNA = "ifany")
table(natality_clean$low_birth_weight, useNA = "ifany")
table(natality_clean$prenatal_care_group, useNA = "ifany")
table(natality_clean$race_ethnicity, useNA = "ifany")
table(natality_clean$education, useNA = "ifany")
table(natality_clean$smoking_status, useNA = "ifany")
table(natality_clean$birth_type, useNA = "ifany")

#Save cleaned dataset 
write_rds(
  natality_clean,
  here("data", "processed", "natality_2024_clean.rds")
)

#Tableau Sample 
set.seed(2024)

tableau_eligible <- natality_clean %>%
  filter(
    !is.na(preterm_birth),
    !is.na(low_birth_weight)
  )

sample_size <- min(200000, nrow(tableau_eligible))

tableau_sample <- tableau_eligible %>%
  slice_sample(n = sample_size)

write_csv(
  tableau_sample,
  here("data", "processed", "natality_2024_tableau.csv")
)

cat("Eligible births:", nrow(tableau_eligible), "\n")
cat("Tableau sample rows:", nrow(tableau_sample), "\n")
