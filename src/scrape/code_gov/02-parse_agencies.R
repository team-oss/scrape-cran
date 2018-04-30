library(rvest)
library(xml2)
library(stringr)

parse_short_name <- function(x) {
  a <- rvest::html_attr(x, 'href', default = NA)
  split <- str_split(a, '/')[[1]]
  return(split[length(split)])
}

parse_long_name <- function(x) {
  return(html_text(x, trim = TRUE))
}

parse_href <- function(x) {
  rel_path <- rvest::html_attr(x, 'href', default = NA)
  return(sprintf('%s/%s', 'https://code.gov', rel_path))
}

#parse_short_name(x)
#parse_long_name (x)


webpage <- read_html('data/oss/original/code_gov/01-explore_code.html')

# source_char <- readRDS('data/oss/original/code_gov/01-explore_code.RDS')

#html_nodes(webpage, '.sidebar-list a')

sidebar_agencies <- html_nodes(webpage, '.sidebar-list a')

sidebar_agencies

short_names <- sapply(X = sidebar_agencies, FUN = parse_short_name)
short_names

long_names <- sapply(X = sidebar_agencies, FUN = parse_long_name)
long_names

urls <- sapply(X = sidebar_agencies, FUN = parse_href)
urls

df <- data.frame('short_name' = short_names,
                 'long_name' = long_names,
                 'url' = urls)

saveRDS(df, 'data/oss/working/code_gov/agency_urls.RDS')
write.csv(df, file = 'data/oss/working/code_gov/agency_urls.csv', )
