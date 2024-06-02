### create_deal_counts_csv()

- **Purpose**: Reads deal data from an Excel file, manipulates it, and saves the processed data to a CSV file.
- **Steps**:
  1. Read Excel file skipping the first row.
  2. Rename the first column to "Date_Announced".
  3. Reshape data from wide to long format using `pivot_longer()`.
  4. Extract the year from "Date_Announced".
  5. Create a binary "Presence" variable based on certain conditions.
  6. Group data by year and company ID, and summarize the "Presence" variable.
  7. Reshape data from long to wide format using `pivot_wider()`.
  8. Write processed data to "analysis_data.csv".

### merge_deal_counts_to_control_vars()

- **Purpose**: Merges deal counts data with control variables data and saves merged data to a CSV file.
- **Steps**:
  1. Read deal counts data from a CSV file.
  2. Read control variables data from an Excel file.
  3. Merge the two datasets using `merge()`.
  4. Write merged data to "Merged_Data.csv".

### reshape_data()

- **Purpose**: Reads merged data from a CSV file, reshapes it from wide to long format, and saves transformed data to a new CSV file.
- **Steps**:
  1. Read merged data from a CSV file.
  2. Remove the "Year" column.
  3. Pivot data from wide to long format using `pivot_longer()`.
  4. Rename columns.
  5. Write transformed data to "transformed_data.csv".
