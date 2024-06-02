process_data_and_fit_logistic_regression_model <- function(data_file) {
  library(readr)    # For reading CSV files
  library(dplyr)    # For data manipulation
  library(car)      # For calculating VIF
  library(caret)    # For identifying highly correlated variables
  library(bestNormalize) # For normalizing data
  library(caTools)  # For splitting the data
  
  # Step 1: Read the data
  merged_data <- read_csv(data_file)
  
  # Step 2: Rename columns
  merged_data <- merged_data %>%
    rename(Fed_Fund_Rate = `Fed.Fund.Rate`,
           Policy_Uncertainty_Index = `Policy.Uncertainty.Index`)
  
  # Step 3: Transform columns
  merged_data$Log_News_Based_Policy_Uncert_Index <- log(merged_data$News_Based_Policy_Uncert_Index)
  
  # Step 4: Define independent variables
  independent_vars <- c(
    'Policy_Uncertainty_Index',
    'Fed_Fund_Rate',
    'Log_News_Based_Policy_Uncert_Index'
    # Add other variables as they appear in your actual data
  )
  
  # Step 5: Split the data into training and testing sets (70% train, 30% test)
  set.seed(123)  # For reproducibility
  sample_split <- sample.split(merged_data$annualized_deal_activity, SplitRatio = 0.7)
  train_data <- subset(merged_data, sample_split == TRUE)
  test_data <- subset(merged_data, sample_split == FALSE)
  
  # Step 6: Calculate correlation matrix
  correlation_matrix <- cor(train_data[, independent_vars])
  
  # Step 7: Calculate VIFs (fit a preliminary model to get VIFs)
  preliminary_formula <- as.formula(paste('annualized_deal_activity ~', paste(independent_vars, collapse = ' + ')))
  preliminary_model <- glm(preliminary_formula, data = train_data, family = binomial)
  vif_values <- vif(preliminary_model)
  
  # Step 8: Identify highly correlated variables (e.g., correlation coefficient > 0.7)
  highly_correlated <- findCorrelation(correlation_matrix, cutoff = 0.7, names = TRUE)
  
  # Step 9: Handle multicollinearity if necessary
  if (length(highly_correlated) > 0) {
    print("Highly correlated variables detected. Handling multicollinearity...")
    # Remove one of the highly correlated variables
    to_remove <- highly_correlated[2] # Select the second variable for removal
    independent_vars <- setdiff(independent_vars, to_remove)
    # Re-define formula with updated independent variables
    formula <- as.formula(paste('annualized_deal_activity ~', paste(independent_vars, collapse = ' + ')))
  } else {
    # Use the original formula if no multicollinearity is detected
    formula <- preliminary_formula
  }
  
  # Step 10: Fit the logistic regression model on the training data
  logit_model <- glm(formula, data = train_data, family = binomial, control = glm.control(maxit = 100, epsilon = 1e-8))
  
  # Step 11: Evaluate the model on the testing data
  test_predictions <- predict(logit_model, newdata = test_data, type = "response")
  test_actual <- test_data$annualized_deal_activity
  test_predictions_binary <- ifelse(test_predictions > 0.5, 1, 0)
  
  # Calculate accuracy
  accuracy <- mean(test_predictions_binary == test_actual)
  print(paste("Model Accuracy on Test Data:", accuracy))
  
  # Return the logistic regression model
  print(summary(logit_model))
  
  return(logit_model)
}

# Call the function and store the logistic regression model
model <- process_data_and_fit_logistic_regression_model("./data/transformed_data.csv")

# Sample prediction using the model
sample_data <- data.frame(
  Policy_Uncertainty_Index = 0.5,
  Fed_Fund_Rate = 0.1,
  Log_News_Based_Policy_Uncert_Index = 1.2
  # Add other variables as needed
)

# Predict using the model
prediction <- predict(model, newdata = sample_data, type = "response")
print(prediction)
