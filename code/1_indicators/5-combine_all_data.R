# join all datasets (preprocessed variables and created indicators) ----

# read in data
data_academic_status <- read_csv("data/academic_status.csv")
data_controls <- read_csv("data/controls.csv")  
data_text_length <- read_csv("data/text_length.csv")
data_readability_score <- read_csv("data/readability.csv")
data_cluster <- read_csv("data/cluster.csv")
data_political_score <- read_csv("data/political_score.csv")


# join datasets (inner join with ResponseId)
data <- inner_join(data_academic_status, data_controls, by = "ResponseId", copy = FALSE)
data <- inner_join(data, data_text_length, by = "ResponseId", copy = FALSE)
data <- inner_join(data, data_readability_score, by = "ResponseId", copy = FALSE) %>% select(-hate_definition.y)
data <- inner_join(data, data_cluster, by = "ResponseId", copy = FALSE)
data <- inner_join(data, data_political_score, by = "ResponseId", copy = FALSE)

# fix colnames
data <- data %>% 
  mutate(hate_definition = hate_definition.x,
         total_minutes = total_minutes.x,
         total_minutes_log2 = total_minutes_log2.x) %>% 
  select(-c(hate_definition.x, total_minutes.x, total_minutes_log2.x, total_minutes.y, total_minutes_log2.y))

# save data
data %>% write_csv("data/data_combined.csv")
