#cost table
pacman::p_load(sdalr, DBI, dplyr, data.table, dtplyr, stringr)

infos <- readRDS('./data/oss/working/CRAN_2018/quick_fix_analysis_table.RDS')
infos$cost <-  round(18096.47 * 2.5 * (2.4 * (infos$kloc)^1.05)^0.38, 2)
#write out again
saveRDS(infos, './data/oss/working/CRAN_2018/quick_fix_analysis_table.RDS')
library(sdalr)
library(DBI)
library(data.table)
#write to database
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "CRAN_analysis",
             value = infos,
             row.names = FALSE,
             overwrite = TRUE)
