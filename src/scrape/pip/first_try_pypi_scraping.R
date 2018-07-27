library(RCurl)
library(XML)
library(rvest)
library(dplyr)
library(httr)
library(stringr)
source("~/oss/src/scrape/pip/first_try_scraping_func.R")

# pypi_df <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))

# temp1 <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))
# for (a in 1:3)
# {
#   temp1 <- rbind(temp1, scrape_func(base_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+1+-+Planning&c=License+%3A%3A+OSI+Approved&o=&q=&page=", a, sep = ""), "Planning", a))
# }
# write.csv(temp1, '~/oss/data/oss/final/PyPI/all_scraped/planning.csv')

# temp2 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+2+-+Pre-Alpha&c=License+%3A%3A+OSI+Approved", "Pre-Alpha", 1)
# pypi_df <- rbind(pypi_df, temp2)
# write.csv(temp2, '~/oss/data/oss/final/PyPI/all_scraped/pre_alpha.csv')

# temp3 <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))
# for (b in 1:3)
# {
#   temp3 <- rbind(temp3, scrape_func(base_url = paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+3+-+Alpha&c=License+%3A%3A+OSI+Approved&o=&q=&page=", b, sep = ""), "Alpha", b))
#   #pypi_df <- rbind(pypi_df, temp3)
# }
# write.csv(temp3, '~/oss/data/oss/final/PyPI/all_scraped/alpha1.csv')

# tempf <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))
# for (f in 4:6)
# {
#   tempf <- rbind(tempf, scrape_func(base_url = paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+3+-+Alpha&c=License+%3A%3A+OSI+Approved&o=&q=&page=", f, sep = ""), "Alpha", f))
# }
# write.csv(tempf, '~/oss/data/oss/final/PyPI/all_scraped/alpha2.csv')
#

# temp4 <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))
# for (c in 1:11)
# {
#   temp4 <- rbind(temp4, scrape_func(base_url = paste("https://pypi.org/search/?c=Development+Status+%3A%3A+4+-+Beta&c=License+%3A%3A+OSI+Approved&o=&q=&page=", c, sep = ""), "Beta", c))
#   #pypi_df <- rbind(pypi_df, temp4)
# }
# write.csv(temp4, '~/oss/data/oss/final/PyPI/all_scraped/beta.csv')

# Gets data for PyPI projects with OSI-approved licenses and with development status of 5-Production/Stable
# temp5 <- setNames(data.frame(matrix(ncol = 10, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)", "repository", "homepage",  "py3", "development_status", "dependencies"))
# for (d in 1:8)
# {
#   temp5 <- rbind(temp5, scrape_func(base_url = paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+5+-+Production%2FStable&c=License+%3A%3A+OSI+Approved&o=&q=&page=",d, sep=""), "Production/Stable", d))
#   #pypi_df <- rbind(pypi_df, temp5)
# }
# write.csv(temp5, '~/oss/data/oss/final/PyPI/all_scraped/production_stable.csv')

# Gets data for PyPI projects with OSI-approved licenses and with a development status of 6-Mature
temp6 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+6+-+Mature&c=License+%3A%3A+OSI+Approved", "Mature", 1)
#pypi_df <- rbind(pypi_df, temp6)
write.csv(temp6, '~/oss/data/oss/final/PyPI/all_scraped/mature.csv')
#
temp7 <- scrape_func(base_url = "https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+7+-+Inactive&c=License+%3A%3A+OSI+Approved", "Inactive", 1)
#pypi_df <- rbind(pypi_df, temp7)
write.csv(temp7, '~/oss/data/oss/final/PyPI/all_scraped/inactive.csv')

# write.csv(pypi_df, '~/oss/data/oss/final/PyPI/pypi_all.csv')
