# Packages failed because of <doi:xxxx> is not a valid XML tag
# replace <doi:.*> with <doi>MANUALLY REPLACED DOI</doi>

library(stringr)
library(progress)
library(rvest)

# Find out which packages were not scraped ----

pkgs <- read.csv('./data/oss/original/bioconductor/3.7/packages_v3.7.csv', stringsAsFactors = FALSE)
pkg_files <- list.files('./data/oss/original/bioconductor/3.7/pkgs/')

nrow(pkgs)
length(pkg_files)

nrow(pkgs) - length(pkg_files)

failed <- setdiff(pkgs$Package, str_remove(pkg_files, '.html'))

failed_df <- pkgs[pkgs$Package %in% failed, ]
failed_df

failed_urls <- failed_df$url

save_file_path <- sprintf('./data/oss/original/bioconductor/3.7/pkgs/bad_xml/%s.html', failed)

testthat::expect_equal(length(failed_urls), length(save_file_path))

# Download bad XML pages ----

pb <- progress_bar$new(total = length(failed_urls))
for (i in 1:length(failed_urls)) {
  url <- failed_urls[i]
  path <- save_file_path[i]
  xml2::download_html(url, file = path, )
  pb$tick()
  Sys.sleep(runif(1, 0, 1))
}

# Replace bad xml tags ----

pb <- progress_bar$new(total = length(save_file_path))
for (file in save_file_path) {
  #print(file)
  txt <- readLines(file)
  txt[str_detect(txt, '<doi:.*>')]
  new_txt <- str_replace(txt, '<doi:.*>', '<doi>MANUALLY REPLACED DOI</doi>')
  new_file_path <- str_replace(file, '/bad_xml/', '/fixed_xml/')
  writeLines(new_txt, con = new_file_path)
  pb$tick()
}

# Check if things load ----

fixed_files <- list.files('./data/oss/original/bioconductor/3.7/pkgs/fixed_xml/', full.names = TRUE)

# if it loads without error, then good
for (f in fixed_files) {
  read_html(f)
}
