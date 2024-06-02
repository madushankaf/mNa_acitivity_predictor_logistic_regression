library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(readr) 
library(tidyverse)

create_deal_counts_csv <- function(file_path) {
    # Read the first sheet by name
    deal_data <- read_excel(file_path, sheet = 1, skip = 1)
    names(deal_data)[1] <- "Date_Announced"
    company_cols <- names(deal_data)[-1]

    data_long <- deal_data %>%
    pivot_longer(cols = -Date_Announced, names_to = "Company_ID", values_to = "Value")

    data_long <- data_long %>%
    mutate(Year = year(Date_Announced))

    analysis_data <- data_long %>%
        mutate(Presence = ifelse(!is.na(Value) & Value == 1, 1, 0)) %>%
        group_by(Year, Company_ID) %>%
        summarise(Presence = max(Presence, na.rm = TRUE)) %>%
        pivot_wider(names_from = Company_ID, values_from = Presence, values_fill = list(Presence = 0))
    
    print(analysis_data)

    write_csv(analysis_data, "./data/analysis_data.csv")

    # Print a message indicating the file has been saved
    print("The analysis data has been written to 'analysis_data.csv'")


}

# Usage example:
create_deal_counts_csv("./data/Data1.xlsx")


merge_deal_counts_to_control_vars <- function(deal_counts_file, control_vars_file) {
    # Read the deal counts data
    deal_counts_data <- read.csv(deal_counts_file)

    # Read the control variables data
    control_vars_data <- read_excel(control_vars_file)

    # Merge the deal counts data with the control variables data
    merged_data <- merge(deal_counts_data, control_vars_data, by.x = "Year", by.y = "Year", all = TRUE)

    # Create a CSV file with the merged data
    csv_file_path <- paste0("./data/merged_data",  ".csv")
    write.csv(merged_data, file = csv_file_path, row.names = FALSE)

    # Print the file path of the created CSV file
    print(paste("CSV file created:", csv_file_path))
}

# Usage example:
merge_deal_counts_to_control_vars("./data/analysis_data.csv", "./data/Variables.xlsx")


# Define the function
reshape_data <- function(merged_file) {

    merged_data <- read.csv(merged_file)
    merged_data <- merged_data %>% select(-Year)

    # Pivot the data from wide to long format
    long_data <- merged_data %>%
        pivot_longer(
            cols = 2:3993,     # Specifies the range of company ID columns
            names_to = "companyid", 
            values_to = "value"
        ) %>%
        group_by(companyid)

    names(long_data)[1] <- "annualized_deal_activity"


    # Write the transformed data to a CSV file
    write.csv(long_data, "./data/transformed_data.csv", row.names = FALSE)
    print(paste("transformed CSV file created:", "transformed_data.csv"))

    
}

reshape_data("./data/merged_data.csv")





