# How well does people's definition of hate speech predict their political orientation?

# Survey item: "In politics people often talk about the "left" and the "right". On a scale between 1 (furthest left) and 11 (furthest right), where would you place yourself?"
# Data: Classification Data
# Method a little bit similar to: #Polar Scores. Measuring partisanship using social media content [@hemphill2016]
  
# Preparation
  
# libraries
library(tidyverse)
library(tidymodels)
library(broom)

# read in survey data 
data_survey <- read_csv("data/data_clean.csv")

# and select only ID and leftright
data_leftright <- data_survey %>% select(ResponseId, leftright) %>% filter(!is.na(leftright))

# read in classification data
data_classification <- read_csv("data/batches.csv")

# and select variables of interest: ResponseID and Boolean Variables.
data_features <- data_classification %>% 
  select(-Input.country, -Input.hate_definition, -ends_with("open"), -Answer.flag_comments, -Answer.flag.flag) %>% 
  mutate(ResponseId = Input.ResponseId) %>% # align variable name with other dataset
  select(-Input.ResponseId) # remove old row

# perform inner join to combine leftright with the classification features
data <- inner_join(data_leftright, data_features, by = "ResponseId")
#data %>% write_csv("data/data_pol_score.csv")


#### Train and evaluate a linear model ####

# split the dataset
set.seed(123) # For reproducibility
data_split <- initial_split(data, prop = 0.3)
train_data <- training(data_split) %>% select(-ResponseId)
test_data  <- testing(data_split)

# Define the model specification
model_spec <- linear_reg() %>% 
  set_engine("lm") %>% 
  set_mode("regression")

# fit the model
model_fit <- model_spec %>% 
  fit(leftright ~ ., data = train_data)

# Extract coefficients and create a dataframe to look at feature importance
coefficients_df <- tidy(model_fit) %>% 
  select(term, estimate) %>%
  filter(term != "(Intercept)") %>%   # remove the intercept
  arrange(estimate)

coefficients_df %>% write_csv("data/coefficients.csv")

# predict leftright on the test data
predictions <- predict(model_fit, new_data = test_data) %>% 
  bind_cols(test_data)

# Calculate prediction error, here: RMSE
error <- predictions %>%
  metrics(truth = leftright, estimate = .pred)


# Create Prediction Score

# The score is constructed like this: 10 minus the absolute error between leftright and the prediction for leftright

## Calculate the prediction score and assign it to each observation in the training set

# a higher score means better predictability
data_result <- predictions %>% 
  mutate(leftright_pred_score = 10-abs(leftright-.pred)) %>%
  select(ResponseId, leftright, .pred, leftright_pred_score)

data_scores <- data_result %>% select(ResponseId, leftright, leftright_pred_score)

# assign NA's to training data and add them to the final dataset
train_data <- training(data_split) %>% select(ResponseId, leftright) %>% mutate(leftright_pred_score = NA)

# combine test and training data to reach original sample size
data_scores <- rbind(data_scores, train_data)

# save data
data_scores %>% write_csv("data/political_score.csv")


