library(rvest)
library(xml2)
library(stringr)

webpage <- read_html('data/oss/original/code_gov/01-explore_code.html')


# Parse short names (abbreviations) ----

(short_names <- webpage %>%
  str_extract_all('href.*#/explore-code/agencies/.*?>') %>%
  .[[1]] %>%
  str_extract_all('(?<=#/explore-code/agencies/)(.*)(?=")') %>%
  unlist() %>%
  unique()
)

testthat::expect_equal(length(short_names), 25)

# Make the urls from short names ----

(urls <- paste0('https://code.gov/#/explore-code/agencies/', short_names))

# Save and write out ----

df <- data.frame('short_name' = short_names,
                 'url' = urls)

write.csv(df, file = 'data/oss/working/code_gov/agency_urls.csv', row.names = FALSE)
