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
library(httr)
library(plyr)
library(rvest)
library(stringr)
library(XML)
