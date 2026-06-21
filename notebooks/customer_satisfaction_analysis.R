# ============================================================
# Customer Satisfaction Analysis — Furniture Retail
# Author: Bishal Ranjan Bora
# University of Warwick — MSc Business Analytics
# ============================================================

# ── 1. Load Libraries ────────────────────────────────────────
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(naniar)
library(car)
library(emmeans)
library(dplyr)

# ── 2. Load & Inspect Data ───────────────────────────────────
cust_data <- read.csv("data/cust_satisfaction.csv")

str(cust_data)
summary(cust_data)

# ── 3. Data Cleaning ─────────────────────────────────────────

# Check for missing values
cat("Missing values per column:\n")
print(colSums(is.na(cust_data)))
# No missing values found

# Check for duplicates
cat("\nDuplicate rows:", sum(duplicated(cust_data)), "\n")

# Set SES_category as factor with defined levels
cust_data$SES_category <- factor(cust_data$SES_category,
                                  levels = c("Low", "Medium", "High"))

cat("\nRecords in dataset:", nrow(cust_data), "\n")

# ── 4. Outlier Detection ─────────────────────────────────────
numeric_vars <- c("customer.satisfaction", "staff.satisfaction", "delivery.time")

outlier_results <- map_df(numeric_vars, function(var) {
  Q1 <- quantile(cust_data[[var]], 0.25, na.rm = TRUE)
  Q3 <- quantile(cust_data[[var]], 0.75, na.rm = TRUE)
  IQR_value <- Q3 - Q1
  data.frame(
    Variable = var,
    Outliers = sum(
      cust_data[[var]] > Q3 + 1.5 * IQR_value |
      cust_data[[var]] < Q1 - 1.5 * IQR_value,
      na.rm = TRUE
    )
  )
})

cat("\nOutlier Summary:\n")
print(outlier_results)
# Only delivery.time has outliers — retained for analysis

# Boxplots to visualise outliers
box_plots <- lapply(numeric_vars, function(var) {
  ggplot(cust_data, aes(x = "", y = .data[[var]])) +
    geom_boxplot(outlier.color = "red", outlier.shape = 16,
                 outlier.size = 2, fill = "#93c5fd") +
    labs(title = paste("Boxplot of", var), x = "", y = var) +
    theme_minimal()
})

do.call(grid.arrange, c(box_plots, ncol = 3))

# ── 5. Exploratory Data Analysis ─────────────────────────────

# Histograms for numeric variables
hist_plots <- lapply(numeric_vars, function(var) {
  ggplot(cust_data, aes(x = .data[[var]])) +
    geom_histogram(bins = 20, fill = "#1B3A5C", color = "white", alpha = 0.8) +
    labs(title = paste("Distribution of", var), x = var, y = "Count") +
    theme_minimal()
})

do.call(grid.arrange, c(hist_plots, ncol = 3))

# Bar plot for SES category
ggplot(cust_data, aes(x = SES_category, fill = SES_category)) +
  geom_bar() +
  scale_fill_manual(values = c("Low" = "#ef4444", "Medium" = "#f97316", "High" = "#1B3A5C")) +
  labs(title = "Store Count by SES Category", x = "SES Category", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")

# Bar plot for new product range
ggplot(cust_data, aes(x = factor(new_range), fill = factor(new_range))) +
  geom_bar() +
  scale_fill_manual(values = c("FALSE" = "#94a3b8", "TRUE" = "#2E7D8C")) +
  labs(title = "Stores With vs Without New Product Range",
       x = "New Product Range", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")

# ── 6. Correlation Analysis ──────────────────────────────────
cor_matrix <- cust_data %>%
  select(customer.satisfaction, staff.satisfaction, delivery.time) %>%
  cor()

cat("\nCorrelation Matrix:\n")
print(round(cor_matrix, 3))

# Scatter plots with regression lines
scatter1 <- ggplot(cust_data, aes(x = staff.satisfaction, y = customer.satisfaction)) +
  geom_point(alpha = 0.6, color = "#2E7D8C") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Staff Satisfaction vs Customer Satisfaction",
       x = "Staff Satisfaction", y = "Customer Satisfaction") +
  theme_minimal()

scatter2 <- ggplot(cust_data, aes(x = delivery.time, y = customer.satisfaction)) +
  geom_point(alpha = 0.6, color = "#1B3A5C") +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Delivery Time vs Customer Satisfaction",
       x = "Delivery Time", y = "Customer Satisfaction") +
  theme_minimal()

grid.arrange(scatter1, scatter2, ncol = 2)

# ── 7. Individual Linear Regressions ─────────────────────────
cat("\n══ INDIVIDUAL LINEAR REGRESSIONS ══\n")

# Staff satisfaction
lm_staff <- lm(customer.satisfaction ~ staff.satisfaction, data = cust_data)
cat("\nCustomer Satisfaction ~ Staff Satisfaction:\n")
print(summary(lm_staff))

# Delivery time
lm_delivery <- lm(customer.satisfaction ~ delivery.time, data = cust_data)
cat("\nCustomer Satisfaction ~ Delivery Time:\n")
print(summary(lm_delivery))

# ── 8. Multiple Linear Regression ────────────────────────────
cat("\n══ MULTIPLE LINEAR REGRESSION ══\n")

lm_multiple <- lm(customer.satisfaction ~ staff.satisfaction +
                    delivery.time + new_range + SES_category,
                  data = cust_data)
print(summary(lm_multiple))

# VIF — check for multicollinearity
cat("\nVariance Inflation Factors (VIF):\n")
print(vif(lm_multiple))
# All values well below 5 — no multicollinearity concern

# ── 9. Interaction Analysis ──────────────────────────────────
cat("\n══ INTERACTION ANALYSIS: Delivery Time x SES ══\n")

# Interaction model
lm_interaction <- lm(customer.satisfaction ~ delivery.time * SES_category,
                     data = cust_data)
print(summary(lm_interaction))

# ANOVA — compare base model vs interaction model
cat("\nANOVA Model Comparison (base vs interaction):\n")
print(anova(lm_delivery, lm_interaction))
# Significant interaction confirms SES moderates delivery time effect

# VIF for interaction model
cat("\nVIF for Interaction Model:\n")
print(vif(lm_interaction))

# Estimated Marginal Means by SES
cat("\nEstimated Marginal Means by SES Category:\n")
emmeans_result <- emmeans(lm_interaction, ~ delivery.time | SES_category)
print(summary(emmeans_result))

# ── 10. Interaction Plot ─────────────────────────────────────
ggplot(cust_data, aes(x = delivery.time, y = customer.satisfaction,
                      color = SES_category)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  scale_color_manual(values = c("Low" = "#ef4444",
                                "Medium" = "#f97316",
                                "High" = "#1B3A5C")) +
  labs(
    title    = "Interaction of Delivery Time and SES on Customer Satisfaction",
    subtitle = "Delivery time has a stronger negative effect in Low SES stores",
    x        = "Delivery Time",
    y        = "Customer Satisfaction",
    color    = "SES Category"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = "gray50", hjust = 0.5)
  )

# ── 11. Summary ──────────────────────────────────────────────
cat("\n════════════════════════════════════════════════════════\n")
cat("SUMMARY OF FINDINGS\n")
cat("════════════════════════════════════════════════════════\n")
cat(sprintf("Staff Satisfaction → Customer Satisfaction: +0.746 per unit (R² = %.3f)\n",
            summary(lm_staff)$r.squared))
cat(sprintf("Delivery Time → Customer Satisfaction:      -0.029 per unit (R² = %.3f)\n",
            summary(lm_delivery)$r.squared))
cat("\nMultiple Regression R-squared:", round(summary(lm_multiple)$r.squared, 3), "\n")
cat("\nKey finding: Delivery time has a significantly stronger negative\n")
cat("effect on customer satisfaction in LOW SES stores vs HIGH SES stores.\n")
cat("Recommendation: Prioritise delivery optimisation in low SES locations.\n")
cat("════════════════════════════════════════════════════════\n")
