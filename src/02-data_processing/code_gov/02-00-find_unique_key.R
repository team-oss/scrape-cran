# main findings:
# the repoID column is the actual unique value for each row in the dataset
# the status column can be used to filter down to "production" ready software

library(tibble)
library(dplyr)
library(tidyr)

PROJECT_KEY_COLUMNS <- c('name', 'organization', 'downloadURL', 'repositoryURL', 'repoID')

code_gov_df <- readRDS('./data/oss/original/code_gov/api_pull/2018-12-05-repo_contents.RDS') %>%
  tibble::as_tibble()

# just filter down columns to get a better sense of what is in here
sub_cols <- code_gov_df %>%
  select(-contains('tags'), -contains('languages'), -contains('permission'), -vcs, -starts_with('X.'))

top_5

code_gov_df %>%
  dplyr::mutate(organization = tidyr::replace_na(organization, 'missing')) %>%
  dplyr::select(organization) %>%
  table(useNA = 'always')

code_gov_df %>%
  select(downloadURL, repositoryURL) %>%
  print(n = 100)




URLs <- c("http://stackoverflow.com/questions/19020749/function-to-extract-domain-name-from-url-in-r",
          "http://www.talkstats.com/", "www.google.com")
suffix_extract(domain(URLs))$domain
sub

# recode missing values
code_gov_df$organization[is.na(code_gov_df$organization)] <- ('missing')
testthat::expect_true(sum(is.na(code_gov_df$organization)) == 0)

# get duplicated project names
# if a project name is duplicated,
# we want to know if it is a coincidence, or if they are the same project (usually under a different organization)
# we also need to know what columns can serve as unique key values
dup_names <- code_gov_df$name[duplicated(code_gov_df$name)]

tmp <- code_gov_df %>%
  select(PROJECT_KEY_COLUMNS)

tmp_dup_names <- tmp %>%
  filter(name %in% dup_names)

# none of the rows are duplicated
# just the 'name'
# the values in PROJECT_KEY_COLUMNS serve as unique values
# where repoID is actually unique for each row
testthat::expect_equal(sum(duplicated(code_gov_df$repoID)), 0)
testthat::expect_equal(sum(duplicated(tmp_dup_names)), 0)

no_dups <- code_gov_df %>%
  select(PROJECT_KEY_COLUMNS)
testthat::expect_equal(sum(duplicated(no_dups)), 0)

# duplicated repositoryURLs
no_dups %>%
  filter(duplicated(no_dups$repositoryURL))



saveRDS(code_gov_df, './data/oss/working/code_gov/api_pull/repo_contents_missing.RDS')
saveRDS(PROJECT_KEY_COLUMNS, './data/oss/working/code_gov/api_pull/project_key_columns.RDS')
