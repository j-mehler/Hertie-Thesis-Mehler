# form indicator: readability

library(pacman)

# load data
data <- read_csv("data/batches.csv")

# select respondent id and hate definition variable
selection <- data %>% select(ResponseId, hate_definition)

# load package
pacman::p_load_gh(c(
  'trinker/lexicon',
  'trinker/textclean',
  'trinker/textshape',
  "trinker/syllable", 
  "trinker/readability"
))

# calculate readability scores
readability <- readability(selection$hate_definition, list(selection$ResponseId, selection$hate_definition))

# remove "Inf" value
readability[is.infinite(Automated_Readability_Index)] <- NA
readability[is.infinite(Average_Grade_Level)] <- NA

# save all scores
readability %>% write_csv("data/readability_all_scores.csv")

# select average grade level as final readability score
readability_score <- readability %>% select(ResponseId, hate_definition, Average_Grade_Level)

# change colname
colnames(readability_score) <- c("ResponseId", "hate_definition", "readability_score")

# check distribution and values
readability_score %>% summary()

# save data (respondent id and new indicator variables)
readability_score %>% write_csv("data/readability.csv")
