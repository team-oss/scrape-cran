library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)
source("~/oss/src/scrape/pip/02_scraping_func.R")

pypi_df <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))


for (a in 1:3)
{
  temp1 <- scrape_func(base_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+1+-+Planning&c=License+%3A%3A+OSI+Approved&o=&q=&page=", a, sep = ""), "Planning")
  pypi_df <- rbind(pypi_df, temp1)
}

temp2 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+2+-+Pre-Alpha&c=License+%3A%3A+OSI+Approved", "Pre-Alpha")
pypi_df <- rbind(pypi_df, temp2)

for (b in 1:6)
{
  temp3 <- scrape_func(base_url = paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+3+-+Alpha&c=License+%3A%3A+OSI+Approved&o=&q=&page=", b, sep = ""), "Alpha")
  pypi_df <- rbind(pypi_df, temp3)
}

for (c in 1:11)
{
  temp4 <- scrape_func(base_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+4+-+Beta&c=License+%3A%3A+OSI+Approved&o=&q=&page=", c, sep = ""), "Beta")
  pypi_df <- rbind(pypi_df, temp4)
}

# Gets data for PyPI projects with OSI-approved licenses and with development status of 5-Production/Stable
for (d in 1:8)
{
  temp5 <- scrape_func(base_url = paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+5+-+Production%2FStable&c=License+%3A%3A+OSI+Approved&o=&q=&page=",d, sep=""), "Production/Stable")
  pypi_df <- rbind(pypi_df, temp5)
}

# Gets data for PyPI projects with OSI-approved licenses and with a development status of 6-Mature
temp6 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+6+-+Mature&c=License+%3A%3A+OSI+Approved", "Mature")
pypi_df <- rbind(pypi_df, temp6)

temp7 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+7+-+Inactive&c=License+%3A%3A+OSI+Approved", "Inactive")
pypi_df <- rbind(pypi_df, temp7)

write.csv(pypi_df, '~/oss/data/oss/final/PyPI/pypi_all.csv')
