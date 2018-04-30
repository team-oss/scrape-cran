#this script made a single data frame of all the project links on sourceforge using their API and XML
library(RCurl)
library(xml2)
library(stringr)
library(rvest)
library(data.table)

List_Titles_df <- c()
for(i in 1:166){
SFTitle_Link <- read_xml(paste('https://sourceforge.net/sitemap-', i, sep="", ".xml"))
#Get the list of the titles on the given page
List_Titles <- SFTitle_Link %>%
  xml_children() %>%
  xml_text()
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)

#match only the main source forge pages(exclude reviews, support, files), then reset it as a data frame every time for format use
List_Titles <- List_Titles[!grepl("reviews", List_Titles$List_Titles),]
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)
List_Titles <- List_Titles[!grepl("support", List_Titles$List_Titles),]
List_Titles <- as.data.frame(List_Titles, stringsAsFactors = F)
List_Titles <- List_Titles[!grepl("files", List_Titles$List_Titles),]

List_Titles_df <- rbind(List_Titles_df, as.data.frame(List_Titles, stringsAsFactors = F))
}


