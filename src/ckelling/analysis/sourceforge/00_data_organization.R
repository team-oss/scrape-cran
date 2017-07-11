# Organizing all of the data
library(dplyr)
library(tictoc)
#data <- full_join(all_ranks, id2s, by= c(GEOID2 = "Index_Data.Id2"))
library(splines)
?bs

#data for the last 200,000+ rows, that should include all of the information for these software
tic()
fs <- list.files('~/git/oss/data/oss/original/sourceforge/final_with_downloads/data', full.names = TRUE, pattern = '*.RData')
tail(fs)
#7:30am:  464,675
#9am:     467,841
#11:30am: 473,000
#1:30pm:  477,408
#2:30pm:  479,145
#3:30pm:  481,251
#4:30pm:  483,232
load_stuff <- function(file_name) {
  load(file_name)
  return(data.frame(new_data, stringsAsFactors = F))
}
fl <- lapply(X = fs, FUN = load_stuff)

completedown_SF <- data.table::rbindlist(fl)
toc()

fs <- list.files('~/git/oss/data/oss/original/sourceforge/SF_scrape_FINAL', full.names = TRUE, pattern = '*.RData')
load_stuff <- function(file_name) {
  load(file_name)
  return(data.frame(new_data, stringsAsFactors = F))
}
fl <- lapply(X = fs, FUN = load_stuff)
complete_SFdat <- data.table::rbindlist(fl)


# data for the first 250,000 rows
#load(file = '~/git/oss/data/oss/working/sourceforge/complete_SFdat2.RData')
#complete_SFdat <- complete_SFdat2
#data that needs to be appended to the first 250,000 rows
tic()
fs <- list.files('~/git/oss/data/oss/original/sourceforge/need_to_append/data', full.names = TRUE, pattern = '*.RData')
load_stuff <- function(file_name) {
  load(file_name)
  return(data.frame(new_data, stringsAsFactors = F))
}
fl <- lapply(X = fs, FUN = load_stuff)
completeapp_SF <- data.table::rbindlist(fl)
toc()
complete_SFdat$OSS.Title <- trimws(complete_SFdat$OSS.Title)
completeapp_SF$OSS.Title <- trimws(completeapp_SF$OSS.Title)

#First, I will consider the data that does not include Total Downloads
#full complete_SFdat: 224,679 rows
test <- complete_SFdat[!duplicated(complete_SFdat$OSS.Title),]
#only unique column names: 218,695 rows
1- nrow(test)/nrow(complete_SFdat)
#this is still only 2.8% missing

#Now, I will consider the data that will be appended (Total Downloads)
#full completeapp_SF: 210,982
test2 <- completeapp_SF[!duplicated(completeapp_SF$OSS.Title),]
#only unique column names: 205,571
1- nrow(test2)/nrow(completeapp_SF)
#This represents a 2.5% decrease (repeated names)

#now, to find the rows in common: (should be approximately 218,695)
data <- left_join(test, test2, by= c(OSS.Title = "OSS.Title"))
#this dataset has 218,695 rows, which is exactly what I am expecting

data$Description.x <- data$Description.y
data <- data[, -which(names(data) == "Description.y")]
names(data)[3] <- "Description"

#not unique data
complete_data <- rbind(data, completedown_SF)

save(complete_data, file = '~/git/oss/data/oss/working/sourceforge/DONE_SFunclean.RData')
