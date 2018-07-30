source('R/parse_github_slug.R')

code_gov_df <- readRDS('./data/oss/working/code_gov/api_pull/repo_contents_missing.RDS')

code_gov_df$slug <- purrr::map_chr(code_gov_df$repositoryURL, .GlobalEnv$parse_github_slug)

saveRDS(code_gov_df, './data/oss/working/code_gov/api_pull/code_gov_parsed_gh_slug.RDS')
