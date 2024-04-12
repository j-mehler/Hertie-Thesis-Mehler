# Controls

# Gender (female/male/other)
# Age (derived age, sclae 1-10, collapsed into categories 18-29, 30-49, 50-69, 70+)
# Political interest (measured with four levels, collapsed into three)
# Empathy (first principal component of responses to three topic-specific items)
# Experience with hate and offensive speech (score created from the answers on five items) 
# Online hostile engagement (score created from the answers on three items)


# load reprocessed data
data_all <- read_csv("data/data_clean.csv")

# select columns relevant for creating the controls + respondents' ID
data_clean_controls <- data_all %>% select(ResponseId, gender, age, age10, age_cat, polinterest_cat)

# load and select empathy and experience data as numeric variables
data_survey_complete <- readRDS("data/data_survey_complete.rds")
data_numeric <- data_survey_complete %>% select(ResponseId, starts_with("empathy"), starts_with("exp"), polinterest)

# combine clean controls and numeric data
data_controls <- inner_join(data_clean_controls, data_numeric, by = "ResponseId")
  

# POLINTEREST ----
# add variable that collapses the four categories into three
data_controls <- data_controls %>% mutate(
  polinterest_cat_3 = ifelse(is.na(polinterest_cat), NA, 
                             ifelse(polinterest_cat == "Not interested at all" | polinterest_cat == "Slightly interested", 
                                    "Low", 
                                    ifelse(polinterest_cat == "Moderately interested", 
                                           "Intermediate", "High")
                                    )
                             )
  )

# check frequency
freq(data_controls$polinterest_cat_3)


# EMPATHY ----
# Select only the columns related to empathy
empathy_data <- data_controls %>% select(ResponseId, empathy_person, empathy_predicting, empathy_perspective)

# check NA's
empathy_data %>% 
  filter(is.na(empathy_person)) %>% 
  count() # 295 

empathy_data %>% 
  filter(is.na(empathy_predicting)) %>% 
  count() # 318

empathy_data %>% 
  filter(is.na(empathy_perspective)) %>% 
  count() # 327

empathy_data %>% 
  filter(is.na(empathy_person) & is.na(empathy_predicting) & is.na(empathy_perspective)) %>% 
  count() # 109 have all missing

empathy_data %>% 
  filter(is.na(empathy_person) | is.na(empathy_predicting) | is.na(empathy_perspective)) %>% 
  count() # 613 have one missing, but this seems to be distributed across all three items

# empathy_data_clean <- na.omit(empathy_data) # this would remove 613 observations

# Better: Imputation
# Impute mean of other two components or the exact value of one, if two are missing
data_controls <- data_controls %>%
  rowwise() %>%
  mutate(
    empathy_person = if_else(is.na(empathy_person) & sum(!is.na(pick(starts_with("empathy")))) == 2,
                             mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_person),
    empathy_predicting = if_else(is.na(empathy_predicting) & sum(!is.na(pick(starts_with("empathy")))) == 2,
                                 mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_predicting),
    empathy_perspective = if_else(is.na(empathy_perspective) & sum(!is.na(pick(starts_with("empathy")))) == 2,
                                  mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_perspective),
    empathy_person = if_else(is.na(empathy_person) & sum(!is.na(pick(starts_with("empathy")))) == 1,
                             mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_person),
    empathy_predicting = if_else(is.na(empathy_predicting) & sum(!is.na(pick(starts_with("empathy")))) == 1,
                                 mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_predicting),
    empathy_perspective = if_else(is.na(empathy_perspective) & sum(!is.na(pick(starts_with("empathy")))) == 1,
                                  mean(c_across(starts_with("empathy")), na.rm = TRUE), empathy_perspective)
  ) %>%
  ungroup()

# if needed again, save imputation results because of long runtime
# data_controls %>% write_csv("data/imputation.csv")
# data_controls <- read_csv("data/imputation.csv")

# Perform PCA for Empathy
pca_data <- data_controls %>%
  select(ResponseId, empathy_person, empathy_predicting, empathy_perspective) %>%
  drop_na(empathy_person, empathy_predicting, empathy_perspective)

pca_results <- prcomp(select(pca_data, -ResponseId), scale. = TRUE)

# Extract the first principal component scores
pc1_scores <- pca_results$x[, 1]

# Include PCA scores back into pca_data
pca_data <- pca_data %>%
  mutate(empathy_pc = pc1_scores)

# Join PCA scores back to the original data_controls by ResponseId
data_controls <- data_controls %>%
  left_join(pca_data %>% select(ResponseId, empathy_pc), by = "ResponseId")

# check distribution of new PC variable
ggplot(data_controls, aes(x = empathy_pc)) +
  geom_density()

freq(data_controls$empathy_pc)


# EXPERIENCE WITH HATE SPEECH ----

# [exp_offended, exp_threatened, exp_witnessed, exp_disagree, exp_angry]

# check frequencies
freq(data_controls$exp_offended)
freq(data_controls$exp_threatened)
freq(data_controls$exp_witnessed)
freq(data_controls$exp_disagree)
freq(data_controls$exp_angry)

# add score out of row means
data_controls <- data_controls %>%
  mutate(exp_hate_speech = rowMeans(select(., exp_offended, exp_threatened, exp_witnessed, exp_disagree, exp_angry), 
                           na.rm = TRUE))


# ONLINE HOSTILE ENGAGEMENT ----

# [exp_postregret, exp_postoffensive, exp_postopinion]

# check frequencies
freq(data_controls$exp_postregret)
freq(data_controls$exp_postoffensive)
freq(data_controls$exp_postopinion)

# add score out of row means
data_controls <- data_controls %>%
  mutate(exp_hostile_engagement = rowMeans(select(., exp_postregret, exp_postoffensive, exp_postopinion), 
                           na.rm = TRUE))



# Last Steps ----

# drop columns that were used to create my controls
data_controls <- data_controls %>% select(-polinterest_cat, 
                                          -c(empathy_person, empathy_predicting, empathy_perspective),
                                          -c(exp_offended, exp_threatened, exp_witnessed, exp_disagree, exp_angry),
                                          -starts_with("exp_post"))

# add minority status
data_minority <- data_all %>% select(minority, minority_cat)
data_controls <- cbind(data_controls, data_minority)

# check new variables
data_controls %>% summary()

# add factor variables for the numeric ones (empathy, experience with hs, experience with online hostile engagement)
data_controls <- data_controls %>% mutate(
  empathy_pc_cat = ifelse(is.na(empathy_pc), NA, ifelse(empathy_pc >= 0, "More empathetic", "Less empathetic")),
  exp_hate_speech_cat = ifelse(is.na(exp_hate_speech), NA, ifelse(exp_hate_speech >= 3.004, "More experience", "Less experience")), # mean of exp_hate_speech is 3 
  exp_hostile_engagement_cat = ifelse(is.na(exp_hostile_engagement), NA, ifelse(exp_hostile_engagement >= 2.258, "More experience", "Less experience")) # mean around 2
)

# check frequencies of new variables
freq(data_controls$empathy_pc_cat)
freq(data_controls$exp_hate_speech_cat)
freq(data_controls$exp_hostile_engagement_cat)

# save dataset
data_controls %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/controls.csv")





