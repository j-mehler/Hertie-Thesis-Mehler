# form indicator: text length

# load data
data <- read_csv("data/batches.csv")

# create column that provides the number of characters of people's personal hate speech definitions
data <- data %>% mutate(text_length = nchar(data$Input.hate_definition))

# select respondent id and new indicator variable 
text_length <- data %>% select(Input.ResponseId, Input.hate_definition, text_length)

# save data (respondent id and new indicator variable)
text_length %>% write_csv("data/text_length.csv")
