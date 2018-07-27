library(RSQLite)
library(sdalr)
complete_osi <- read.csv("~/oss/data/oss/final/PyPI/complete_osi_info.csv")
complete_osi$X <- NULL
gh <- read.csv("~/oss/data/oss/working/pypi/10_github_api_info.csv")
gh$X.1 <- NULL
gh$X <- NULL

deps <- read.csv("~/oss/data/oss/final/PyPI/python_pkg_dependencies.csv")

# COMPLETENESS
names_comp <- (sum(!is.na(complete_osi$name)) / nrow(complete_osi)) * 100
dev_status_comp <- (sum(!is.na(complete_osi$development_status)) / nrow(complete_osi)) * 100
license <- (sum(!is.na(complete_osi$license)) / nrow(complete_osi)) * 100
rel_date <- (sum(!is.na(complete_osi$latest_release_date)) / nrow(complete_osi)) * 100
version <- (sum(!is.na(complete_osi$version)) / nrow(complete_osi)) * 100
github_repo <- (sum(!is.na(complete_osi$slugs)) / nrow(complete_osi)) * 100
stars <- (sum(!is.na(complete_osi$stars)) / nrow(complete_osi)) * 100
num_contr <- (sum(!is.na(complete_osi$num_contributors)) / nrow(complete_osi)) * 100
loc <- (sum(!is.na(complete_osi$lines_of_code)) / nrow(complete_osi)) * 100
dep_comp <- ((length(unique(deps$package_name)) - sum(is.na(deps$dependency_name))) / nrow(complete_osi)) * 100

contr_info <- select(complete_osi, name, num_contributors, lines_of_code)

upload_pkg = function(data) {
  conn = con_db(dbname = 'oss',
                pass = get_my_password())
  dbWriteTable(conn = conn,
               name = '',
               value = data,
               row.names = FALSE,
               overwrite = TRUE)
  on.exit(expr = dbDisconnect(conn = conn))
}

