#=========================================================================#
#  Pricing Experiment 2 Pipeline
#  Adapted from Misra et al. (2019) and DM's replication package
#  This script simulates the second experiment of Dubé and Misra (2023) using a personalized pricing strategy
#  Author: Jianan
#  Date: 12/18/2021, Modified: 07/18/2025
#  Note: The final conversion rate shows that the personalized pricing strategy has much higher conversion rates than the reported version in Dubé and Misra (2023). 
#        This is potentially due to strong assumptions that firms can evaluate demand from experiment 2 samples using the same acquisition rates at different price points as in experiment 1.
#=========================================================================#

# Load necessary packages
library(dplyr)
library(stats)  # For basic statistical functions
library(graphics)  # For plotting (though not used here, included for completeness)
library(utils)  # For file operations like dir.create

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
set.seed(123)

# Load data files
load(file = "data/estimdata.Rdata")
load(file = "output/gmcfs.Rdata")

# Define constants
N_SEGMENTS <- 1000
N_CONSUMERS <- 5315  # Total sample size
N_REPLICATIONS <- 10000  # Number of replications as per Misra et al. (2019)
prices_exp1 <- c(19, 39, 59, 79, 99, 159, 199, 249, 299, 399)
acquisition_rates <- c(0.36, 0.32, 0.28, 0.28, 0.24, 0.20, 0.18, 0.17, 0.13, 0.11)
delta <- 5

# Define intervals and probabilities for v_s
intervals <- list(c(0, 19), c(19, 39), c(39, 59), c(79, 99), c(99, 159), 
                 c(159, 199), c(199, 249), c(249, 299), c(299, 399), c(399, 499))
probs <- c(0.64, 0.04, 0.04, 0.04, 0.04, 0.02, 0.01, 0.04, 0.02, 0.11)

# Initialize storage for replication results
conversion_rates <- matrix(NA, nrow = N_REPLICATIONS, ncol = 3)
colnames(conversion_rates) <- c("control", "uniform", "personalized")

# Replication loop
for (rep in 1:N_REPLICATIONS) {
  # Generate segment midpoints v_s for this replication
  v_s <- numeric(N_SEGMENTS)
  for (s in 1:N_SEGMENTS) {
    interval_index <- sample(1:10, 1, prob = probs)
    a <- intervals[[interval_index]][1]
    b <- intervals[[interval_index]][2]
    v_s[s] <- runif(1, a, b)
  }

  # Assign consumers to segments
  segment_sizes <- rep(floor(N_CONSUMERS / N_SEGMENTS), N_SEGMENTS)
  remainder <- N_CONSUMERS - sum(segment_sizes)
  if (remainder > 0) segment_sizes[1:remainder] <- segment_sizes[1:remainder] + 1
  consumer_segment <- rep(1:N_SEGMENTS, times = segment_sizes)

  # Generate individual valuations v_i
  v_i <- numeric(N_CONSUMERS)
  for (i in 1:N_CONSUMERS) {
    s <- consumer_segment[i]
    v_i[i] <- runif(1, max(0, v_s[s] - delta), min(500, v_s[s] + delta))
  }

  # Assign consumers to pricing cells
  CELL_PROBS <- c(control = 0.26, uniform = 0.27, personalized = 0.47)
  cells <- sample(names(CELL_PROBS), N_CONSUMERS, replace = TRUE, prob = CELL_PROBS)

  # Define personalized price sequence for capping
  prices_personalized <- seq(119, 499, by = 10)
  prices_personalized <- c(99, prices_personalized)

  # Extract demand estimates from loaded data
  vars <- colnames(datz)[2:(ncol(datz) - 1)]
  X <- as.matrix(datz[, vars])
  P <- datz[, "P"]
  mm <- cbind(X, P, X * (P %*% matrix(1, 1, ncol(X))))
  colnames(mm)[(ncol(X) + 2):(2 * ncol(X) + 1)] <- paste("P:", colnames(X), sep = "")
  mm_base <- as.matrix(X)
  yy <- factor(datz$FT)
  yy2 <- factor(datz$Y)
  N <- nrow(mm)

  # Compute alpha and beta using first bootstrap estimate
  X_full <- cbind(matrix(1, N, 1), mm)
  colnames(X_full)[1] <- "intercept"
  intmn_vars <- grep(":", colnames(X_full))
  priceind <- which(colnames(X_full) == "P")
  mainmn <- X_full[, -intmn_vars]
  intmn <- X_full[, intmn_vars] / X_full[, priceind]

  a <- as.matrix(mainmn[, -priceind] %*% gm.cfs[-c(intmn_vars, priceind), 1])
  b <- as.matrix(kronecker(matrix(gm.cfs[priceind, 1], nrow = 1), matrix(1, N, 1)) + 
                 intmn %*% gm.cfs[intmn_vars, 1])
  b[b >= 0] <- NA

  # Run personalized pricing using runTarg function
  share <- function(p, aa, bb) {
    1 / (1 + exp(-aa - bb * p))
  }
  profit <- function(p0, aa, bb) {
    if (is.null(dim(aa))) {
      S <- mean(share(p0, aa, bb), na.rm = TRUE)
    } else {
      S <- mean(apply(share(p0, aa, bb), 2, mean, na.rm = TRUE))
    }
    prof <- p0 * S
    return(prof)
  }
  runTarg <- function(a, b) {
    pstar <- matrix(0, nrow(a), 1)
    for (rr in 1:nrow(a)) {
      aa <- as.matrix(a[rr, ])
      bb <- as.matrix(b[rr, ])
      ptemp <- optimize(f = profit, interval = c(0, 10), aa = aa, bb = bb, maximum = TRUE)
      pstar[rr] <- ptemp$maximum * 50
      possible_p <- prices_personalized[prices_personalized <= pstar[rr]]
      pstar[rr] <- if (length(possible_p) > 0) max(possible_p) else 99
    }
    return(list(pstar = pstar))
  }
  outtarg <- runTarg(a, b)
  pstar <- outtarg$pstar

  # Resize pstar to match N_CONSUMERS
  if (length(pstar) < N_CONSUMERS) {
    pstar <- rep(pstar, length.out = N_CONSUMERS)
  }

  # Assign prices
  prices <- numeric(N_CONSUMERS)
  for (i in 1:N_CONSUMERS) {
    if (cells[i] == "control") {
      prices[i] <- 99
    } else if (cells[i] == "uniform") {
      prices[i] <- 249
    } else {
      prices[i] <- pstar[i]
    }
  }

  # Simulate purchases
  purchases <- as.integer(v_i >= prices)

  # Compute conversion rates for this replication
  conversion_rates[rep, ] <- tapply(purchases, cells, mean)
}

# Average conversion rates across replications
mean_conversion_rates <- colMeans(conversion_rates, na.rm = TRUE)
sd_conversion_rates <- apply(conversion_rates, 2, sd, na.rm = TRUE)
ci_lower <- apply(conversion_rates, 2, quantile, probs = 0.025, na.rm = TRUE)
ci_upper <- apply(conversion_rates, 2, quantile, probs = 0.975, na.rm = TRUE)

# Create summary data frame
summary_stats <- data.frame(
  Cell = names(mean_conversion_rates),
  MeanConversionRate = mean_conversion_rates,
  SDConversionRate = sd_conversion_rates,
  CI_Lower = ci_lower,
  CI_Upper = ci_upper,
  SampleSize = table(cells)[names(mean_conversion_rates)]
)

# Save data from the last replication (for reference)
simulated_exp2_data <- data.frame(
  ConsumerID = 1:N_CONSUMERS,
  Segment = consumer_segment,
  TrueValuation = v_i,
  Cell = cells,
  Price = prices,
  Purchase = purchases
)
save(simulated_exp2_data, file = paste0(data_dir, "simulated_exp2_data.Rdata"))

# Output results
cat("Simulated Experiment 2 Results (Averaged over 10,000 Replications):\n")
print(summary_stats)

# Compare with reported values from Dubé and Misra (2023)
reported <- data.frame(
  Cell = c("control", "uniform", "personalized"),
  ReportedConversion = c(0.23, 0.15, 0.15)
)
comparison <- merge(summary_stats[, c("Cell", "MeanConversionRate")], reported, by = "Cell", all.x = TRUE)
cat("\nComparison with Reported Values:\n")
print(comparison)