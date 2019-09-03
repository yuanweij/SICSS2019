#### Trees Replication ####

# Installing packages

# install.packages("dplyr")
# install.packages("haven")
# install.packages("readxl")
# install.packages("readr")
# install.packages("stringr")
# install.packages("fastDummies")
# install.packages("caret")
# install.packages("tree")

#### Libraries #### 

suppressPackageStartupMessages(
  
  {

    library(dplyr)
    library(gridExtra)
    library(haven)
    library(rpart)
    library(readxl)
    library(readr)
    library(stringr)
    library(fastDummies)
    library(caret)
    library(tree)
    library(rattle)
    library(rpart.plot)
    library(RColorBrewer)
    
    
  }

)


#### Cleaning Data #### 

# Importing data 

df = read_csv("sf-crime/train.csv")

# Lower-casing the column names 

colnames(df) = tolower(colnames(df))

# Removing address fields that end in "/ " --- they do not have a second 
# street anyways and it will make cleaning the data much easier. 

df$address[str_sub(df$address, start = -2) == " /"] = 
  str_replace(df$address[str_sub(df$address, start = -2) == " /"],
              " /", "")

# Generating covariates for analysis --- new ones will be 
# year, month, hour, block, and street

df_edit = df %>% mutate(year = factor(substring(dates, 1, 4)), 
                        dayofweek = factor(dayofweek),
                        month = factor(substring(dates, 6, 7)),
                        hour = factor(substring(dates, 12, 13)),
                        block = 
                          factor(ifelse(grepl(x = address, "Block") == TRUE, 
                                        str_trim(str_extract(string = 
                                                               sfc_train$address,
                                                             ".*(?=Block)")), 0)),
                        street1 = 
                          factor(ifelse(grepl(x = address, "/") == TRUE,
                                        (do.call(
                                          rbind.data.frame,
                                          str_split(address, "/")
                                        ) %>% `colnames<-` (c("street1",
                                                              "street2")) %>% 
                                          dplyr::select(1) %>% 
                                          as.matrix() %>% 
                                          as.vector() %>% 
                                          str_trim() %>% 
                                          as.character()),
                                        str_extract(string = address,
                                                    "\\w+\\s\\w+$"))),
                        street2 = 
                          factor(ifelse(grepl(x = address, "/") == TRUE,
                                        (do.call(
                                          rbind.data.frame,
                                          str_split(address, "/")
                                        ) %>% `colnames<-` (c("street1",
                                                              "street2")) %>% 
                                          dplyr::select(1) %>% 
                                          as.matrix() %>% 
                                          as.vector() %>% 
                                          str_trim() %>% 
                                          as.character()),
                                        str_extract(string = address,
                                                    "\\w+\\s\\w+$"))),
                        pddistrict = factor(pddistrict)) %>% 
  filter(category %in% c("LARCENY/THEFT", "OTHER OFFENSES", "NON-CRIMINAL",
                          "ASSAULT", "DRUG/NARCOTIC", "VEHICLE THEFT",
                           "VANDALISM", "WARRANTS", "BURGLARY", "SUSPICIOUS OCC")
  ) %>% 
  mutate(category = factor(category)) %>% 
  dummy_columns(select_columns = c("pddistrict", "hour",
                                   "month", "dayofweek",
                                   "year"))


#c("LARCENY/THEFT", "OTHER OFFENSES", "NON-CRIMINAL",
#  "ASSAULT", "DRUG/NARCOTIC", "VEHICLE THEFT",
#  "VANDALISM", "WARRANTS", "BURGLARY", "SUSPICIOUS OCC")

#### Splitting Data #### 

# Splitting data into test and training datasets --- 60% of data will be 
# training data 

set.seed(20190609) # discuss? 

part_list = createDataPartition(1:nrow(df_edit), times = 1, p = 0.6,
                                list = FALSE) %>% 
  as.vector() %>% 
  as.numeric()

train = df_edit[part_list, 
                grep(x = colnames(df_edit),
                     "category|^month_|^hour_|^dayofweek_|^year_|^pddistrict_|x|y",
                     value = FALSE)]

cv = df_edit[!(1:nrow(df_edit) %in% part_list), 
               grep(x = colnames(df_edit),
                    "category|^month_|^hour_|^dayofweek_|^year_|^pddistrict_|x|y",
                    value = TRUE)]

#### Fitting a simple tree #### 

# Fitting a tree model rpart --- the default split selection mechanism here 
# is gini impurity

tree_out = rpart(category ~ ., data = train, method = "class",
                      control = rpart.control(maxdepth = 4,
                                              minbucket = 1,
                                              cp = .0001),
                 parms = list(split = "information"),
                 minsplit = 2,
                 minbucket = 1)

fancyRpartPlot(tree_out, caption = NULL)

# First, we're going to assess how well the model performs in predicting 
# the training data. One measure of prediction error is the log loss. 

prob_matrix = predict(tree_out, train, type = "prob")

# We want to take the log loss with respect to a particular category. Each 
# row in the probability matrix is the probability that a particular observation
# is a particular crime category. 

sto_vector = rep(NA, nrow(prob_matrix))

for (i in 1:length(sto_vector)) {

  sto_vector[i] = prob_matrix[i, names(prob_matrix[1, ]) == train$category[i]]

}

logloss = abs(sum(log(sto_vector)) / length(sto_vector))

# We can also look at the confusion matrix 

pred_train = predict(tree_out, train, type = "class")
