# Commitment in Survey Participation

# load reprocessed data
data_all <- read_csv("data/data_clean.csv")


# select time stamps for submission of each page
time_data <- data_all %>% select(ResponseId, ends_with("Submit")) %>% select(-t_hate_definition_Page_Submit)

# aggregate time stamps for each observation
time_data <- time_data %>% 
  mutate(total_minutes = round(rowSums(select(., -ResponseId), na.rm = TRUE)/60, 1),
         total_minutes_log2 = round(log2(rowSums(select(., -ResponseId), na.rm = TRUE)/60), 2))

# drop time stamp variables
time_data <- time_data %>% select(ResponseId, total_minutes, total_minutes_log2)

#### add to existing control data ####

# load controls
data_controls <- read_csv("data/controls.csv")

# add time variable to control dataset
data_controls <- inner_join(data_controls, time_data, by = "ResponseId")

# overwrite file with control variables
data_controls %>% write_csv("data/controls.csv")
