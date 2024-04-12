# Academic Status

# load reprocessed data
data_all <- read_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_clean.csv")


# create new variable on academic status (until 22 it is probably decided which path someone is going to pursue)
data_new <- data_all %>% mutate(
  academic_status = if_else(age <= 22, NA, 
                            if_else(educ_cat == "High", 
                                    "academic", 
                                    ifelse(educ_cat == "Intermediate" | educ_cat == "Low", 
                                           "non-academic", NA)
                                    )
                            )
  )

# select academic status and ResponseId
data_new <- data_new %>% select(ResponseId, academic_status, educ_cat)

# save dataset
data_new %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/academic_status.csv")





