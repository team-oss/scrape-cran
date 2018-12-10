# does not recalculate kloc value
# only applies formula to calculate costs

library(sdalr)
library(dplyr)
library(DBI)

conn <- sdalr::con_db(dbname = 'oss',
                      user = rstudioapi::askForSecret('Username'),
                      pass = rstudioapi::askForPassword(),
                      host = 'localhost',
                      port = 5433)

calculate_cost_from_kloc <- function(dta) {
  costs_df <- dta %>%
    dplyr::mutate(cost_18096.47 = round(18096.47 * 2.5 * (2.4 * (kloc)^1.05)^0.38, 2),
                  cost_19963.55 = round(19963.55 * 2.5 * (2.4 * (kloc)^1.05)^0.38, 2)
    ) %>%
    select(-cost)
  return(costs_df)
}

# CRAN -----

db_tbl <- DBI::dbReadTable(conn = conn, name = 'CRAN_analysis') %>%
  calculate_cost_from_kloc()
DBI::dbWriteTable(conn = conn, name = 'CRAN_direct_download_costs_recalculated', value = db_tbl,
                  row.names = FALSE, overwrite = TRUE)

# Python -----

db_tbl <- DBI::dbReadTable(conn = conn, name = 'python_final') %>%
  calculate_cost_from_kloc()
DBI::dbWriteTable(conn = conn, name = 'python_cost_estimates_recalculated', value = db_tbl,
                  row.names = FALSE, overwrite = TRUE)

# Julia -----

db_tbl <- DBI::dbReadTable(conn = conn, name = 'julia_cost_estimates') %>%
  calculate_cost_from_kloc()
DBI::dbWriteTable(conn = conn, name = 'julia_cost_estimates_recalculated', value = db_tbl,
                  row.names = FALSE, overwrite = TRUE)

# codegov -----
# code_gov_contributions <- DBI::dbReadTable(conn, 'code_gov_contribitions') %>%
#   select(-user) %>%
#   group_by(slug) %>%
#   mutate(start_date = min(start_date),
#          end_date = max(end_date),
#          contributors = nrow(.),
#          kloc = (additions + deletions) / 1e3,
#          major = sum(kloc / sum(kloc) > 5e-2),
#          additions = sum(additions),
#          deletions = sum(deletions),
#          commits = sum(commits),
#          kloc = sum(kloc)) %>%
#   unique() %>%
#   mutate(cost = round(18096.47 * 2.5 * (2.4 * (kloc)^1.05)^0.38, 2))
# DBI::dbWriteTable(conn = conn, name = 'codegov_cost_estimates', value = code_gov_contributions,
#                   row.names = FALSE, overwrite = TRUE)

db_tbl <- DBI::dbReadTable(conn = conn, name = 'codegov_cost_estimates') %>%
  calculate_cost_from_kloc()
DBI::dbWriteTable(conn = conn, name = 'codegov_cost_estimates_recalculated', value = db_tbl,
                  row.names = FALSE, overwrite = TRUE)

# CDNJS -----
db_tbl <- DBI::dbReadTable(conn = conn, name = 'cdn_final') %>%
  calculate_cost_from_kloc()
DBI::dbWriteTable(conn = conn, name = 'cdn_cost_estimates_recalculated', value = db_tbl,
                  row.names = FALSE, overwrite = TRUE)

