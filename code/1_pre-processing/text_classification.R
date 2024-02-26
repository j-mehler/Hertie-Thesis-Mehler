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
Batch_1 <- Batch_1 %>% select("Input.country", starts_with("Answer")) %>% select(-Answer.other_open)
Batch_2 <- Batch_2 %>% select("Input.country", starts_with("Answer")) %>% select(-Answer.scope_open)

# combine batches
batches <- rbind(Batch_1, Batch_2)

# select only classification items and country variable
batches <- batches %>% select("Input.country", starts_with("Answer"))

batches %>% write_csv("/Users/Jo/OneDrive/1_Hertie Studies/Thesis/Hertie-Thesis-Mehler/data/batches.csv")
