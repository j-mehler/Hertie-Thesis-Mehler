

# libraries
library(tidygraph)
library(ggraph)

# Assuming `data` is your dataframe containing the 50 boolean variables
cor_matrix <- cor(data_numeric_filtered, method = "pearson")

# Assuming 'data' is your dataframe and 'cor_matrix' is computed from it
var_names <- rownames(cor_matrix) # Assuming rownames are your variable names

# Convert the correlation matrix to a long format, including variable names
cor_data <- as.data.frame(as.table(cor_matrix)) %>%
  filter(Var1 != Var2) %>% # Exclude self-correlations
  mutate(Var1 = factor(Var1, levels = var_names),
         Var2 = factor(Var2, levels = var_names)) %>%
  filter(abs(Freq) > 0.2) # Filter to simplify the network, adjust threshold as needed

# Create a tidy graph from the filtered correlation data
graph <- as_tbl_graph(cor_data, directed = FALSE) %>%
  activate(nodes) %>%
  mutate(name = name) # Ensure nodes have 'name' attribute for labeling

# Visualize the network with node labels
ggraph(graph, layout = 'fr') +
  geom_edge_link(aes(edge_width = abs(Freq), edge_color = Freq > 0), show.legend = FALSE) +
  geom_node_point(size = 4, color = "blue") +
 # geom_node_text(aes(label = name), repel = TRUE, size = 3) +
  scale_edge_color_manual(values = c("red" = "negative correlation", "blue" = "positive correlation")) +
  ggtitle("Network Visualization of Boolean Variables Correlation") +
  theme_void()
