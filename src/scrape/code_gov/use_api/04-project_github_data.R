library(purrr)
library(dtplyr)

gh_data <- readRDS('./data/oss/original/code_gov/api_pull/github_repo_data.RDS')

add_name_to_gh_data <- function(gh_data, list_name) {
  gh_data$name <- list_name
  return(gh_data)
}

named_dfs <- mapply(add_name_to_gh_data, gh_data, names(gh_data))

dt <- data.table::rbindlist(named_dfs, fill = TRUE)[, V1 := NULL]

write.csv(dt, file = 'data/oss/final/code_gov/project_github_info.csv', row.names = FALSE)
