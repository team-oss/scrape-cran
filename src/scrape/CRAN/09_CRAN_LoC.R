#take the link to each source package and download it, then run wc to get line for each pacakge
library(stringr)
library(dplyr)
library(progress)
library(purrr)
library(tidyr)
library(sdalr)
library(DBI)
library(data.table)

###### DO NOT RUN THIS CHUNK UNLESS YOU NEED TO REDOWNLOAD FROM CRAN ----
cran_src <- readRDS(file = './data/oss/original/CRAN_2018/cran_src.RDS')
cran_src$pack_src <- as.character(cran_src$pack_src)

for(i in 1:nrow(cran_src)){
  download.file(url = cran_src$pack_src[i],destfile =
                  paste0('./data/oss/original/CRAN_2018/package_source/tar_files/',cran_src$abrv[i]))
}
#fix this stuff below
#tars <- list.files(path='./data/oss/original/CRAN_2018/package_source/tar_files/')
#loop over the tar files and extract them
pb <- progress_bar$new(total = length(tars))
for(i in 1:length(tars)){
  pb$tick()
  untar(paste0('./data/oss/original/CRAN_2018/package_source/tar_files/',tars[i])
        , exdir = './data/oss/original/CRAN_2018/package_source/extracted')
}

###### line count for each package ----
setwd('./data/oss/original/CRAN_2018/package_source/extracted')
getwd() #make sure this is the extracted folder in data original
out <- system(command = "find . -type f -name '*.R' -o -name '*.c' -o -name '*.h' | xargs wc -l",intern=T)
out1 <- out[1:10]
out1

unlist_and_store <- function(line_of_cran_output){
  splits <- line_of_cran_output %>%
    str_split(pattern = "\\ ./") %>%
    unlist() %>%
    str_trim() %>%
    t() %>%
    data.frame()
  return(splits)
}

y <- lapply(out1, unlist_and_store)
y <- tibble(y)
unnest(y)

#test on more
y2 <- lapply(out[1:600], unlist_and_store)
y2 <- tibble(y2)
unnest(y2)

#real thing
output <- lapply(out, unlist_and_store)
output <- tibble(output)
output <- unnest(output)

#clean it up
output <- as.data.table(output)
colnames(output) <- c("lines_of_code","file","misc")
output$lines_of_code <- as.integer(output$lines_of_code)

#find which package each file belongs to
output$package <- str_extract(output$file, ".*?(?=\\/)")


#summarize
byPack <- group_by(output, package)
tab <- byPack %>% summarise(
  lines_of_code = sum(lines_of_code)
)

#attach kloc
tab$kloc <- tab$lines_of_code / 1000

#calculate cost
tab$cost <- round(18096.47 * 2.5 * (2.4 * (tab$kloc)^1.05)^0.38, 2)

#save it
setwd('../../../../../oss/') #should be oss
saveRDS(tab,'./working/CRAN_2018/Cran_Direct_download_costs.RDS')

#write to db
# my_db_con <- con_db("oss", pass=sdalr::get_my_password())
# dbWriteTable(con = my_db_con,
#              name = "CRAN_direct_download_costs",
#              value = tab,
#              row.names = FALSE,
#              overwrite = TRUE)

