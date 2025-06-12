pacman::p_load(here)
source(here("q2/setup.R"))
 
# Diagnostic: Review Scores Rating
cat("=== Data Diagnostics for `review_scores_rating` ===\n")

# 1. Data type
cat("Data Type:\n")
print(class(edibnb$review_scores_rating))

# 2. Summary statistics (range, median, quartiles, etc.)
cat("\nSummary Statistics:\n")
print(summary(edibnb$review_scores_rating))

# 3. Count of missing values
cat("\nMissing Values (NA count):\n")
print(sum(is.na(edibnb$review_scores_rating)))

# 4. Check for outliers using IQR method
q1 <- quantile(edibnb$review_scores_rating, 0.25, na.rm = TRUE)
q3 <- quantile(edibnb$review_scores_rating, 0.75, na.rm = TRUE)
iqr <- q3 - q1
lower_bound <- q1 - 1.5 * iqr
upper_bound <- q3 + 1.5 * iqr

cat("\nOutlier Detection (IQR method):\n")
cat("Lower bound:", lower_bound, "\n")
cat("Upper bound:", upper_bound, "\n")
outliers <- edibnb$review_scores_rating[!is.na(edibnb$review_scores_rating) &
                                          (edibnb$review_scores_rating < lower_bound |
                                             edibnb$review_scores_rating > upper_bound)]
cat("Number of potential outliers:", length(outliers), "\n")
cat("Outlier values (if any):\n")
print(outliers)
