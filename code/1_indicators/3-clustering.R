#### Process cluster indicator ####

# libraries
library(tidyverse)

# read in raw cluster data
cluster_raw <- read_csv("data/cluster_raw.csv")

# read in classification data
batches <- read_csv("data/batches.csv")

## read in original batch data
#batches <- read_csv("data/batches.csv")

#### Convert batches to numeric but keep ResponseId, make sure to reach same sample size ####

## Convert boolean (logical) columns to numeric
data_numeric_filtered <- batches %>% 
  filter(Answer.flag.flag == FALSE) # filter out obs. that are flagged for revision
  select(-ends_with("open"), -Answer.flag_comments, -Answer.flag.flag, -Input.ResponseId) %>% 

#  mutate(across(.cols = everything(), .fns = ~ as.numeric(. == TRUE)))
#
## Create Vector with ResponseId data
#ResponseId <- batches %>% 
#  filter(Answer.flag.flag == FALSE) %>% 
#  select(Input.ResponseId)
#
## combine numeric data and ResponseId
#data <- cbind(ResponseId, data_numeric_filtered)

  
# remove any rows with only zeros (because this was also done for the clustering see RMD)
# create function 
not_zero <- function(x) {
  x == 0
}
# create vector with all item names (columns of pure numeric data)
all_columns <- data_numeric_filtered %>% colnames()
# filter out any columns that are only zero
data <- data %>% filter(!if_all(all_columns, not_zero))


#### Match cluster data with ResponseId

cluster_data <- 
  cbind(data, cluster_raw) %>% # combine data
  mutate(ResponseId = Input.ResponseId) %>% # correct column name
  select(ResponseId, cluster) %>% # select only cluster column and ResponseId
  mutate(cluster = case_when( # change cluster names to characters
    cluster == 1 ~ "A",
    cluster == 2 ~ "B",
    cluster == 3 ~ "C",
    cluster == 4 ~ "D" 
  ))

# save cluster indicator
cluster_data %>% write_csv("data/cluster.csv")
