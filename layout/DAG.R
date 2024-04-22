# DAG

library(ggplot2)
library(ggdag)
library(dagitty)

# Define the DAG
dag <- dagify(
  Academic_Status ~ Gender + Age,
  HS_Concept ~ Academic_Status + Empathy + Political_Interest + Age + Esp_with_HS + Online_Hostile_Engagement,
  Empathy ~ Academic_Status + Gender,
  Political_Interest ~ Academic_Status,
  Online_Hostile_Engagement ~ Academic_Status,
  Esp_with_HS ~ Gender + Academic_Status,
  labels = c(
    Academic_Status = "Academic Status",
    HS_Concept = "HS Concept",
    Gender = "Gender",
    Esp_with_HS = "Esp. with HS",
    Empathy = "Empathy",
    Age = "Age",
    Online_Hostile_Engagement = "Online Hostile Engagement",
    Political_Interest = "Political Interest"
  )
)



# Plotting the DAG using ggdag directly
ggdag_plot <- ggdag(dag) + 
  ggtitle("Directed Acyclic Graph (DAG)") +
  theme_minimal()

print(ggdag_plot)


#### alternative approach

# Define the DAG
dag <- dagitty("dag {
  Academic_Status -> HS_Concept
  Academic_Status -> Empathy
  Academic_Status -> Political_Interest
  Academic_Status -> Online_Hostile_Engagement
  Academic_Status -> Esp_with_HS
  Gender -> Academic_Status
  Gender -> Empathy
  Gender -> Esp_with_HS
  Age -> Academic_Status
  Age -> HS_Concept
  Empathy -> HS_Concept
  Political_Interest -> HS_Concept
  Esp_with_HS -> HS_Concept
  Online_Hostile_Engagement -> HS_Concept
}")

# Plotting the DAG
plot(dag)



