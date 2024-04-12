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

# save all scores
readability %>% write_csv("data/readability_all_scores.csv")

# select average grade level as final readability score
readability_score <- readability %>% select(Input.ResponseId, Input.hate_definition, Average_Grade_Level)

# change colname
colnames(readability_score) <- c("ResponseId", "hate_definition", "readability_score")

# check distribution and values
readability_score %>% summary()

# remove "Inf" value
readability_score[is.infinite(readability_score)] <- NA

# save data (respondent id and new indicator variables)
readability_score %>% write_csv("data/readability.csv")
