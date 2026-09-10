# Data Dictionary

## Data Source

This project uses the 2024 United States Natality Public-Use File from the
National Center for Health Statistics, Centers for Disease Control and
Prevention.

- Data year: 2024
- Unit of observation: One live birth registered in the United States
- Data format: Fixed-width text file
- Data source: https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm
- User guide: https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/DVS/natality/UserGuide2024.pdf

## Selected Variables

| CDC variable | Position | Description | Values used in this project | Missing or unknown value |
|---|---:|---|---|---|
| `OEGest_Comb` | 499–500 | Obstetric estimate of gestational age, edited | 17–47 completed weeks | `99` |
| `OEGest_R3` | 503 | Obstetric estimate of gestation, three-category recode | `1` = under 37 weeks; `2` = 37 weeks and over | `3` |
| `DBWT` | 504–507 | Infant birth weight in grams, edited | 227–8,165 grams | `9999` |
| `PRECARE` | 224–225 | Month prenatal care began | `00` = no prenatal care; `01`–`10` = month care began | `99` |
| `PRECARE5` | 227 | Month prenatal care began, recoded | `1` = months 1–3; `2` = months 4–6; `3` = month 7 through final month; `4` = no prenatal care | `5` |
| `PREVIS` | 238–239 | Total number of prenatal visits | `00`–`98` visits | `99` |
| `MAGER` | 75–76 | Mother's age in individual years | Ages 12–50; `12` includes ages 10–12 and `50` means age 50 or older | No separate unknown category in this field |
| `MRACEHISP` | 117 | Mother's race and Hispanic-origin recode | Codes `1`–`7` represent the reported race/ethnicity groups | `8` |
| `MEDUC` | 124 | Mother's highest completed education level | Codes `1`–`8` represent education levels | `9` |
| `CIG_REC` | 269 | Any cigarette smoking during pregnancy | `Y` = yes; `N` = no | `U` |
| `DPLURAL` | 454 | Number of infants in the pregnancy | `1` = singleton; `2` = twin; `3` = triplet; `4` = quadruplet or higher | No separate unknown category |

## Race and Ethnicity Codes

The `MRACEHISP` variable uses the following codes:

| Code | Definition |
|---:|---|
| 1 | Non-Hispanic White only |
| 2 | Non-Hispanic Black only |
| 3 | Non-Hispanic American Indian or Alaska Native only |
| 4 | Non-Hispanic Asian only |
| 5 | Non-Hispanic Native Hawaiian or Other Pacific Islander only |
| 6 | Non-Hispanic more than one race |
| 7 | Hispanic |
| 8 | Origin unknown or not stated |

## Maternal Education Codes

The `MEDUC` variable uses the following codes:

| Code | Definition |
|---:|---|
| 1 | Eighth grade or less |
| 2 | Ninth through twelfth grade, no diploma |
| 3 | High-school graduate or GED |
| 4 | Some college credit, no degree |
| 5 | Associate degree |
| 6 | Bachelor's degree |
| 7 | Master's degree |
| 8 | Doctorate or professional degree |
| 9 | Unknown |

## Derived Variables

| Derived variable | Definition |
|---|---|
| `preterm_birth` | Gestational age under 37 completed weeks |
| `low_birth_weight` | Birth weight below 2,500 grams |
| `prenatal_care_group` | First trimester, second trimester, third trimester, no prenatal care, or unknown |
| `maternal_age_group` | Under 20, 20–24, 25–29, 30–34, 35–39, or 40 and older |
| `smoking_status` | Smoked or did not smoke during pregnancy |
| `birth_type` | Singleton or multiple birth |