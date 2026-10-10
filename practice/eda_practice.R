# =============================================================================
# Exploratory Data Analysis & Visualisation — beginner practice file
# Course: EDA & Visualisation (Data Science)
# Tip: run line-by-line with Cmd+Enter (Mac) or Ctrl+Enter (Windows)
# =============================================================================

# ---- 0. Packages -------------------------------------------------------------
# Install once (uncomment if needed), then load each session:
# install.packages(c("tidyverse", "janitor", "skimr"))

library(tidyverse)  # dplyr + ggplot2 + readr, etc.
library(janitor)    # clean_names(), tabyl()
library(skimr)      # quick numeric/categorical summaries


# ---- 1. Load a built-in dataset ---------------------------------------------
# mtcars: cars (rows) × features (columns). Good starter for EDA.
data(mtcars)
cars <- mtcars |>
  rownames_to_column("model") |>
  clean_names()

# Peek at structure
glimpse(cars)
head(cars, 8)


# ---- 2. First-pass EDA: what do we have? ------------------------------------
# Dimensions, types, missing values
dim(cars)
summary(cars)
skim(cars)

# Count missing values per column (should be 0 for mtcars)
colSums(is.na(cars))


# ---- 3. Univariate exploration ----------------------------------------------
# Numeric: centre and spread
cars |>
  summarise(
    mean_mpg = mean(mpg),
    median_mpg = median(mpg),
    sd_mpg = sd(mpg),
    min_mpg = min(mpg),
    max_mpg = max(mpg)
  )

# Histogram — distribution of mpg
ggplot(cars, aes(x = mpg)) +
  geom_histogram(bins = 10, fill = "steelblue", colour = "white") +
  labs(
    title = "Distribution of miles per gallon",
    x = "Miles per gallon (mpg)",
    y = "Count"
  ) +
  theme_minimal()

# Boxplot — spot outliers easily
ggplot(cars, aes(y = mpg)) +
  geom_boxplot(fill = "steelblue") +
  labs(title = "mpg boxplot", y = "mpg") +
  theme_minimal()


# ---- 4. Categorical / grouped views -----------------------------------------
# Treat cylinders as a factor (category)
cars <- cars |>
  mutate(cyl = factor(cyl))

# Frequency table
cars |> count(cyl, sort = TRUE)

# Bar chart of cylinder counts
ggplot(cars, aes(x = cyl)) +
  geom_bar(fill = "darkorange") +
  labs(
    title = "Cars by number of cylinders",
    x = "Cylinders",
    y = "Count"
  ) +
  theme_minimal()


# ---- 5. Bivariate relationships ---------------------------------------------
# Scatter: horsepower vs mpg (expect a negative relationship)
ggplot(cars, aes(x = hp, y = mpg)) +
  geom_point(aes(colour = cyl), size = 3, alpha = 0.8) +
  geom_smooth(method = "lm", se = TRUE, colour = "grey30") +
  labs(
    title = "Fuel efficiency vs horsepower",
    x = "Horsepower",
    y = "Miles per gallon",
    colour = "Cylinders"
  ) +
  theme_minimal()

# Correlation (numeric columns only)
cars |>
  select(where(is.numeric)) |>
  cor(use = "complete.obs") |>
  round(2)


# ---- 6. Group comparisons ---------------------------------------------------
# Mean mpg by cylinder group
cars |>
  group_by(cyl) |>
  summarise(
    n = n(),
    mean_mpg = mean(mpg),
    mean_hp = mean(hp),
    .groups = "drop"
  )

# Boxplots by group
ggplot(cars, aes(x = cyl, y = mpg, fill = cyl)) +
  geom_boxplot(show.legend = FALSE) +
  labs(
    title = "mpg by cylinder count",
    x = "Cylinders",
    y = "mpg"
  ) +
  theme_minimal()


# ---- 7. A small “EDA checklist” you can reuse -------------------------------
# For any new dataset, try this order:
#   1. glimpse() / skim()          — shape & types
#   2. missingness                 — colSums(is.na())
#   3. univariate plots            — hist / box / bar
#   4. relationships               — scatter, cor, group_by
#   5. write 2–3 sentences         — what surprised you?

# Practice prompt: replace mtcars with another built-in set, e.g.
#   data(iris)  or  data(diamonds)  # diamonds needs ggplot2 (in tidyverse)
# and repeat steps 2–6.


# ---- 8. Optional: save a plot ------------------------------------------------
# ggsave("mpg_vs_hp.png", width = 7, height = 5, dpi = 150)
