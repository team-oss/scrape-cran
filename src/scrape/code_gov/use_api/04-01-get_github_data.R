source('./src/scrape/Github/contributions.R')

code_gov_df <- readRDS('./data/oss/working/code_gov/api_pull/code_gov_parsed_gh_slug.RDS')

# stuff to get the contrinutions.R script working
# token from chendaniely/nsf_toss
github_personal_token = '756e341ee87d5878e9dc48fe61c9b260d4dcd756' # Get one from https://github.com/settings/tokens
token = add_headers(token = github_personal_token)


gh_data <- purrr::map(code_gov_df$slug, .f = parse_github_repo)
names(gh_data) <- code_gov_df$name

saveRDS(gh_data, './data/oss/original/code_gov/api_pull/github_repo_data.RDS')


# parse_github_repo(USDepartmentofLabor/DotNet_DOLDataSDK)
