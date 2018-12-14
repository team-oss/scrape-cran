#parse and clean the CRAN data, and the two other tables that we made
library(stringr)
library(plyr)
library(dplyr)
library(jsonlite)

dat <- readRDS("./data/oss/original/CRAN_2018/master_frame.RDS")

#Dan's advice: List to JSON, JSON to data frame
tmp <- dat[[1]]
tmp[[1]]
toJSON(dat[[1]][[1]])


# list of list of n x 2 matrix (2 rows), where the first row is the label
dat2 <- lapply(dat, '[[', 1)
dat2


create_vector_from_mat <- function(matrix, row_name_idx = 1, data_idx = 2) {
  keys <- matrix[row_name_idx, ]
  values <- matrix[data_idx, ]
  v <- c(values)
  names(v) <- keys
  return(v)
}

dat2 <- lapply(dat2, create_vector_from_mat)

dat2_named_list <- lapply(dat2, function(x){split(x, names(x))})

dat2_json_list <- lapply(dat2_named_list, toJSON)

df <- lapply(dat2_json_list, fromJSON)

dt <- data.table::rbindlist(df, fill = TRUE)

head(dt)

#save the resulting frame
saveRDS(dt, file = "./data/oss/working/CRAN_2018/Cran_full_table.RDS")

###PART TWO
##### RUN AGAIN FOR CI #####
CI_table <- readRDS("./data/oss/original/CRAN_2018/CI_checks.RDS")

#Just go from list of matrices to data from, no JSON needed here
tmp <- CI_table[[1]]
tmp[[1]]
toJSON(CI_table[[1]][[1]])

CI2 <- CI_table

create_vector_from_mat <- function(matrix, row_name_idx = 1, data_idx = 2, number_3 = 3) {
  keys <- matrix[row_name_idx, ]
  values <- matrix[data_idx, ]
  vv <- matrix[number_3,]

  v <- bind_rows(keys,values,vv)
  names(v) <- colnames(tmp)
  return(v)
}

CI2 <- lapply(CI2, create_vector_from_mat)
#make each entry in the list a data frame, then combine back into one data frame
#(kind of like rbind but for list of list)
library(data.table)

tmp1 <- ldply(CI2, data.frame)
tmp1 <- as.data.table(tmp1)

#here we see that some packages only support 2 or less versions.
table(table(tmp1$Package_Name))
#this isn't the thing that messes everything up. Look here for the error:
#we see the issue is when a row is ALL Na. This is a scraping issue
tmp1 %>% dplyr::group_by(Package_Name, Version, Flavor) %>%
  dplyr::summarize(n = n()) %>%
  filter(n > 1)

?dcast.data.table
table(tmp1$Package_Name)[table(tmp1$Package_Name) != 3L]

fin <- data.table::dcast.data.table(tmp1, Package_Name + Version ~ Flavor, value.var = 'Status')
fin

lapply(fin[, 3:6], table, useNA='always')
tmp2 <- tmp1[!is.na(tmp1$Flavor), ]
fin <- data.table::dcast.data.table(tmp2, Package_Name + Version ~ Flavor, value.var = 'Status')
#save the resulting frame
saveRDS(fin, file = "./data/oss/working/CRAN_2018/Cran_CI.RDS")
