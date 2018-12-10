library(dplyr)
library(tidyr)

source('./R/count_values.R')

PROJECT_KEY_COLUMNS <- readRDS('./data/oss/working/code_gov/api_pull/project_key_columns.RDS')
code_gov_df <- readRDS('./data/oss/working/code_gov/api_pull/repo_contents_missing.RDS')


## initial data filter ----

code_gov <- code_gov_df %>%
  select(repoID, name, organization, description, contact.email, contact.name, status,
         downloadURL, repositoryURL, homepageURL,
         agency.name, agency.acronym, agency.website, agency.codeUrl,
         contains('language'),
         contains('license'))

# make sure my primary keys are in the dataset
testthat::expect_true(all(PROJECT_KEY_COLUMNS %in% names(code_gov)))

## prep language columns ----

# are there projects that do not have a listed language? yes
code_gov_language <-  dplyr::select(code_gov, starts_with('language'))

code_gov$num_languages <- apply(code_gov_language, MARGIN = 1, .GlobalEnv$count_values)
table(code_gov$num_languages, useNA = 'always')

# add a language missing column
# for the gather dropna step
# this way projects are not removed from the data
code_gov <- dplyr::mutate(code_gov,
                          language_missing = dplyr::if_else(num_languages == 0, 'missing', 'has'))
addmargins(table(code_gov$num_languages, code_gov$language_missing, useNA = 'always'))


## create language tables -----
# split into has language and no language dfs
# then combine them together for final dataset

# using name as key
code_gov_proj_languages_none <- code_gov %>%
  dplyr::select(PROJECT_KEY_COLUMNS, "language_missing") %>%
  dplyr::filter(language_missing == "missing") %>%
  dplyr::select(-language_missing) %>%
  dplyr::mutate(language = 'none')
testthat::expect_true(table(code_gov$num_languages, useNA = 'always')['0'] == nrow(code_gov_proj_languages_none))

code_gov_proj_languages_has <- code_gov %>%
  dplyr::filter(language_missing == 'has') %>%
  dplyr::select(PROJECT_KEY_COLUMNS, contains('language'), -"language_missing") %>%
  tidyr::gather(key = 'language_col', value = 'language',
                dplyr::starts_with('languages')) %>%
  dplyr::select(-language_col) %>%
  dplyr::filter(!is.na(language))
head(code_gov_proj_languages_has)

# check has values
# are the grouped language counts, the same as the original row-wise lang counts?
tmp_chk_1 <- code_gov_proj_languages_has %>%
  dplyr::group_by_(PROJECT_KEY_COLUMNS) %>%
  dplyr::summarize(num_languages = n()) %>%
  dplyr::arrange_(PROJECT_KEY_COLUMNS)

tmp_chk_2 <- code_gov %>%
  dplyr::filter(language_missing == 'has') %>%
  dplyr::select(name, num_languages) %>%
  dplyr::arrange_(PROJECT_KEY_COLUMNS)

testthat::expect_equal(tmp_chk_1, tmp_chk_2)

## Combine has with none and save out -----

# there should be no names that are in the has and none
testthat::expect_equal(length((dplyr::intersect(code_gov_proj_languages_none$name, code_gov_proj_languages_has$name))),
                       0)

code_gov_proj_languages_has <- code_gov_proj_languages_has %>%
  select(-num_languages)

code_gov_proj_languages <- dplyr::bind_rows(code_gov_proj_languages_none, code_gov_proj_languages_has)

write.csv(code_gov_proj_languages, file = './data/oss/final/code_gov/project_languages.csv', row.names = FALSE)
