process_data_and_fit_logistic_regression_model <- function(data_file) {
  library(readr)    # For reading CSV files
  library(readxl)   # For reading Excel files
  library(dplyr)    # For data manipulation
  library(car)      # For calculating VIF
  library(caret)    # For identifying highly correlated variables
  library(bestNormalize) # For normalizing data

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
  
  # Step 5: Calculate correlation matrix
  correlation_matrix <- cor(merged_data[, independent_vars])
  
  # Step 6: Calculate VIFs (fit a preliminary model to get VIFs)
  preliminary_formula <- as.formula(paste('annualized_deal_activity ~', paste(independent_vars, collapse = ' + ')))
  preliminary_model <- glm(preliminary_formula, data = merged_data, family = binomial)
  vif_values <- vif(preliminary_model)
  
  # Step 7: Identify highly correlated variables (e.g., correlation coefficient > 0.7)
  highly_correlated <- findCorrelation(correlation_matrix, cutoff = 0.7, names = TRUE)
  
  # Step 8: Handle multicollinearity if necessary
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
  
  # Step 9: Fit the logistic regression model
  logit_model <- glm(formula, data = merged_data, family = binomial, control = glm.control(maxit = 100, epsilon = 1e-8))
  
  # Step 10: Return the logistic regression model

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
