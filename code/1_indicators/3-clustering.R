#### Process cluster indicator ####

# libraries
library(tidyverse)

# read in raw cluster data
cluster_raw <- read_csv("data/cluster_raw.csv")

# read in classification data
batches <- read_csv("data/batches.csv")

data_numeric <- batches %>% select(-ResponseId, -hate_definition)

## remove any rows with only zeros (because this was also done for the clustering see RMD)
## create function 
#not_zero <- function(x) {
#  x == 0
#}
#
## create vector with all item names (columns of pure numeric data)
#all_columns <- data_numeric %>% colnames()
#
## filter out any columns that are only zero
#data_numeric <- data_numeric %>% filter(!if_all(all_columns, not_zero))

#### Convert batches to numeric but keep ResponseId, make sure to reach same sample size ####

### Convert boolean (logical) columns to numeric
#data_numeric_filtered <- batches %>% 
#  filter(Answer.flag.flag == FALSE) # filter out obs. that are flagged for revision
#  select(-ends_with("open"), -Answer.flag_comments, -Answer.flag.flag, -.ResponseId) %>% 
#
#  mutate(across(.cols = everything(), .fns = ~ as.numeric(. == TRUE)))
#

# Create Vector with ResponseId data
ResponseId <- batches %>% select(ResponseId)

# combine numeric data and ResponseId
data <- cbind(ResponseId, data_numeric)


#### Combine cluster data with ResponseId

cluster_data <- 
  cbind(data, cluster_raw) %>% # combine data
  select(ResponseId, cluster) %>% # select only cluster column and ResponseId
  mutate(cluster = case_when( # change cluster names to characters
    cluster == 1 ~ "Content-based",
    cluster == 2 ~ "Harms-based",
    cluster == 3 ~ "Denying/Nonsense",
    cluster == 4 ~ "Harms-based narrow" 
  ))

# save cluster indicator
cluster_data %>% write_csv("data/cluster.csv")
