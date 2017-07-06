####################################
#### OpenHub projects: analysis ####
####################################
# This code runs profiling code and produces descriptives for project tables

#### Created by: sphadke
#### Creted on: 07/06/2017
#### Last edited on: 07/06/2017


####################
#### Cleanup
####################
rm(list=ls())
gc()
set.seed(312)


####################
#### R Setup
####################
library(plyr)
library(stringr)

load("~/git/oss/data/oss/working/openhub/randomProjects/all_random_projects_table.RData")


####################
#### Data quality check
####################

num_empty_rows <- abc

for(i in 1:ncol(incident_table)){
  x <- incident_table[,i]

  # Make all blanks NAs
  x[x == ""] <- NA

  name <- colnames(incident_table)[i]
  class <- class(x)

  # Proportion of missing values
  miss <- round(sum(is.na(x))*100/nrow(incident_table), digits = 2)

  # How many unique values to the variable?
  vals <- length(unique(x))
  # summary <- summary(x)
  if(vals <= 10){
    tab <- table(x)
    print(tab)
  }
  print(c(name, class, miss, vals))
}


