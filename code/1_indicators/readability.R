# form indicator: readability

library(pacman)

# load data
data <- read_csv("data/batches.csv")

# select respondent id and hate definition variable
selection <- data %>% select(Input.ResponseId, Input.hate_definition)

# load package
pacman::p_load_gh(c(
  'trinker/lexicon',
  'trinker/textclean',
  'trinker/textshape',
  "trinker/syllable", 
  "trinker/readability"
))

# calculate readability scores
readability <- readability(selection$Input.hate_definition, list(selection$Input.ResponseId, selection$Input.hate_definition))

# save data (respondent id and new indicator variables)
readability %>% write_csv("data/readability.csv")
