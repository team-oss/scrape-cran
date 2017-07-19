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

# ## Completely empty rows
# num_empty_rows <- length(data$licenses[apply(data[,2:ncol(data)], 1, function(x){all(is.na(x))}) == TRUE])
# rm(num_empty_rows)


####
#### Plot of languages
####
# ran_language_freq <- as.data.frame(table(clean_ran_data$main_language))
# ran_lang_to_plot <- head(ran_language_freq[order(ran_language_freq$Freq, decreasing= T),], n = 10)
# ran_lang_to_plot <- clean_ran_data[(clean_ran_data$main_language %in% ran_lang_to_plot$Var1) == TRUE, 'main_language']
# ran_lang_to_plot <- as.data.frame(ran_lang_to_plot)
#
#
# random_lang <- ggplot(data = ran_lang_to_plot, aes(x = ran_lang_to_plot, fill = ran_lang_to_plot)) +
#   geom_bar() +
#   theme_minimal() +
#   theme(legend.position = "none") +
#   ggtitle("Ten main languages: Random projects") +
#   labs(y = "Frequency", x = "") +
#   theme(plot.title = element_text(hjust = 0.5)) +
#   theme(text=element_text(size=20),
#         axis.text=element_text(size=16),
#         axis.title=element_text(size=20))
#
# png(filename = "./output/openhub/graphics/poster/random_main_lang.png",
#     units = "in", width = 8, height = 15,
#     res = 72, bg = "transparent")
# random_lang
# dev.off()


rel_language_freq <- as.data.frame(table(clean_rel_data$main_language))
rel_lang_to_plot <- head(rel_language_freq[order(rel_language_freq$Freq, decreasing= T),], n = 10)
rel_lang_to_plot <- clean_rel_data[(clean_rel_data$main_language %in% rel_lang_to_plot$Var1) == TRUE, 'main_language']
rel_lang_to_plot <- as.data.frame(rel_lang_to_plot)

rel_lang <- ggplot(data = rel_lang_to_plot, aes(x = rel_lang_to_plot, fill = rel_lang_to_plot)) +
  geom_bar() +
  scale_fill_brewer(palette = "Spectral") +
  theme_minimal() +
  theme(legend.position = "none") +
  ggtitle("Ten main languages: Relevant projects") +
  labs(y = "Frequency", x = "") +
  theme(axis.text.x = element_text(size = 24, angle = 45, hjust = 1),
        axis.text.y = element_text(size = 24),
        title = element_text(size = 24),
        axis.title = element_text(size = 20)) +
  theme(plot.title = element_text(hjust = 0.5))

png(filename = "./output/openhub/graphics/poster/rel_main_lang.png",
    units = "in", width = 8, height = 15,
    res = 72, bg = "transparent")
rel_lang
dev.off()



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

# View(completeness)




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
#### See if things are correlated
####

# cor(clean_data[, c('average_rating', 'user_count', 'rating_count', 'review_count', 'twelve_month_contributor_count', 'total_contributor_count', 'total_commit_count', 'total_code_lines', 'twelve_month_commit_count')])


####
#### Time plot of development
####

# ggplot(clean_data, aes(created_at, total_commit_count)) +
#   geom_point() +
#   scale_x_datetime(date_labels = "%Y-%b") #+ xlab("") + ylab("Daily Views")
#
# ggplot(clean_data, aes(created_at, total_contributor_count)) +
#   geom_line() +
#   scale_x_datetime(date_labels = "%Y-%b")




####
#### Wordclouds
####
## Main development language

language_corpus <- Corpus(VectorSource(clean_data$main_language))
language_dtm <- TermDocumentMatrix(language_corpus)
dps_m <- as.matrix(language_dtm)
dps_m <- sort(rowSums(dps_m),decreasing=TRUE)
dps_m <- data.frame(word = names(dps_m),freq = dps_m)

# png(filename="/wordcloud_dps.png",
#     units="in",
#     width=10,
#     height=10,
#     #pointsize=12,
#     res=72
# )

ggplot(data = clean_data, aes(x = main_language)) +
  geom_bar()

wordcloud(dps_m$word, dps_m$freq, min.freq = 1, random.order = FALSE, colors=brewer.pal(8, "Dark2"))
# dev.off()


## Top 3 languages
all_languages <- c(unlist(str_split(clean_data$languages, ";")))
all_languages <- all_languages[str_detect(all_languages, "other") == FALSE]
language_corpus <- Corpus(VectorSource(all_languages))
language_corpus <- tm_map(language_corpus, removeNumbers)
language_corpus <- tm_map(language_corpus, removeWords, c("other", "Other"))
language_dtm <- TermDocumentMatrix(language_corpus)
dps_m <- as.matrix(language_dtm)
dps_m <- sort(rowSums(dps_m),decreasing=TRUE)
dps_m <- data.frame(word = names(dps_m),freq = dps_m)

wordcloud(dps_m$word, dps_m$freq, min.freq = 1, random.order = FALSE, colors=brewer.pal(8, "Dark2"))


####
## Later
####
## Description
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



####
#### Network of tags
####

tags_df <- na.omit(clean_data$tags)

tag_edgelist <- matrix(ncol = 2)

for (i in 1:nrow(clean_data)){
  num_tags <- length(unlist(str_split(tags_df[i], pattern = ";")))

  if(num_tags > 1) {
    val_tags <- unlist(str_split(tags_df[i], pattern = ";"))

    combinations <- combinations(n = num_tags, r = 2, val_tags, repeats.allowed = FALSE, set = TRUE)

    tag_edgelist <- rbind(tag_edgelist, combinations)
  }

  print(i)
}

tag_edgelist <- na.omit(tag_edgelist)
tag_net <- network(as.data.frame(tag_edgelist), directed = FALSE, matrix.type = "edgelist")

plot(tag_net, displaylabels = F,
     #label = get.vertex.attribute(contact.net, "female"),
     vertex.cex = 1)#, vertex.col = c("Blue", "Red"))
