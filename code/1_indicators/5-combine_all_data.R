# join all datasets (preprocessed variables and created indicators) ----

# read in data
data_academic_status <- read_csv("data/academic_status.csv")
data_controls <- read_csv("data/all_controls.csv")  
data_text_length <- read_csv("data/text_length.csv")

data_readability_score <- read_csv("data/readability.csv")
data_readability_score <- data_readability_score %>% select(-hate_definition)

data_cluster <- read_csv("data/cluster.csv")
data_pred_error <- read_csv("data/leftright_pred_error.csv")

# to extract country and language variables
data_clean <- read_csv("data/data_clean.csv")
additional_data <- data_clean %>% select(ResponseId, country, Q_Language)


# join datasets (inner join with ResponseId)
data <- inner_join(data_academic_status, data_controls, by = "ResponseId")
data <- left_join(data_text_length, data, by = "ResponseId")
data <- left_join(data_readability_score, data, by = "ResponseId")
data <- left_join(data_cluster, data, by = "ResponseId")
data <- inner_join(data_pred_error, data, by = "ResponseId")
data <- left_join(data, additional_data, by = "ResponseId")


# save data
data %>% write_csv("data/data_combined.csv")
