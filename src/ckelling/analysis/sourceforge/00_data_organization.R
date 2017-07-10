# Organizing all of the data
library(dplyr)
library(tictoc)
#data <- full_join(all_ranks, id2s, by= c(GEOID2 = "Index_Data.Id2"))

load(file = '~/git/oss/data/oss/working/sourceforge/complete_SFdat.RData')

tic()
fs <- list.files('~/git/oss/data/oss/original/sourceforge/final_with_downloads/data', full.names = TRUE, pattern = '*.RData')
load_stuff <- function(file_name) {
  load(file_name)
  return(data.frame(new_data, stringsAsFactors = F))
}
fl <- lapply(X = fs, FUN = load_stuff)

completedown_SF <- data.table::rbindlist(fl)
toc()



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


#This is not working
data <- full_join(complete_SFdat, completeapp_SF, by= c(OSS.Title = "OSS.Title"))
data2 <- unique(data)
data2$Description.x <- data2$Description.y
data2 <- data2[, -which(names(data2) == "Description.y")]
names(data2)[3] <- "Description"

#not unique data
test <- rbind(data2, completedown_SF)
