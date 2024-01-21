## Plumber API using RapiDoc



library(plumber)
library(rapidoc)
library(tidymodels)
library(ranger)
library(purrr)
library(readr)
library(dplyr)
library(rlang)
library(ggplot2)

glass = readRDS("../glass.rds")
glass_data = readr::read_csv("../glass.csv")

#* @apiTitle Glass Identification
#* @apiDescription An API to classify type of glasses (whether it is either from a building or a car) based on its components
#* @apiContact list(name = "API Support", url = "https://github.com/stesiam/GlassIdentificationAPI")
#* @apiLicense list(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0.html")
#* @apiVersion 1.0.1
#* @apiTag Statistics Descriptive Statistics
#* @apiTag Plot Visualize some 
#* @apiTag ML Machine Learning model


#* @tag Statistics
#' Calculate mean value for a variable in a dataset
#' Available values are : RI, Na, Mg, Al, Si, K, Ca, Ba, Fe
#' @param data The dataset (glass_data)
#' @param var The selected variable (RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) for which the mean is calculated
#' @get /mean_data
#' @serializer unboxedJSON
function(data = "glass_data", var) {
  data <- switch(data,
                 "glass_data" = glass_data,
                 stop("Unknown data"))
  
  result <- data %>%
    summarise(mean_value = mean(!!rlang::sym(var), na.rm = TRUE))
  
  return(result)
}


#* @tag Statistics
#' Calculate the variance for a variable in a dataset
#' Available values are: glass_data, iris, mtcars
#' @param data The dataset (glass_data)
#' @param selected_var The selected variable (RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) for which the variance is calculated
#' @get /var_data
#' @serializer unboxedJSON
function(data = "glass_data", selected_var) {
  
  data <- switch(data,
                 "glass_data" = glass_data,
                 stop("Unknown data"))
  
  result <- data %>%
    summarise(variance_value = var(!!rlang::sym(selected_var), na.rm = TRUE))
  
  return(result)
}

#* @tag Statistics
#' Calculate maximum value for a variable in a dataset
#' Available values are : RI, Na, Mg, Al, Si, K, Ca, Ba, Fe
#' @param data The dataset (glass_data)
#' @param var The selected variable (RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) for which the max value is calculated
#' @get /max_data
#' @serializer unboxedJSON
function(data = "glass_data", var) {
  data <- switch(data,
                 "glass_data" = glass_data,
                 stop("Unknown data"))
  
  result <- data %>%
    summarise(mean_value = mean(!!rlang::sym(var), na.rm = TRUE))
  
  return(result)
}

#* @tag Statistics
#' Calculate minimum value for a variable in a dataset
#' Available values are : RI, Na, Mg, Al, Si, K, Ca, Ba, Fe
#' @param data The dataset (glass_data)
#' @param var The selected variable (RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) for which the min value is calculated
#' @get /min_data
#' @serializer unboxedJSON
function(data = "glass_data", var) {
  data <- switch(data,
                 "glass_data" = glass_data,
                 stop("Unknown data"))
  
  result <- data %>%
    summarise(mean_value = mean(!!rlang::sym(var), na.rm = TRUE))
  
  return(result)
}

#* @tag Plot
#' @get /histogram_test
#' @serializer png
hist_response <- function(var, bins = 20, title, subtitle, caption){
  b <- ggplot(glass_data, aes_string(x = var)) +
    geom_histogram(bins = as.integer(bins)) +
    labs(
      title = title,
      subtitle = subtitle,
      caption = caption
    ) + 
    theme_classic()
  
  print(b)
}


#* @tag ML
#* Return the predicted class (window/non-window)
#* @param RI:dbl Number of uninterrupted capital letters
#* @param Na:dbl Percentage of dollar signs
#* @param Mg:dbl Percentage of bang
#* @param Al:dbl Percentage of "money"
#* @param Si:dbl Percentage of "000"
#* @param K:dbl Percentage of "make"
#* @param Ca:dbl Percentage of "money"
#* @param Ba:dbl Percentage of "000"
#* @param Fe:dbl Percentage of "make"
#* @get /predict_result
function(RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) {
  model_data = dplyr::tibble(
    RI = as.numeric(RI),
    Na = as.numeric(Na),
    Mg = as.numeric(Mg),
    Al = as.numeric(Al),
    Si = as.numeric(Si),
    K = as.numeric(K),
    Ca = as.numeric(Ca),
    Ba = as.numeric(Ba),
    Fe = as.numeric(Fe)
  )
  
  predict(glass, model_data) %>%
    purrr::pluck(1)
}

#* @tag ML
#* Return the probability of each class (window glass / non-window glass)
#* @param RI:dbl Number of uninterrupted capital letters
#* @param Na:dbl Percentage of dollar signs
#* @param Mg:dbl Percentage of bang
#* @param Al:dbl Percentage of "money"
#* @param Si:dbl Percentage of "000"
#* @param K:dbl Percentage of "make"
#* @param Ca:dbl Percentage of "money"
#* @param Ba:dbl Percentage of "000"
#* @param Fe:dbl Percentage of "make"
#* @get /predict_result_with_probs
function(RI, Na, Mg, Al, Si, K, Ca, Ba, Fe) {
  model_data = dplyr::tibble(
    RI = as.numeric(RI),
    Na = as.numeric(Na),
    Mg = as.numeric(Mg),
    Al = as.numeric(Al),
    Si = as.numeric(Si),
    K = as.numeric(K),
    Ca = as.numeric(Ca),
    Ba = as.numeric(Ba),
    Fe = as.numeric(Fe)
  )
  
  predict(glass, model_data,type="prob") %>%
    tidyr::pivot_longer(., cols = everything(), names_to = "Result", values_to = "prob") %>% 
    mutate(., Result = stringr::str_replace_all(Result, ".*_", ""))
}

# Programmatically alter your API
#* @plumber
function(pr) {
  pr %>%
    # Overwrite the default serializer to return unboxed JSON
    pr_set_docs("rapidoc",
                ## Attributes
                render_style="view",
                theme= "light", 
                layout="column",
                heading_text = "Glass API"
    )
}