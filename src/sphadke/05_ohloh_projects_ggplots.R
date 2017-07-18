####################################
#### OpenHub projects: analysis ####
####################################
# This code runs profiling code and produces descriptives for project tables
# Assign the file of interest to "data" to have the code run without changing names

#### Created by: sphadke
#### Creted on: 07/06/2017
#### Last edited on: 07/18/2017


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
library(sdalr)
library(SnowballC)
library(stringr)


## Data import and rename
# random projects
load("~/git/oss/data/oss/working/openhub/randomProjects/all_random_projects_table.RData")

# relevant projects
load("~/git/oss/data/oss/working/openhub/relevantProjects/projectRelevantMaster.RData")

ran_data <- randomProjectTable
rel_data <- projectRelevantMaster
rm(randomProjectTable)
rm(projectRelevantMaster)


####################
#### Data quality check
#### And cleanup
####################

## Convert blanks and "NA"s to NAs
ran_data[ran_data == ""] <- NA
ran_data[ran_data == "\n  "] <- NA
ran_data[ran_data == "NA"] <- NA

rel_data[rel_data == ""] <- NA
rel_data[rel_data == "\n  "] <- NA
rel_data[rel_data == "NA"] <- NA


## Make relevant columns numeric
ran_data$user_count <- as.numeric(ran_data$user_count)
ran_data$average_rating <- as.numeric(ran_data$average_rating)
ran_data$rating_count <- as.numeric(ran_data$rating_count)
ran_data$review_count <- as.numeric(ran_data$review_count)
ran_data$twelve_month_contributor_count <- as.numeric(ran_data$twelve_month_contributor_count)
ran_data$total_contributor_count <- as.numeric(ran_data$total_contributor_count)
ran_data$twelve_month_commit_count <- as.numeric(ran_data$twelve_month_commit_count)
ran_data$total_commit_count <- as.numeric(ran_data$total_commit_count)
ran_data$total_code_lines <- as.numeric(ran_data$total_code_lines)


rel_data$user_count <- as.numeric(rel_data$user_count)
rel_data$average_rating <- as.numeric(rel_data$average_rating)
rel_data$rating_count <- as.numeric(rel_data$rating_count)
rel_data$review_count <- as.numeric(rel_data$review_count)
rel_data$twelve_month_contributor_count <- as.numeric(rel_data$twelve_month_contributor_count)
rel_data$total_contributor_count <- as.numeric(rel_data$total_contributor_count)
rel_data$twelve_month_commit_count <- as.numeric(rel_data$twelve_month_commit_count)
rel_data$total_commit_count <- as.numeric(rel_data$total_commit_count)
rel_data$total_code_lines <- as.numeric(rel_data$total_code_lines)

####
## Remove the fully empty rows
####
clean_ran_data <- ran_data[!apply(ran_data[2:33], 1, function(x){all(is.na(x))}), ]
rm(ran_data)

clean_rel_data <- rel_data[!apply(rel_data[2:33], 1, function(x){all(is.na(x))}), ]
rm(rel_data)


# Separating out the factoid columns
clean_ran_data$age <- NA
clean_ran_data$team_size <- NA
clean_ran_data$activity <- NA
clean_ran_data$comments <- NA

for(i in 1:nrow(clean_ran_data)){

  if(length(grep("Age", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_ran_data$age[i] <- unlist(str_split(grep("Age", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE), "Age"))[2]
  }

  if(length(grep("Team", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_ran_data$team_size[i] <- unlist(str_split(grep("Team", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE), "Size"))[2]
  }

  if(length(grep("Activity", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_ran_data$activity[i] <- unlist(str_split(grep("Activity", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE), "Activity"))[2]
  }

  if(length(grep("Comments", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_ran_data$comments[i] <- unlist(str_split(grep("Comments", unlist(str_split(clean_ran_data$factoids[i], ";")), value = TRUE), "Comments"))[2]
  }

  print(i)
}

table(clean_ran_data$age)
table(clean_ran_data$team_size)
table(clean_ran_data$activity)
table(clean_ran_data$comments)

clean_ran_data$age <- as.factor(clean_ran_data$age)
clean_ran_data$activity <- as.factor(clean_ran_data$activity)
clean_ran_data$team_size <- as.factor(clean_ran_data$team_size)
clean_ran_data$comments <- as.factor(clean_ran_data$comments)


clean_rel_data$age <- NA
clean_rel_data$team_size <- NA
clean_rel_data$activity <- NA
clean_rel_data$comments <- NA

for(i in 1:nrow(clean_rel_data)){

  if(length(grep("Age", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_rel_data$age[i] <- unlist(str_split(grep("Age", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE), "Age"))[2]
  }

  if(length(grep("Team", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_rel_data$team_size[i] <- unlist(str_split(grep("Team", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE), "Size"))[2]
  }

  if(length(grep("Activity", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_rel_data$activity[i] <- unlist(str_split(grep("Activity", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE), "Activity"))[2]
  }

  if(length(grep("Comments", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE)) > 0){
    clean_rel_data$comments[i] <- unlist(str_split(grep("Comments", unlist(str_split(clean_rel_data$factoids[i], ";")), value = TRUE), "Comments"))[2]
  }

  print(i)
}

table(clean_rel_data$age)
table(clean_rel_data$team_size)
table(clean_rel_data$activity)
table(clean_rel_data$comments)

clean_rel_data$age <- as.factor(clean_rel_data$age)
clean_rel_data$activity <- as.factor(clean_rel_data$activity)
clean_rel_data$team_size <- as.factor(clean_rel_data$team_size)
clean_rel_data$comments <- as.factor(clean_rel_data$comments)


## Let's try some ggplots with factoids
####
## Four factoids: age, activity, team_size, comments
## Six continuous variables of interest: user_count, average_rating, rating_count, review_count, total_contributor_count, total_commit_count, total_code_lines
#ggplot(aes(y = boxthis, x = f2, fill = f1), data = df) + geom_boxplot()


####
#### Total code lines
####
#### Total code lines by project type and activity level
activity_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'activity'), measure.vars = c('total_code_lines'))
activity_ran_df$data <- "Random projects"
activity_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'activity'), measure.vars = c('total_code_lines'))
activity_rel_df$data <- "Relevant projects"
activity_df <- rbind(activity_ran_df, activity_rel_df)

code_lines_1 <- ggplot(data = activity_df, aes(x = activity, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total code lines by project type and activity level") +
  labs(x = "Activity level", y = "Total code lines") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


#### Total code lines by project type and age
age_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'age'), measure.vars = c('total_code_lines'))
age_ran_df$data <- "Random projects"
age_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'age'), measure.vars = c('total_code_lines'))
age_rel_df$data <- "Relevant projects"
age_df <- rbind(age_ran_df, age_rel_df)

code_lines_2 <- ggplot(data = age_df, aes(x = age, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total code lines by project type and age") +
  labs(x = "Age", y = "Total code lines") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### Total code lines by project type and team_size level
team_size_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'team_size'), measure.vars = c('total_code_lines'))
team_size_ran_df$data <- "Random projects"
team_size_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'team_size'), measure.vars = c('total_code_lines'))
team_size_rel_df$data <- "Relevant projects"
team_size_df <- rbind(team_size_ran_df, team_size_rel_df)

code_lines_3 <- ggplot(data = team_size_df, aes(x = team_size, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total code lines by project type and team size") +
  labs(x = "Team size", y = "Total code lines") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### Total code lines by project type and activity level
comments_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'comments'), measure.vars = c('total_code_lines'))
comments_ran_df$data <- "Random projects"
comments_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'comments'), measure.vars = c('total_code_lines'))
comments_rel_df$data <- "Relevant projects"
comments_df <- rbind(comments_ran_df, comments_rel_df)

code_lines_4 <- ggplot(data = comments_df, aes(x = comments, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total code lines by project type and comments") +
  labs(x = "Comments", y = "Total code lines") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


png(filename = "./output/openhub/graphics/activity_projtype.png",
    units = "in", width = 15, height = 15,
    res = 72, bg = "transparent"
)
multiplot(code_lines_1, code_lines_2, code_lines_3, code_lines_4, cols=2)
dev.off()






####
#### Total contributor count
####
#### Total contributor count by project type and activity level
activity_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'activity'), measure.vars = c('total_contributor_count'))
activity_ran_df$data <- "Random projects"
activity_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'activity'), measure.vars = c('total_contributor_count'))
activity_rel_df$data <- "Relevant projects"
activity_df <- rbind(activity_ran_df, activity_rel_df)

contrib_count_1 <- ggplot(data = activity_df, aes(x = activity, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total contributor count by project type and activity level") +
  labs(x = "Activity level", y = "Total contributor count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


#### Total contributor count by project type and age
age_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'age'), measure.vars = c('total_contributor_count'))
age_ran_df$data <- "Random projects"
age_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'age'), measure.vars = c('total_contributor_count'))
age_rel_df$data <- "Relevant projects"
age_df <- rbind(age_ran_df, age_rel_df)

contrib_count_2 <- ggplot(data = age_df, aes(x = age, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total contributor count by project type and age") +
  labs(x = "Age", y = "Total contributor count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### Total contributor count by project type and team_size level
team_size_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'team_size'), measure.vars = c('total_contributor_count'))
team_size_ran_df$data <- "Random projects"
team_size_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'team_size'), measure.vars = c('total_contributor_count'))
team_size_rel_df$data <- "Relevant projects"
team_size_df <- rbind(team_size_ran_df, team_size_rel_df)

contrib_count_3 <- ggplot(data = team_size_df, aes(x = team_size, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total contributor count by project type and team size") +
  labs(x = "Team size", y = "Total contributor count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### Total contributor count by project type and activity level
comments_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'comments'), measure.vars = c('total_contributor_count'))
comments_ran_df$data <- "Random projects"
comments_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'comments'), measure.vars = c('total_contributor_count'))
comments_rel_df$data <- "Relevant projects"
comments_df <- rbind(comments_ran_df, comments_rel_df)

contrib_count_4 <- ggplot(data = comments_df, aes(x = comments, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Total contributor count by project type and comments") +
  labs(x = "Comments", y = "Total contributor count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


png(filename = "./output/openhub/graphics/contributor_projtype.png",
    units = "in", width = 15, height = 15,
    res = 72, bg = "transparent"
)
multiplot(contrib_count_1, contrib_count_2, contrib_count_3, contrib_count_4, cols=2)
dev.off()




####
#### User count
####
#### User count by project type and activity level
activity_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'activity'), measure.vars = c('user_count'))
activity_ran_df$data <- "Random projects"
activity_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'activity'), measure.vars = c('user_count'))
activity_rel_df$data <- "Relevant projects"
activity_df <- rbind(activity_ran_df, activity_rel_df)

user_count_1 <- ggplot(data = activity_df, aes(x = activity, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("User count by project type and activity level") +
  labs(x = "Activity level", y = "User count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


#### user count by project type and age
age_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'age'), measure.vars = c('user_count'))
age_ran_df$data <- "Random projects"
age_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'age'), measure.vars = c('user_count'))
age_rel_df$data <- "Relevant projects"
age_df <- rbind(age_ran_df, age_rel_df)

user_count_2 <- ggplot(data = age_df, aes(x = age, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("User count by project type and age") +
  labs(x = "Age", y = "User count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### user count by project type and team_size level
team_size_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'team_size'), measure.vars = c('user_count'))
team_size_ran_df$data <- "Random projects"
team_size_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'team_size'), measure.vars = c('user_count'))
team_size_rel_df$data <- "Relevant projects"
team_size_df <- rbind(team_size_ran_df, team_size_rel_df)

user_count_3 <- ggplot(data = team_size_df, aes(x = team_size, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("User count by project type and team size") +
  labs(x = "Team size", y = "User count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### user count by project type and activity level
comments_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'comments'), measure.vars = c('user_count'))
comments_ran_df$data <- "Random projects"
comments_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'comments'), measure.vars = c('user_count'))
comments_rel_df$data <- "Relevant projects"
comments_df <- rbind(comments_ran_df, comments_rel_df)

user_count_4 <- ggplot(data = comments_df, aes(x = comments, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("User count by project type and comments") +
  labs(x = "Comments", y = "User count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


png(filename = "./output/openhub/graphics/user_projtype.png",
    units = "in", width = 15, height = 15,
    res = 72, bg = "transparent"
)
multiplot(user_count_1,user_count_2,user_count_3,user_count_4, cols=2)
dev.off()




####
#### rating count
####
#### rating count by project type and activity level
activity_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'activity'), measure.vars = c('rating_count'))
activity_ran_df$data <- "Random projects"
activity_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'activity'), measure.vars = c('rating_count'))
activity_rel_df$data <- "Relevant projects"
activity_df <- rbind(activity_ran_df, activity_rel_df)

rating_count_1 <- ggplot(data = activity_df, aes(x = activity, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Rating count by project type and activity level") +
  labs(x = "Activity level", y = "Rating count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


#### rating count by project type and age
age_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'age'), measure.vars = c('rating_count'))
age_ran_df$data <- "Random projects"
age_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'age'), measure.vars = c('rating_count'))
age_rel_df$data <- "Relevant projects"
age_df <- rbind(age_ran_df, age_rel_df)

rating_count_2 <- ggplot(data = age_df, aes(x = age, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Rating count by project type and age") +
  labs(x = "Age", y = "Rating count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### rating count by project type and team_size level
team_size_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'team_size'), measure.vars = c('rating_count'))
team_size_ran_df$data <- "Random projects"
team_size_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'team_size'), measure.vars = c('rating_count'))
team_size_rel_df$data <- "Relevant projects"
team_size_df <- rbind(team_size_ran_df, team_size_rel_df)

rating_count_3 <- ggplot(data = team_size_df, aes(x = team_size, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Rating count by project type and team size") +
  labs(x = "Team size", y = "Rating count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )

#### rating count by project type and activity level
comments_ran_df <- melt(data = clean_ran_data, id.vars = c('project_name', 'comments'), measure.vars = c('rating_count'))
comments_ran_df$data <- "Random projects"
comments_rel_df <- melt(data = clean_rel_data, id.vars = c('project_name', 'comments'), measure.vars = c('rating_count'))
comments_rel_df$data <- "Relevant projects"
comments_df <- rbind(comments_ran_df, comments_rel_df)

rating_count_4 <- ggplot(data = comments_df, aes(x = comments, y = value, fill = data)) +
  geom_boxplot() +
  theme_minimal() +
  theme(legend.position="right") +
  ggtitle("Rating count by project type and comments") +
  labs(x = "Comments", y = "Rating count") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme(text=element_text(size=20),
        axis.text=element_text(size=16),
        axis.title=element_text(size=20)#,
        #axis.text.x=element_text(angle=90,hjust=1)
  )


png(filename = "./output/openhub/graphics/rating_count_projtype.png",
    units = "in", width = 15, height = 15,
    res = 72, bg = "transparent"
)
multiplot(rating_count_1,rating_count_2,rating_count_3,rating_count_4, cols=2)
dev.off()




