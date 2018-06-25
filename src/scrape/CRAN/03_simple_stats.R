#analysis of cran
data <- readRDS(file = './data/oss/working/CRAN_2018/Cran_full_table.RDS')
data <- data.frame(data)

#Na's in each column
na_count <-colSums(is.na(data))

na_count <- data.frame(na_count)
na_count <- na_count / 12614 #make percentage missing
na_count <- round(na_count, digits =4) *100


#temp scrape
#function for each package page
library(rvest)
library(xml2)
library(stringr)
library(magrittr)
#read in link to package
CRANLink <- read_html('https://cran.r-project.org/web/packages/A3/')

#get the title of the package
long_title <- CRANLink %>%
  html_node('h2') %>%
  html_text() %>%
  str_trim() %>%
  str_replace_all(pattern = '\n', replacement = ' ') #cut out newlines

#parse abbreviated title
ptitle <- str_extract(long_title,"(?<=\\: ).*")
#parse the full title
abrv <- str_extract(long_title,".*(?=\\:)")


tabs <- CRANLink %>%
  html_node('table') %>%
  html_table()
tabs <- t(tabs)
tabs

links <- CRANLink %>%
  html_nodes('p+ table a')

frame <- cbind(abrv,ptitle,tabs)
frame <- list(frame)
frame[[1]][1] <- "Abrv"
frame[[1]][3] <- "Desc"
frame

############# need to get links to citations and links to tests
