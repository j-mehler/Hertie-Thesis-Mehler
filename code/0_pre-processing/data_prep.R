# data preparation

library(tidyverse)
library(here)

load(here("data/data_survey_prepd_respondent.RData"))

data_complete <- data_survey_complete_resp

# drop variables that will not be taken into account in the analysis
data_selected <- data_complete %>% 
  dplyr::select(!c(1:8, 10:22, starts_with("vig"), starts_with("t_")))

# Replacing "0" with "NA" in open text answers
data_clean <- data_selected %>% 
  mutate(open_hatedefinition = na_if(open_hatedefinition, ""),
         open_allow = na_if(open_allow, ""))

# save cleaned dataset
data_clean %>% write_csv(here("data/data_clean.csv"))
