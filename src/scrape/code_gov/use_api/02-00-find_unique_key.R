library(dplyr)
library(tidyr)

PROJECT_KEY_COLUMNS <- c('name', 'organization', 'repositoryURL')

code_gov_df <- readRDS('./data/oss/original/code_gov/api_pull/repo_contents.RDS')

code_gov_df$organization[is.na(code_gov_df$organization)] <- ('missing')

testthat::expect_true(sum(is.na(code_gov_df$organization)) == 0)

dup_names <- code_gov_df$name[duplicated(code_gov_df$name)]

tmp <- code_gov_df %>%
  select(PROJECT_KEY_COLUMNS) %>%
  tibble::as_tibble()

tmp_dup_names <- tmp %>%
  filter(name %in% dup_names)

testthat::expect_equal(sum(duplicated(tmp_dup_names)), 0)


saveRDS(code_gov_df, './data/oss/working/code_gov/api_pull/repo_contents_missing.RDS')
saveRDS(PROJECT_KEY_COLUMNS, './data/oss/working/code_gov/api_pull/project_key_columns.RDS')
