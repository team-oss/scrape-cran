library(data.table)
library(sdalr)
library(DBI)

file_list <- list.files(path = "data/oss/oss2/original/cran/logs/r/",
                        pattern = "^2012.*gz$",
                        full.names = TRUE)


con <- con_db(dbname = "oss", host = "127.0.0.1", port = 5433, user = "aschroed", pass = "Iwnftp$2")

#dbGetQuery(con, "DROP TABLE IF EXISTS cran_logs_pkg")

for (f in file_list) {
  print(paste("Reading", f))
  data <- fread(cmd = paste("zcat", f))
  data[, date := as.Date(date, "%Y-%m-%d")]
  data_grp <- data[, .N, .(date, country, version)]
  #data <- fread(f)
  print(paste("Writing", f))
  dbWriteTable(con, "cran_logs_r_day", data_grp, row.names = F, append = TRUE)
}


# write.csv(data, "data/oss/oss2/data.csv")
