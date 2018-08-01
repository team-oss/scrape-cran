pacman::p_load(sdalr, DBI, dplyr, data.table, dtplyr, stringr)

read_julia_contributions = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'julia_contributions') %>%
    data.table()
  on.exit(dbDisconnect(conn = conn))
  return(value = output)
  }
cost_estimates = read_julia_contributions() %>%
  select(-user) %>%
  group_by(slug) %>%
  mutate(start_date = min(start_date),
         end_date = max(end_date),
         contributors = nrow(.),
         kloc = (additions + deletions) / 1e3,
         major = sum(kloc / sum(kloc) > 5e-2),
         additions = sum(additions),
         deletions = sum(deletions),
         commits = sum(commits),
         kloc = sum(kloc)) %>%
  unique() %>%
  mutate(cost = round(18096.47 * 2.5 * (2.4 * (kloc)^1.05)^0.38, 2)) %>%
  data.table()
upload_cost_julia = function(data) {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  dbWriteTable(conn = conn,
               name = 'julia_cost_estimates',
               value = data,
               row.names = FALSE,
               overwrite = TRUE)
  on.exit(dbDisconnect(conn = conn))
  }
upload_cost_julia(data = cost_estimates)
