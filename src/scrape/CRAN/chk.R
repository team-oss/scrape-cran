pacman::p_load(sdalr, DBI, stringr, dplyr, data.table, dtplyr, purrr, ggplot2)

read_cran = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'CRAN_analysis') %>%
    data.table() %>%
    select(slug, kloc)
  on.exit(expr = dbDisconnect(conn = conn))
  return(value = output)
  }
cran = read_cran()
read_dependencies = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'cran_dependencies') %>%
    data.table()
  on.exit(expr = dbDisconnect(conn = conn))
  return(value = output)
}
dependencies = read_dependencies()
pkgs = unique(x = dependencies$name)
read_keys = function() {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  output = dbReadTable(conn = conn,
                       name = 'CRAN_name_slug_keys') %>%
    select(name, slug) %>%
    data.table()
  on.exit(expr = dbDisconnect(conn = conn))
  return(value = output)
  }
keys = read_keys()

output = merge(x = cran,
               y = keys) %>%
  select(name, kloc) %>%
  mutate(cost = round(18096.47 * 2.5 * (2.4 * (kloc)^1.05)^0.38, 2)) %>%
  data.table()

output2 = dependencies %>%
  filter((name %in% output$name) |
           (dependencies %in% output$name))
