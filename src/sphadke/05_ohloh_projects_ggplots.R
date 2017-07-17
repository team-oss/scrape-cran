####################################
#### OpenHub projects: analysis ####
####################################
# This code runs profiling code and produces descriptives for project tables
# Assign the file of interest to "data" to have the code run without changing names

#### Created by: sphadke
#### Creted on: 07/06/2017
#### Last edited on: 07/07/2017


####################
#### Cleanup
####################
rm(list=ls())
gc()
set.seed(312)


####################
#### R Setup
####################
library(ggplot2)
library(gtools)
library(lubridate)
library(network)
library(reshape2)
library(scales)
library(SnowballC)
library(stringr)
library(tm)
library(wordcloud)


## Data import and rename
# random projects
# load("~/git/oss/data/oss/working/openhub/randomProjects/all_random_projects_table.RData")

# relevant projects
load("~/git/oss/data/oss/working/openhub/relevantProjects/projectRelevantMaster.RData")

#data <- randomProjectTable
data <- projectRelevantMaster
#rm(randomProjectTable)
rm(projectRelevantMaster)


####################
#### Data quality check
#### And cleanup
####################

## Convert blanks and "NA"s to NAs
data[data == ""] <- NA
data[data == "\n  "] <- NA
data[data == "NA"] <- NA


## Make all date columns lubridate compatible
data$created_at <- as.POSIXct(data$created_at, format = '%Y-%m-%dT%H:%M:%SZ')
data$updated_at <- as.POSIXct(data$updated_at, format = '%Y-%m-%dT%H:%M:%SZ')
data$last_analysis_update <- as.POSIXct(data$last_analysis_update, format = '%Y-%m-%dT%H:%M:%SZ')
data$last_source_code_access <- as.POSIXct(data$last_source_code_access, format = '%Y-%m-%dT%H:%M:%SZ')


## Make relevant columns numeric
data$user_count <- as.numeric(data$user_count)
data$average_rating <- as.numeric(data$average_rating)
data$rating_count <- as.numeric(data$rating_count)
data$review_count <- as.numeric(data$review_count)
data$twelve_month_contributor_count <- as.numeric(data$twelve_month_contributor_count)
data$total_contributor_count <- as.numeric(data$total_contributor_count)
data$twelve_month_commit_count <- as.numeric(data$twelve_month_commit_count)
data$total_commit_count <- as.numeric(data$total_commit_count)
data$total_code_lines <- as.numeric(data$total_code_lines)


## Completely empty rows
num_empty_rows <- length(data$licenses[apply(data[,2:ncol(data)], 1, function(x){all(is.na(x))}) == TRUE])
rm(num_empty_rows)


####
## Remove the fully empty rows
####
clean_data <- data[!apply(data[2:33], 1, function(x){all(is.na(x))}), ]
rm(data)


# Separating out the factoid columns
clean_data$age <- NA
clean_data$team_size <- NA
clean_data$activity <- NA
clean_data$comments <- NA

for(i in 1:nrow(clean_data)){

  if(length(grep("Age", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_data$age[i] <- unlist(str_split(grep("Age", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE), "Age"))[2]
  }

  if(length(grep("Team", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_data$team_size[i] <- unlist(str_split(grep("Team", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE), "Size"))[2]
  }

  if(length(grep("Activity", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_data$activity[i] <- unlist(str_split(grep("Activity", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE), "Activity"))[2]
  }

  if(length(grep("Comments", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_data$comments[i] <- unlist(str_split(grep("Comments", unlist(str_split(clean_data$factoids[i], ";")), value = TRUE), "Comments"))[2]
  }

  print(i)
}

table(clean_data$age)
table(clean_data$team_size)
table(clean_data$activity)
table(clean_data$comments)

clean_data$age <- as.factor(clean_data$age)
clean_data$activity <- as.factor(clean_data$activity)
clean_data$team_size <- as.factor(clean_data$team_size)
clean_data$comments <- as.factor(clean_data$comments)


####
## Let's try some ggplots with factoids
####
#ggplot(aes(y = boxthis, x = f2, fill = f1), data = df) + geom_boxplot()

activity_df <- melt(data = clean_data, id.vars = c('project_name', 'activity'), measure.vars = c('total_code_lines'))

colnames(activity_df)[3] <- "total_code_lines"
#levels(activity_df$activity) <- c("Affiliated", "Outside")

ggplot(data = activity_df, aes(x = activity, y = value, fill = activity)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="none") +
  #ggtitle(paste0("Affiliators: Total=", sum(organization$affiliators))) +
  labs(x = "Activity level", y = "Total code lines") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

