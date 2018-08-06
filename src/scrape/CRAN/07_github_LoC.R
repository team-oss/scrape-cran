#calculating lines of code for CRAN github information
#we will need to do more lines of code for cran packages not on github
library(stringr)
library(dplyr)
git_data <- readRDS(file= './data/oss/working/CRAN_2018/Cran_git_cleanest.RDS')

byPack <- group_by(git_data, slug)
#now display sum of adds and deletes
data_thing <- byPack %>% summarise(
  adds = sum(additions),
  dels = sum(deletions),
  commits = sum(commits)
)
data_thing$lines_of_code <- data_thing$adds + data_thing$dels
data_thing$kloc <- data_thing$lines_of_code /1000

View(data_thing)

#use this to write to file
#saveRDS(data_thing, file = './data/oss/working/CRAN_2018/Cran_lines_of_code.RDS')
