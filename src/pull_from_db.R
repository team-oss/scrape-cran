library(data.table)
library(sdalr)
library(DBI)

# Create db connection
con <- con_db(dbname = "oss", host = "127.0.0.1", port = 5433, user = "aschroed", pass = "Iwnftp$2")

# Get top 100 packages for a given country and year
pkg_dnld_2018 <- dbGetQuery(con, "SELECT *
                       FROM cran_logs_pkg_year
                       WHERE country = 'US'
                       AND year = 2018
                       ORDER BY pkg_cnt DESC
                       LIMIT 100")

head(pkg_dnld_2018)
