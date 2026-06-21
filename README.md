# Customer Satisfaction Analysis — Furniture Retail

**Tools:** R · tidyverse · ggplot2 · Multiple Regression · ANOVA · Interaction Analysis · emmeans  
**Domain:** Retail Analytics · Customer Experience · Socioeconomic Segmentation  
**Context:** Individual Assignment — Business Statistics (IB94X0), University of Warwick MSc Business Analytics  
**Status:**  Complete

---

##  Project Overview

This project analyses the factors influencing customer satisfaction at a furniture retail company. The focus is on understanding how **staff satisfaction**, **delivery times**, **new product ranges**, and **store socioeconomic status (SES)** affect customer satisfaction — and whether the relationship between delivery time and satisfaction varies across different SES segments.

**Business Question:** What drives customer satisfaction, and does the impact of delivery time differ across high, medium, and low SES store locations?

---

##  Key Findings

### Individual Predictors

| Predictor | Effect on Customer Satisfaction | R² | Significance |
|---|---|---|---|
| Staff Satisfaction | +0.746 per unit increase | 20.6% | p < 0.001 |
| Delivery Time | -0.029 per unit increase | 6.7% | p < 0.05 |

### Multiple Regression Model

| Predictor | Coefficient | Significance |
|---|---|---|
| Staff Satisfaction | +0.35 | p < 0.001 |
| Delivery Time | Negative (significant) | p < 0.05 |
| New Product Range | Not significant | — |
| SES (Medium vs High) | Significantly higher | p < 0.05 |
| SES (Low vs High) | Marginally lower | p ≈ 0.05 |

### Interaction Effect (Key Finding)
The ANOVA comparison confirmed a **significant interaction between delivery time and SES category** (p < 0.001) — meaning delivery time has a **more pronounced negative effect on customer satisfaction in low SES stores** than high SES stores.

---

##  Repository Structure

```
customer-satisfaction-analysis/
│
├── notebooks/
│   └── customer_satisfaction_analysis.R    # Full R analysis
│
└── README.md
```

---

##  Methodology

### 1. Data Cleaning & EDA
- No missing values found in the dataset
- Outlier detection using IQR method — only `delivery.time` had outliers (retained for analysis)
- Histograms for customer satisfaction, staff satisfaction, delivery time
- Bar plots for new product range and SES category distributions

### 2. Correlation Analysis
- Staff satisfaction positively correlated with customer satisfaction
- Delivery time negatively correlated with customer satisfaction
- Scatter plots with regression lines for visual confirmation

### 3. Regression Modelling
- Individual linear regressions for each predictor
- Multiple linear regression combining all predictors
- VIF check confirmed no multicollinearity (all GVIF values well below 5)

### 4. Interaction Analysis
- Compared base delivery time model vs interaction model using ANOVA
- Interaction model: `customer.satisfaction ~ delivery.time * SES_category`
- Used `emmeans` package to compute estimated marginal means by SES group
- Interaction plot confirmed SES moderates the delivery time–satisfaction relationship

---

##  Key Insight — SES Moderates Delivery Time Impact

```
High SES stores:   Delivery time has MINIMAL impact on satisfaction
Medium SES stores: Moderate negative effect
Low SES stores:    STRONGEST negative effect of delivery time on satisfaction
```

This means a **one-size-fits-all delivery strategy won't work**. Low SES customers are most sensitive to delays and should be prioritised in delivery optimisation efforts.

---

##  Sample Code

```r
# Interaction model
lm_interaction <- lm(customer.satisfaction ~ delivery.time * SES_category,
                     data = cust_data)
summary(lm_interaction)

# ANOVA model comparison
anova(lm_delivery, lm_interaction)

# Estimated Marginal Means by SES
emmeans_interaction <- emmeans(lm_interaction, ~ delivery.time | SES_category)
summary(emmeans_interaction)

# Interaction plot
ggplot(cust_data, aes(x = delivery.time, y = customer.satisfaction,
                      color = SES_category)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Interaction of Delivery Time and SES on Customer Satisfaction",
       x = "Delivery Time", y = "Customer Satisfaction") +
  theme_minimal()
```

---

##  Business Recommendations

1. **Invest in staff satisfaction** — it's the strongest driver of customer satisfaction (R² = 20.6%), and every 1-unit improvement drives +0.35 units of customer satisfaction in the full model
2. **Prioritise delivery time reduction in low SES stores** — the interaction effect shows this is where delays hurt most
3. **New product range has no significant effect** — resources spent on new ranges may be better directed at staff training or logistics
4. **SES-specific strategies** — medium SES stores outperform high SES stores on satisfaction; understanding what drives this could inform broader strategy

---

##  Tools & Packages

```r
library(tidyverse)   # Data manipulation
library(ggplot2)     # Visualisation
library(gridExtra)   # Multi-panel plots
library(car)         # VIF multicollinearity check
library(emmeans)     # Estimated marginal means
library(dplyr)       # Data wrangling
library(naniar)      # Missing value analysis
```

---

##  Contact

**Bishal Ranjan Bora**  
[LinkedIn](https://linkedin.com/in/bishalbora) | [Email](mailto:bora.vishal.15@gmail.com) | [GitHub](https://github.com/bishalbora1998)
