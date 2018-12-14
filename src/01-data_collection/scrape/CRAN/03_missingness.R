#missingness of every variable from cran
data <- readRDS(file = './data/oss/working/CRAN_2018/Cran_full_table.RDS')
data <- data.frame(data)

#Na's in each column
na_count <-colSums(is.na(data))

na_count <- data.frame(na_count)
na_count$prop_missing <- na_count$na_count / nrow(data) # 12614 #make percentage missing
na_count$pct_missing <- round(na_count$prop_missing, digits =4) *100
na_count
