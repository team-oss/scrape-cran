library(XML)
library(rvest)

n<- 2 #put the total number of pages you want to scrape here

URL <- paste0("https://www.openhub.net/tags?names=", 'development', "&page=") #put the tag you want to explore in 2nd space

#clears the projects dataframe before building it with data
projects <- NULL

#loops through the number of pages specified and compiles a list of project IDs
for (pages in c(1:n)){
  openHub <- read_html(paste0(URL, pages))
  p <- openHub %>%
    html_nodes(".title a") %>% html_attr("href")
  p <- substring(p, 4)
  projects <- c(projects, p)
}


####Scraping top X user IDs

n<- 2 #put the total number of pages you want to scrape here

URL <- paste0("https://www.openhub.net/accounts?page=") #generate URL for scraping user IDs

#clears the user_IDs and user dataframes before comiling them
user_IDs <- NULL
user <- NULL

#loops through the number of pages specified and compiles a list of user IDs by href - "/accounts/my_user_ID"
for (pages in c(1:n)){
  openHub <- read_html(paste0(URL, pages))
  user <- openHub %>%
    html_nodes(".account_details .margin_top_20") %>% html_attr("href")

  user_IDs <- c(user_IDs, user)
}

