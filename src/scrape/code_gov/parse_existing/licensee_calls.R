df <- read.csv('./data/oss/original/code_gov_2018-06-27/agencies/agency_project_button_url.csv')

names(df)
head(df)


df$is_github <- stringr::str_detect(df$button_url, 'github.com')

table(df$is_github, useNA = 'always')

