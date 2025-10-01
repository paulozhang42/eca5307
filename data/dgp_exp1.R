#=========================================================================#
#  Pricing Experiment 1 Replication
#  Author: Jianan
#  Adapted from Misra et al. (2019) Section 5
#  Date: 07/23/2025
#  Note: In this code, a confusion is that there's actually N = 7870 consumers and 1000 equally sized segments, but this is 
#        impossible since 7870/100=7.87. We make additional assumption that the original sample size is N=8000 and each segmentation 
#        thus has 8 consumers, but we randomly exclude 130 data points at each replication。
#=========================================================================#

# Load necessary packages
library(dplyr)
library(stats)  # For basic statistical functions
library(utils)  # For file operations

# Set working directory and directories
setwd("/Users/paulozhang42/Desktop/RA")
data_dir <- "/Users/paulozhang42/Desktop/RA/data/"
output_dir <- "/Users/paulozhang42/Desktop/RA/output/"
figures_dir <- "/Users/paulozhang42/Desktop/RA/figures/"

# Create directories if they do not exist
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# Set seed for reproducibility
set.seed(1) #Seed used in DM's replication file

# Define constants
N_SEGMENTS <- 1000
N_CONSUMERS <- 7870  # True sample size as per MSA
N_REPLICATIONS <- 10000  # Number of replications for robustness
CUTOFF <- 6292 # Cutoff price for drawing valuation, see DM's table 6
COST <- 0  # MC of the product, assumed to be zero for simplicity

# Defining vectors
segment <- rep(1:N_SEGMENTS, each = 8)  # Segment labels waiting to be assigned, total 8000 labels (we sample 7870 out of them)
prices <- c(19, 39, 59, 79, 99, 159, 199, 249, 299, 399) 
exp1 <- rep(prices, each = (N_CONSUMERS / 10) ) # Price for each consumer waiting to be assigned.
acquisition_rates <- c(0.36, 0.32, 0.28, 0.28, 0.24, 0.20, 0.18, 0.17, 0.13, 0.10)  # According to MSA's footnote 14, acquisition rates of $59 and $79 are revised to both 0.28, and 399$ is revised to 0.10 as correction of small sample errror.
delta <- 5  # Valuation variation hyperparameter

# Define intervals and probabilities for v_s based on acquisition rates
intervals <- list(c(0, 19), c(19, 39), c(39, 59), c(59, 79), c(79, 99), c(99, 159), 
                 c(159, 199), c(199, 249), c(249, 299), c(299, 399), c(399, CUTOFF))
probs <- c(1 - acquisition_rates[1], diff(1 - acquisition_rates), acquisition_rates[10]) 

# Initialize storage for replication results
conversion_rates <- matrix(NA, nrow = N_REPLICATIONS, ncol = 10)
colnames(conversion_rates) <- as.character(prices)
profits <- matrix(NA, nrow = N_REPLICATIONS, ncol = 10)

# Replication loop
for (B in 1:N_REPLICATIONS) {
  set.seed(1 + B)  # Unique seed per replication based on overall seed
  
  # Generate segment midpoints v_s
  v_s <- numeric(N_SEGMENTS)
  for (seg in 1:N_SEGMENTS) {
    interval_index <- sample(1:11, 1, prob = probs)
    a <- intervals[[interval_index]][1]
    b <- intervals[[interval_index]][2]
    v_s[seg] <- runif(1, a, b)
  }

  # Assign consumers to segments (initial population of 8000)
  consumer_segment <- sample(segment, size = N_CONSUMERS, replace = FALSE) # assign each consumer to a segment, getting a segment label vector.

  # Generate individual valuations v_i for initial population
  v_i <- numeric(N_CONSUMERS)
  for (ind in 1:N_CONSUMERS) {
    s <- consumer_segment[ind]
    v_i[ind] <- runif(1, max(0, v_s[s] - delta), v_s[s] + delta) # MSA do not mention but the valuation should be non-negative.
  }

  # Assign consumers to price points
  price_assignments <- sample(exp1)

  # Simulate purchases
  purchases <- as.integer(v_i >= price_assignments)

  # Compute conversion rates for each price point
  conversion_rates[B, ] <- tapply(purchases, factor(price_assignments, levels = prices), mean, na.rm = TRUE)

  # Compute profit
  for (p in seq_along(prices)) {
  conv_rate <- conversion_rates[B, p]
  profit <- ((prices[p] - COST ) * conv_rate ) * (N_CONSUMERS / 10)
  profits[B, p] <- profit
  }
}

# Average conversion rates across replications
mean_conversion_rates <- colMeans(conversion_rates, na.rm = TRUE)
mean_profits <- colMeans(profits, na.rm = TRUE)
sd_conversion_rates <- apply(conversion_rates, 2, sd, na.rm = TRUE)
sd_profits <- apply(profits, 2, sd, na.rm = TRUE)
ci_lower_conv <- apply(conversion_rates, 2, quantile, probs = 0.025, na.rm = TRUE)
ci_upper_conv <- apply(conversion_rates, 2, quantile, probs = 0.975, na.rm = TRUE)
ci_lower_prof <- apply(profits, 2, quantile, probs = 0.025, na.rm = TRUE)
ci_upper_prof <- apply(profits, 2, quantile, probs = 0.975, na.rm = TRUE)

# Create summary data frame
summary_stats <- data.frame(
  Price = as.numeric(colnames(conversion_rates)),
  Mean_Conversion_Rate = mean_conversion_rates,
  SD_Conversion_Rate = sd_conversion_rates,
  CI_Lower_Conversion = ci_lower_conv,
  CI_Upper_Conversion = ci_upper_conv,
  Mean_Profit = mean_profits,
  SD_Profit = sd_profits,
  CI_Lower_Profit = ci_lower_prof,
  CI_Upper_Profit = ci_upper_prof,
  
  Sample_Size = rep( (N_CONSUMERS / 10) , each = 10)
)

# Save data from the last replication (for reference)
simulated_exp1_data <- data.frame(
  ConsumerID = 1:N_CONSUMERS,
  Segment = consumer_segment,
  TrueValuation = v_i,
  Price = price_assignments,
  Purchase = purchases
)
save(simulated_exp1_data, file = paste0(data_dir, "simulated_exp1_data.Rdata"))

# Output results
cat("Simulated Experiment 1 Results (Averaged over", N_REPLICATIONS, "Replications):\n")
print(summary_stats)

# Compare with reported acquisition rates from Dubé and Misra (2023)
reported <- data.frame(
  Price = prices,
  ReportedConversion = acquisition_rates
)
comparison <- merge(summary_stats[, c("Price", "Mean_Conversion_Rate")], reported, by = "Price", all.x = TRUE)
cat("\nComparison with Reported Acquisition Rates:\n")
print(comparison)
