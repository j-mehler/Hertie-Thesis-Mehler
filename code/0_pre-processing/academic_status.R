# Academic Status and Political Spectrum ------------------------------

# Academic Status ----

# load reprocessed data
data_all <- read_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_clean.csv")

# create new variable on academic status
#data_new <- data_all %>% mutate(
#  academic_status = ifelse(educ_cat == "High", "academic", "non-academic")
#)

# create new variable on academic status (until 22 it is probably decided which path someone is going to pursue)
data_new <- data_all %>% mutate(
  academic_status = if_else(age <= 22, NA, 
                            if_else(educ_cat == "High", 
                                    "academic", 
                                    "non-academic")))

# save dataset
data_new %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_clean.csv")





