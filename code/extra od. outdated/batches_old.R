# read batch 1 and select variables
Batch_1 <- read_csv("data/batches/Batch_394877_batch_results.csv")
Batch_2 <- read_csv("data/batches/Batch_395273_batch_results.csv")
Batch_3a <- read_csv("data/batches/Batch_397738_batch_results-jan-26-br-co-idn-po-1-1.csv")
Batch_3b <- read_csv("data/batches/Batch_397738_batch_results-jan-26-br-co-idn-po-2-1.csv")

# combine all batches
batches <- bind_rows(Batch_1, Batch_2, Batch_3a, Batch_3b)

# check Worker ID distribution
batches %>% group_by(WorkerId) %>% count()

# max per worker is n = 1146 atm, so chose only data from worker A30NFMEAMKLAM8 for now 
batches_OLD <- batches %>% 
  filter(WorkerId == "A30NFMEAMKLAM8") %>% # make responses unique through choosing one annotator only (before every Input existed twice in the dataset)
  select("Input.ResponseId", "Input.country", "Input.hate_definition", starts_with("Answer"))

batches_OLD %>% write_csv("data/batches_OLD.csv")

# Pre-Processing ####

# Create numeric Values (TRUE = 1, FALSE = 0) for all columns and remove the country column for now. Create dataframes for each category content, target etc.

# Replace 'Answer.' with '' for all column names starting with 'Answer.'
names(batches) <- sub("^Answer\\.", "", names(batches))

# Convert boolean (logical) columns to numeric
data_numeric <- batches %>% 
  select(-ends_with("open"), -flag_comments, -Input.country, -Input.hate_definition, -Input.ResponseId) %>% 
  mutate(across(.cols = everything(), .fns = ~ as.numeric(. == TRUE)))

# take out answers that are flagged for revision
data_numeric_filtered <- data_numeric %>% filter(flag.flag == FALSE) %>% select(-flag.flag)

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
data_numeric_filtered %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_numeric_filtered.csv")
data_content %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_content.csv")
data_other_features %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_other_features.csv")
data_scope %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_scope.csv")
data_sender %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_sender.csv")
data_target %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_target.csv")


## Comparing Columns of same length  ####
#
## check column differences between batches and Batch 4
## Get the column names for each dataset
#columns_batches <- names(batches)
#columns_Batch_4 <- names(Batch_4)
#
## Compare the column names to find differences
#differences <- columns_batches != columns_Batch_4
#
## Display the positions and names of the differing columns
#differing_columns <- data.frame(Position = which(differences),
#                                Batch_1_Columns = columns_batches[differences],
#                                Batch_2_Columns = columns_Batch_4[differences])
#
#print(differing_columns)
