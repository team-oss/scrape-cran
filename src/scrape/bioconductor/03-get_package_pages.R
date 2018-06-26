# pull all the html from each package page


library(progress)
library(rvest)

pkgs <- read.csv('./data/oss/original/bioconductor/3.7/packages_v3.7.csv', stringsAsFactors = FALSE)

num_pkgs <- nrow(pkgs)

pb <- progress_bar$new(total = num_pkgs)

for (i in 1:num_pkgs) {
  url <- pkgs[i, 'url']
  pkg <- pkgs[i, 'Package']

  save_file_path <- sprintf('./data/oss/original/bioconductor/3.7/pkgs/%s.html', pkg)

  if (file.exists(save_file_path)) {
    pb$tick()
    next
  } else {
    tryCatch({
      page <- read_html(url,
                        options = c("RECOVER", "NOERROR", "NOBLANKS"))

      write_html(page, save_file_path)

      pb$tick()
      Sys.sleep(runif(1, 0, 30))
    }, error = function(e) {
      print(sprintf('Error: %s', url))
      pb$tick()
      #next ## don't need next in error catch
    })
  }
}
