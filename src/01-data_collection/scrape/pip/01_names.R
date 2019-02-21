# INPUT: N/A
#
# OUTPUT:
#         "~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv"
#         "~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv"
library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)

pypi_names <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("name", "development_status"))

temp1 <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("name", "development_status"))
for (i in 1:500) # website only seems to have 500 pages of results
{
  temp1 <- rbind(temp1, names_func(page_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+5+-+Production%2FStable&o=&q=&page=", i, sep = ""), "Production/Stable"))
}
write.csv(temp1, "~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv")


temp2 <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("name", "development_status"))
for (k in 1:22) # on 2019-01-15 there are now 24 pages of results for a total of 464 projects
{
  temp2 <- rbind(temp2, names_func(page_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+6+-+Mature&o=&q=&page=", k, sep = ""), "Mature"))
}
temp2 <- temp2[1:423,]

write.csv(temp2, "~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv")

names_func <- function(page_url, dev_stat)
{
  Sys.sleep(2)
  names_df <- setNames(data.frame(matrix(ncol = 2, nrow = 20)),c("name", "development_status"))

  base_site_html <- read_html(page_url)
  names <- base_site_html %>% html_nodes('.package-snippet__title a') %>% html_text()
  for (j in 1:length(names))
  {
    names_df$name[j] <- names[j]
    names_df$development_status[j] <- dev_stat
  }
  return(names_df)
}

