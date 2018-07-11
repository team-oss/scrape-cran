library(stringr)
library(dplyr)

pypi1 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/planning.csv")
pypi1 <- pypi1[2:56,]
pypi2 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/pre_alpha.csv")
pypi3 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/alpha1.csv")
pypi3 <- pypi3[2:61,]
pypi4 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/alpha2.csv")
pypi4 <- pypi4[2:46,]
pypi5 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/beta.csv")
pypi5 <- pypi5[2:206,]
pypi6 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/production_stable.csv")
pypi6 <- pypi6[2:143,]
pypi7 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/mature.csv")
pypi8 <- read.csv("~/oss/data/oss/final/PyPI/all_scraped/inactive.csv")

all_pypi <- rbind(pypi1, pypi2, pypi3, pypi4, pypi5, pypi6, pypi7, pypi8)

#COMPLETENESS
completeness <- setNames(data.frame(matrix(ncol = 3, nrow = 10)), c("category", "complete", "incomplete"))

total <- nrow(all_pypi)
names_incomp <- (sum(is.na(all_pypi$description))/total) * 100
completeness$category[1] <- "Names"
completeness$complete[1] <- 100 - names_incomp
completeness$incomplete[1] <- names_incomp
description_incomp <- (sum(is.na(all_pypi$description))/total) * 100
completeness$category[2] <- "Description"
completeness$complete[2] <- 100 - description_incomp
completeness$incomplete[2] <- description_incomp
license_incomp <- (sum(is.na(all_pypi$license))/total) * 100
completeness$category[3] <- "License"
completeness$complete[3] <- 100 - license_incomp
completeness$incomplete[3] <- license_incomp
author_incomp <- (sum(is.na(all_pypi$author))/total) * 100
completeness$category[4] <- "Author"
completeness$complete[4] <- 100 - author_incomp
completeness$incomplete[4] <- author_incomp
maintainers_incomp <- (sum(is.na(all_pypi$maintainer.s.))/total) * 100
completeness$category[5] <- "Maintainer(s)"
completeness$complete[5] <- 100 - maintainers_incomp
completeness$incomplete[5] <- maintainers_incomp
repo_incomp <- (sum(is.na(all_pypi$repository))/total) * 100
completeness$category[6] <- "Repository"
completeness$complete[6] <- 100 - repo_incomp
completeness$incomplete[6] <- repo_incomp
hmpg_incomp <- (sum(is.na(all_pypi$homepage))/total) * 100
completeness$category[7] <- "Homepage"
completeness$complete[7] <- 100 - hmpg_incomp
completeness$incomplete[7] <- hmpg_incomp
py3_incomp <- (sum(is.na(all_pypi$py3))/total) * 100
completeness$category[8] <- "Python_3"
completeness$complete[8] <- 100 - py3_incomp
completeness$incomplete[8] <- py3_incomp
dev_incomp <- (sum(is.na(all_pypi$development_status))/total) * 100
completeness$category[9] <- "Development_Status"
completeness$complete[9] <- 100 - dev_incomp
completeness$incomplete[9] <- dev_incomp
dep_incomp <- (sum(is.na(all_pypi$dependencies))/total) * 100
completeness$category[10] <- "Dependencies"
completeness$complete[10] <- 100 - dep_incomp
completeness$incomplete[10] <- dep_incomp

#LIST ALL GITHUB REPOS
github_urls <- setNames(data.frame(matrix(ncol = 1, nrow = 1)), "github_url")

num <- 1
for (i in 1:nrow(all_pypi))
{
  if (grepl("github", all_pypi$repository[i])){
    github_urls[num,1] <- as.character(all_pypi[i,7])
    num = num + 1
  } else if (grepl("github", all_pypi$homepage[i])){
    github_urls[num,1] <- as.character(all_pypi[i,8])
    num = num + 1
  }
}

names <- as.data.frame(all_pypi$name)
write.csv(names, "~/oss/data/oss/working/pypi/01names.csv")

# repo_hmpg <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("repo", "hmpg"))
# num2 <- 1
# for (j in 1:nrow(all_pypi))
# {
#   if (((grepl("github", all_pypi$repository[j])) && (grepl("github", all_pypi$homepage[j]))) && ((grepl("github", all_pypi$repository[j])) == (grepl("github", all_pypi$homepage[j]))))
#   {
#     repo_hmpg[num2,1] <- as.character(all_pypi[j,7])
#     repo_hmpg[num2,2] <- as.character(all_pypi[j,8])
#     num2 = num2 + 1
#   }
#
# }
