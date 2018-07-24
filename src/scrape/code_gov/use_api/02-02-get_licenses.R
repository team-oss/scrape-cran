library(dplyr)
library(tidyr)

source('./R/count_values.R')

PROJECT_KEY_COLUMN <- 'name'

code_gov_df <- readRDS('./data/oss/original/code_gov/api_pull/repo_contents.RDS')

## initial data filter ----

code_gov <- dplyr::select(code_gov_df, PROJECT_KEY_COLUMN, contains('license'))

# expect all names to be unique
testthat::expect_true(all(table(code_gov$name)))


## pretty much the same steps as get_languages, but for the licenses

code_gov_license <- code_gov %>%
  dplyr::select(PROJECT_KEY_COLUMN, contains('licenses.name'))

code_gov_license$num_licenses <- apply(code_gov_license, MARGIN = 1, .GlobalEnv$count_values)
tmp_tab <- table(code_gov_license$num_licenses, useNA = 'always') # everyone has a license! cool!
tmp_tab
testthat::expect_true(is.na(tmp_tab['0'])) # expect no missing license values

code_gove_license_has <- code_gov_license %>%
  dplyr::select(-num_licenses) %>%
  tidyr::gather(key = 'licence_num', value = 'license', dplyr::starts_with('permissions.licenses.name')) %>%
  dplyr::select(-licence_num) %>%
  dplyr::filter(!is.na(license))

head(code_gove_license_has)

write.csv(code_gove_license_has, file = './data/oss/final/code_gov/project_licenses.csv', row.names = FALSE)
