library(tibble)
library(dplyr)
library(urltools)
library(readr)

source(here::here('./R/file_paths.R'))

code_gov_df <- readRDS(.GlobalEnv$CODE_GOV_ORIGINAL_API) %>%
  tibble::as_tibble()

table(code_gov_df$permissions.licenses.name, useNA = 'always') %>% sort(decreasing = TRUE) %>% addmargins()

code_gov_osi_spellings <- c(
  'BSD-3-Clause',
  'NASA v3',
  'Apache-2.0',
  'Creative Commons Zero (CC0)',
  'GPL-2.0',
  'CC0',
  'MIT',
  'LGPL-2.1',
  'mit',
  'cc0-1.0',
  'BSD-2-Clause',
  'apache-2.0',
  'GPL-3.0',
  'LGPL-3.0',
  'CC0-1.0',
  'GPL.v3',
  'Microsoft', # need to specify this
  'gpl-3.0',
  'gpl-2.0',
  #'Open Source', # no idea what this means
  'GPLv2',
  'Apache',
  'Apache 2.0',
  'GPL-2.1',
  'MPL-2.0',
  'agpl-3.0',
  'EPL-1.0',
  'Apache License 2.0',
  'bsd-3-clause',
  'mpl-2.0',
  'AGPL-3.0',
  'Apache v2',
  'bsd-2-clause',
  'AGPL',
  'BSD',
  'GPL v2',
  'GPLV2',
  'GPLv6',
  'isc',
  'lgpl-2.1',
  'lgpl-3.0',
  'Mozilla Public License',
  'ofl-1.1'
)

# osi -----
code_gov_df <- code_gov_df %>%
  dplyr::mutate(osi_approved = dplyr::case_when(
    permissions.licenses.name %in% code_gov_osi_spellings ~ TRUE,
    is.na(permissions.licenses.name) ~ NA,
    !permissions.licenses.name %in% code_gov_osi_spellings ~ FALSE,
    TRUE ~ NA
    # note NA values for permissions.licenses.name are coded as FALSE
  ))

table(code_gov_df$osi_approved, useNA = 'always')

addmargins(table(code_gov_df$permissions.licenses.name, code_gov_df$osi_approved, useNA = 'always'))

res <- addmargins(table(code_gov_df$permissions.licenses.name,
                        code_gov_df$osi_approved,
                        code_gov_df$agency.acronym,
                        useNA = 'always'))

res <- as.data.frame(res)

# repositoryURL domain -----

code_gov_df <- code_gov_df %>%
  dplyr::mutate(
    repositoryURL_domain = urltools::suffix_extract(urltools::domain(repositoryURL))$domain,
    repositoryURL_domain = stringr::str_to_lower(repositoryURL_domain)
)

readr::write_delim(code_gov_df, './data/oss/final/code_gov/2018-12-05-api_pull_repo_contents.tsv', delim = '\t')
