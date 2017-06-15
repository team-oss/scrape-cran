library(XML)
library(rvest)

n<- 2 #put the total number of pages you want to scrape here

URL <- paste0("https://www.openhub.net/tags?names=", development, "&page=") #put the tag you want to explore in 2nd space

#clears the projects dataframe before building it with data
projects <- NULL

#loops through the 
for (pages in c(1:n)){
  openHub <- read_html(paste0(URL, pages))
  projects<- openHub %>%
    html_nodes(".title a") %>%
    html_text() %>%
    as.array() %>% append(projects, after = (10*n))
}
