# form indicator: text length

# load data
data <- read_csv("data/batches.csv")

# create column that provides the number of characters of people's personal hate speech definitions
data <- data %>% mutate(text_length = nchar(data$hate_definition))

# select respondent id, hate definition and new indicator variable 
text_length <- data %>% 
  select(ResponseId, hate_definition, text_length) %>% 
  mutate(text_length_log2 = log2(text_length))

# save data (respondent id and new indicator variable)
text_length %>% write_csv("data/text_length.csv")
