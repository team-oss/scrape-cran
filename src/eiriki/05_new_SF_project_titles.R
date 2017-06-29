#this will be attempting to use the new sourceforge XML links to retrieve all the projects
library(RCurl)
library(xml2)
library(stringr)
library(rvest)
source(file = "~/git/lab/oss/src/eiriki/01_web_scrape.R")
source(file = "~/git/lab/oss/src/eiriki/03_web_scrape_enterprise.R")
library(tictoc)
library(data.table)

List_Titles_df <- c()
for(i in 1:166){
SFTitle_Link <- read_xml(paste('https://sourceforge.net/sitemap-', i, sep="", ".xml"))
#Get the list of the titles on the given page
List_Titles <- SFTitle_Link %>%
  xml_children() %>%
  xml_text()
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)
#match only the main source forge pages, then reset it as a data frame every time for format use
List_Titles <- List_Titles[!grepl("reviews", List_Titles$List_Titles),]
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)
List_Titles <- List_Titles[!grepl("support", List_Titles$List_Titles),]
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)
List_Titles <- List_Titles[!grepl("files", List_Titles$List_Titles),]

List_Titles_df <- rbind(List_Titles_df, as.data.frame(List_Titles, stringsAsFactors = F))
}


