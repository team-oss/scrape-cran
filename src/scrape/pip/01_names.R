# download.file("https://zenodo.org/record/1196312/files/Libraries.io-open-data-1.2.0.tar.gz", "~/oss/data/oss/final/PyPI/librariesio.tar.gz")
#
# dir.create("~/oss/data/oss/working/pypi/libraries_io/")
#
# untar("~/oss/data/oss/final/PyPI/librariesio.tar.gz", files = "~/oss/data/oss/working/pypi/libraries_io/")
library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)

pypi_names <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("name", "development_status"))

temp1 <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("name", "development_status"))

for (i in 1:3)
{
  i = 1
  temp1 <- rbind(temp1, names_func(page_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+5+-+Production%2FStable&o=&q=&page=", i, sep = ""), "Production/Stable"))
}


names_func <- function(page_url, dev_stat)
{
  page_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+5+-+Production%2FStable&o=&q=&page=", i, sep = "")
  names_df <- setNames(data.frame(matrix(ncol = 2, nrow = 20)),c("name", "development_status"))
  position <- 1

  base_site_html <- read_html(page_url)
  names <- base_site_html %>% html_nodes('.package-snippet__title a') %>% html_text()
  for (j in 1:length(names))
  {
    names_df$name[j] <- names[j]
    names_df$development_status[j] <- dev_stat
  }
  return(names_df)
}

