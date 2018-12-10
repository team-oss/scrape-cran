upload_cost <- function(data, table_name) {
  conn <- sdalr::con_db(dbname = 'oss',
                        user = rstudioapi::askForSecret('Who are you? (username)'),
                        pass = rstudioapi::askForPassword(),
                        host = 'localhost',
                        port = 5433)
  DBI::dbWriteTable(conn = conn,
                    name = table_name,
                    value = data,
                    row.names = FALSE,
                    overwrite = TRUE)
  on.exit(dbDisconnect(conn = conn))
}
