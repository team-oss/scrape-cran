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
library(lubridate)
library(scales)
library(SnowballC)
library(stringr)
library(tm)
library(wordcloud)


## Data import and rename
load("~/git/oss/data/oss/working/openhub/randomProjects/all_random_projects_table.RData")

data <- randomProjectTable


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


####
## Remove the fully empty rows
####
clean_data <- data[!apply(data[2:33], 1, function(x){all(is.na(x))}), ]


## Check data quality
completeness <- matrix(NA, ncol(clean_data), 4)

for(i in 1:ncol(clean_data)){
  x <- clean_data[,i]

  completeness[i,1] <- colnames(clean_data)[i]
  completeness[i,2] <- class(x)[1]

  # Proportion of missing values
  completeness[i,3] <- round(sum(is.na(x))*100/nrow(clean_data), digits = 2)

  # How many unique values to the variable?
  completeness[i,4] <- length(unique(x))
  # summary <- summary(x)
  # if(vals <= 10){
  #   tab <- table(x)
  #   print(tab)
  # }
  #print(c(name, class, miss, vals))
}


ggplot(clean_data, aes(created_at, total_commit_count)) +
  geom_line() +
  scale_x_datetime(date_labels = "%Y-%b") #+ xlab("") + ylab("Daily Views")



language_corpus <- Corpus(VectorSource(clean_data$main_language))
language_dtm <- TermDocumentMatrix(language_corpus)
dps_m <- as.matrix(language_dtm)
dps_m <- sort(rowSums(dps_m),decreasing=TRUE)
dps_m <- data.frame(word = names(dps_m),freq = dps_m)


png(filename="/wordcloud_dps.png",
    units="in",
    width=10,
    height=10,
    #pointsize=12,
    res=72
)
wordcloud(dps_m$word, dps_m$freq, min.freq = 1, random.order = FALSE, colors=brewer.pal(8, "Dark2"))
dev.off()





dps_chrg_corpus <- Corpus(VectorSource(clean_data$description))
dps_chrg_corpus <- tm_map(dps_chrg_corpus, PlainTextDocument)
dps_chrg_corpus <- tm_map(dps_chrg_corpus, content_transformer(tolower))

dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, stopwords('english'))
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, c("will","set","functions", "data", "package", "based", "can", "provides", "set", "used", "project", "using", "contains", "function"))
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeNumbers)
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removePunctuation)

dps_chrg_corpus <- tm_map(dps_chrg_corpus, stemDocument)

dps_temp_stemmed <- data.frame(text = sapply(dps_chrg_corpus, as.character), stringsAsFactors = FALSE)

oh_random_proj_desc_dtm <- TermDocumentMatrix(dps_chrg_corpus)
save(oh_random_proj_desc_dtm, file = "~/git/oss/data/oss/working/openhub/randomProjects/oh_random_proj_desc_dtm.RData")
dps_m <- as.matrix(dps_dtm)
dps_m <- sort(rowSums(dps_m),decreasing=TRUE)
dps_m <- data.frame(word = names(dps_m),freq = dps_m)

wordcloud(dps_m$word, dps_m$freq, min.freq = 20, random.order = FALSE, colors=brewer.pal(8, "Dark2"))

