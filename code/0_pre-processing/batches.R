# Text Classification ----

# read batch 1 and select variables
Batch_1 <- read_csv("~/OneDrive/1_Hertie Studies/Thesis/2023-hate-speech-opentext/definition-classifications/Batch_394877_batch_results.csv")
Batch_2 <- read_csv("~/OneDrive/1_Hertie Studies/Thesis/2023-hate-speech-opentext/definition-classifications/Batch_395273_batch_results.csv")

# Get the column names for each dataset
columns_Batch_1 <- names(Batch_1)
columns_Batch_2 <- names(Batch_2)

# Compare the column names to find differences
differences <- columns_Batch_1 != columns_Batch_2

# Display the positions and names of the differing columns
differing_columns <- data.frame(Position = which(differences),
                                Batch_1_Columns = columns_Batch_1[differences],
                                Batch_2_Columns = columns_Batch_2[differences])

print(differing_columns)

# take out the two variables that do not match between the batches
# Batch_1 <- Batch_1 %>% select("Input.country", starts_with("Answer")) %>% select(-Answer.other_open)
# Batch_2 <- Batch_2 %>% select("Input.country", starts_with("Answer")) %>% select(-Answer.scope_open)

# combine batches
# batches <- rbind(Batch_1, Batch_2)

# Batch 2 ----

# select only classification items and country variable (Batch_2 is ENGLISH and I only want English definitions for now for my indices)
batches <- Batch_2 %>% 
  filter(WorkerId == "AII5BIP222H36") %>% # make responses unique through choosing one annotator only (before every Input existed twice in the dataset)
  select("Input.ResponseId", "Input.country", "Input.hate_definition", starts_with("Answer"))
  

batches %>% write_csv("/Users/Jo/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/batches.csv")

# Pre-Processing

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
data_content <- data_numeric %>% select(starts_with("content")) # 15
names(data_content) <- sub("^content\\.", "", names(data_content))

data_other_features <- data_numeric %>% select(starts_with("other")) # 7
names(data_other_features) <- sub("^other\\.", "", names(data_other_features))

data_scope <- data_numeric %>% select(starts_with("scope")) # 2
names(data_scope) <- sub("^scope\\.", "", names(data_scope))

data_sender <- data_numeric %>% select(starts_with("sender")) # 5
names(data_sender) <- sub("^sender\\.", "", names(data_sender))

data_target <- data_numeric %>% select(starts_with("target")) # 18
names(data_target) <- sub("^target\\.", "", names(data_target))

# Saving all new numeric subsets
data_numeric_filtered %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_numeric_filtered.csv")
data_content %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_content.csv")
data_other_features %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_other_features.csv")
data_scope %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_scope.csv")
data_sender %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_sender.csv")
data_target %>% write_csv("~/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/data_target.csv")


# second worker ID ----
# select only classification items and country variable (Batch_2 is ENGLISH and I only want English definitions for now for my indices)
batches_2 <- Batch_2 %>% 
  filter(WorkerId == "A30NFMEAMKLAM8") %>% # make responses unique through choosing one annotator only (before every Input existed twice in the dataset)
  select("Input.ResponseId", "Input.country", "Input.hate_definition", starts_with("Answer"))


batches_2 %>% write_csv("/Users/Jo/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/batches_2.csv")
