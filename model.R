library(readr)
library(dplyr)
library(forcats)
library(tidymodels)
library(themis)

library(ranger) # Engine used for Random Forest model


glass = readr::read_csv("glass.csv",
                        col_names = c("ID", "RI", "Na", "Mg", "Al", "Si","K", "Ca", "Ba", "Fe", "glass_type"))


glass$glass_type <- glass$glass_type %>%
  as.factor(.) %>%
  fct_recode(
    "window" = "1",
    "window" = "2",
    "window" = "3",
    "window" = "4",
    "non-window" = "5",
    "non-window" = "6",
    "non-window" = "7"
  )

freqtable = glass$glass_type %>% table() %>% as.data.frame() %>%
  rename(
    "type" = ".",
    "freq" = "Freq"
  )
ggplot2::ggplot(data = freqtable, aes(x = type, y = freq, fill = type)) +
  geom_col() +
  labs(
    title = "Type of Glass",
    subtitle = "There is a significant overpresentation of window glasses over <br> non-window ones.
Prior modelling it is advised to deal with that<br> imbalance of data to get more reliable results.",
    caption = "stesiam, 2023",
    x = "",
    y = "Observations"
  ) +
  geom_text(aes(x = type, y = freq + 6, label = freq)) +
  theme_bw() + 
  theme(
    plot.title = element_markdown(family = "serif"),
    plot.subtitle = element_markdown(family = "serif"),
    plot.caption = element_markdown(family = "serif"),
    legend.position = c(0.8, 0.8),
    legend.title = element_blank(),
    panel.grid = element_blank()
  )


# Split dataset

set.seed(200)

split <- rsample::initial_split(glass, strata = glass_type, prop = 0.75)
train <- rsample::training(split)
test <- rsample::testing(split)

## Build recipe

# There is a relative unbalance in data response. 
#

rf_rec <- recipe(glass_type ~ ., data = train) %>%
  step_rm("ID") %>%
  step_smote(glass_type)


  
## Preview changes
prep_rec = prep(rf_rec)
juice_rec = juice(prep_rec)

## Build Random Forest model

rf_model <- rand_forest(
  mtry = tune(),
  trees = 500,
  min_n = tune()
) %>%
  set_mode("classification") %>%
  set_engine("ranger")

## Build workflow

rf_wf <- workflow() %>%
  add_recipe(rf_rec) %>%
  add_model(rf_model)


## Create CV 

set.seed(234)
trees_folds <- vfold_cv(train, v = 10)

## Tune parameters

doParallel::registerDoParallel()
set.seed(345)
tune_res <- tune_grid(
  rf_wf,
  resamples = trees_folds,
  control = control_resamples(
    save_pred = TRUE),
  grid = 120
)

## Evaluate cv 

tune_res %>%
  collect_metrics(summarize = T)
best_auc <- select_best(tune_res, "roc_auc")

# Importance of variables

library(vip)

final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(glass_type ~ .,
      data = juice_rec
  ) %>%
  vip(geom = "point") + 
  theme_classic()



## Evaluate test performance

final_rf <- finalize_model(
  rf_model,
  best_auc
)

final_rf

final_wf <- workflow() %>%
  add_recipe(rf_rec) %>%
  add_model(final_rf)

final_res <- final_wf %>%
  last_fit(split)

## Evaluate full dataset

final_res %>%
  collect_metrics()

## Export / Save ML model

final_model_rf = fit(final_wf, glass)
saveRDS(final_model_rf, "glass.rds")
