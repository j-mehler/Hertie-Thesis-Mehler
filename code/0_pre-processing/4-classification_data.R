#### Text Classification ####

Batch_1 <- read_csv("data/batches/Batch_394877_batch_results.csv")
Batch_2 <- read_csv("data/batches/Batch_395273_batch_results.csv")
Batch_3a <- read_csv("data/batches/Batch_397738_batch_results-jan-26-br-co-idn-po-1-1.csv")
Batch_3b <- read_csv("data/batches/Batch_397738_batch_results-jan-26-br-co-idn-po-2-1.csv")
Batch_4 <- read_csv("data/batches/gsheets_annotation_april24.csv")

# combine all batches that already have the same structure
batches_part_1 <- bind_rows(Batch_1, Batch_2, Batch_3a, Batch_3b)

# select relevant columns
batches_part_1 <- batches_part_1 %>% select("Input.ResponseId", 
                              "Input.hate_definition", 
                              starts_with("Answer"), 
                              -ends_with("open"), 
                              -ends_with("comments"))

Batch_4 <- Batch_4 %>% select(-worker_name, -ends_with("open"), -Input.country)

## combine all batches and delete duplicates (annotations total n = 1721)
data_numeric <- bind_rows(batches_part_1, Batch_4) %>% unique()

## take out annotations flagged for revision (n = 1555)
data_numeric_filtered <- data_numeric %>% filter(Answer.flag.flag == 0) %>% select(-Answer.flag.flag)
  
## remove any rows with only zeros
# create function 
zero <- function(x) {
  x == 0
}
# create vector with column names of numeric data
num_columns <- data_numeric_filtered %>% 
  select(-Input.ResponseId, -Input.hate_definition) %>% 
  colnames()
# filter out any rows that are only zero (n = 1549)
data_numeric_filtered <- data_numeric_filtered %>% filter(!if_all(num_columns, zero))

## remove columns with only zeros
data_numeric_filtered <- data_numeric_filtered %>% select_if(~any(. != 0)) 

## Coin Flip: randomly select one annotation per Response ID out of the existing ones

set.seed(123)  # for reproducibility

data_numeric_filtered <- data_numeric_filtered %>%
  group_by(Input.ResponseId) %>%
  sample_n(1)

# final n = 1079

# change column name to ResponseId
data_numeric_filtered <- data_numeric_filtered %>% 
  rename(ResponseId = Input.ResponseId,
         hate_definition = Input.hate_definition)

# save data
data_numeric_filtered %>% write_csv("data/batches.csv")


#### Further pre-processing of column names

# Replace 'Answer.' with '' for all column names starting with 'Answer.'
names(data_numeric_filtered) <- sub("^Answer\\.", "", names(data_numeric_filtered))

# create subsets for each category
data_content <- data_numeric_filtered %>% select(starts_with("content")) # 15
names(data_content) <- sub("^content\\.", "", names(data_content))

data_other_features <- data_numeric_filtered %>% select(starts_with("other")) # 7
names(data_other_features) <- sub("^other\\.", "", names(data_other_features))

data_scope <- data_numeric_filtered %>% select(starts_with("scope")) # 2
names(data_scope) <- sub("^scope\\.", "", names(data_scope))

data_sender <- data_numeric_filtered %>% select(starts_with("sender")) # 5
names(data_sender) <- sub("^sender\\.", "", names(data_sender))

data_target <- data_numeric_filtered %>% select(starts_with("target")) # 18
names(data_target) <- sub("^target\\.", "", names(data_target))

# Saving all new numeric subsets
data_numeric_filtered %>% write_csv("data/data_numeric_filtered.csv")
data_content %>% write_csv("data/data_content.csv")
data_other_features %>% write_csv("data/data_other_features.csv")
data_scope %>% write_csv("data/data_scope.csv")
data_sender %>% write_csv("data/data_sender.csv")
data_target %>% write_csv("data/data_target.csv")





