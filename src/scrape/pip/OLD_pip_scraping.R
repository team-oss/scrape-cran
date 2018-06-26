library(RCurl)
library(XML)
library(rvest)

pip_df <- setNames(data.frame(matrix(ncol = 5, nrow = 1)), c("name", "description", "license", "author", "maintainer(s)"))

position <- 1

base_site <- paste("https://pypi.org/search/?q=&o=&c=Development+Status+%3A%3A+5+-+Production%2FStable&c=License+%3A%3A+OSI+Approved&o=&q=&page=1", sep = "")
base_site_html <- read_html(base_site)

names <- base_site_html %>% html_nodes('.package-snippet__title a') %>% html_text()

for (i in 1:length(names))
{
  #Sys.sleep(5)

  proj_site <- paste("https://pypi.org/project/", names[i], sep = "")
  proj_site_html <- read_html(proj_site)

  descr <- proj_site_html %>% html_nodes('.package-description__summary') %>% html_text()
  license <- proj_site_html %>% html_nodes('.sidebar-section:nth-child(4) .sidebar-section__title+ p') %>% html_text()
  author <- proj_site_html %>% html_nodes('strong+ a') %>% html_text()
  maint <- proj_site_html %>% html_nodes('.sidebar-section__user-gravatar-text') %>% html_text()
  maint2 = maint[1]

  for (j in 1:(length(maint)/2))
  {
    maint2[j] <- trimws(maint[j])
  }

  maintainers <- gsub("'","",paste(shQuote(maint2, type="sh"), collapse=", "))

  pip_df[position, 1] <- names[i]
  pip_df[position, 2] <- descr[1]
  pip_df[position, 3] <- license[1]
  pip_df[position, 4] <- author[1]
  pip_df[position, 5] <- maintainers

  position = position + 1
}
