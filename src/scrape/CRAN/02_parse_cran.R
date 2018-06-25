#parse and clean the CRAN data
library(stringr)
library(dplyr)
library(jsonlite)

dat <- readRDS("./data/oss/original/CRAN_2018/master_frame.RDS")

#wrote a loop to figure out that max number of variables is at index 835
dat[[835]]
tmp <- unlist(dat[[835]])
s <- split(tmp, 1:2)
#we set up column names based on max amount of variables
cols_for_table <- s$`1`

df <- data.frame(matrix(ncol = 20, nrow = 12614))
colnames(df) <- cols_for_table

#fill in the data frame if the information is available for that package
#otherwise leave as NA
# avail_names <- colnames(df)
# for(i in 1:length(dat)){
#   unlist_row <- unlist(dat[[i]])
#   s <- split(unlist_row, 1:2)
#   vars <- s$`1`
#   var_data <- s$`2`
#   #loop over 20 available variables
#   for(j in 1:20){
#     if(str_detect(vars[j],avail_names[j]))
#     if(vars[j] == avail_names[j]){
#       df[i,j] = var_data[j]
#     }
#   }
# }

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
