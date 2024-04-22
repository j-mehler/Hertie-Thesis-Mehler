# form indicator: text length

# load data
data <- read_csv("data/batches.csv")

# create column that provides the number of characters of people's personal hate speech definitions
data <- data %>% mutate(text_length_abs = nchar(data$Input.hate_definition))

# select respondent id, hate definition and new indicator variable 
text_length <- data %>% 
  select(Input.ResponseId, Input.hate_definition, text_length_abs) %>% 
  mutate(text_length = log2(text_length_abs))

# change colname
colnames(text_length) <- c("ResponseId", "hate_definition", "text_length_abs", "text_length")

# save data (respondent id and new indicator variable)
text_length %>% write_csv("data/text_length.csv")
