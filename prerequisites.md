# Installing Required R Libraries

To install and load the necessary R libraries for your project, follow the steps below:

## 1. Install R and RStudio

Ensure that you have R and RStudio installed on your system.

- Download and install R from [CRAN](https://cran.r-project.org/mirrors.html).
- Download and install RStudio from [RStudio's official website](https://rstudio.com/products/rstudio/download/).

## 2. Install the Required Libraries

You can install the required libraries using the `install.packages` function in R. Open RStudio and run the following commands in the console:

```r
# Install readxl for reading Excel files
install.packages("readxl")

# Install dplyr for data manipulation
install.packages("dplyr")

# Install ggplot2 for data visualization
install.packages("ggplot2")

# Install tidyr for data tidying
install.packages("tidyr")

# Install lubridate for date-time manipulation
install.packages("lubridate")

# Install readr for reading rectangular data
install.packages("readr")

# Install car for calculating Variance Inflation Factor (VIF)
install.packages("car")

# Install caret for training and plotting classification and regression models
install.packages("caret")

# Install tidyverse, a collection of R packages for data science
install.packages("tidyverse")
