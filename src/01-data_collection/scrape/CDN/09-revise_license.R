#parse license info in the second round

#libraries
library(data.table)
library(stringr)
library(dplyr)
library(purrr)
library(httr)
library(DBI)
library(sdalr)
source("functions_keren.R")

#set up
#load dfs
my_db_con <- sdalr::con_db("oss", pass=sdalr::get_my_password())
standard_licenses <- DBI::dbReadTable(my_db_con, "licenses")
standard_licenses <- rbind(standard_licenses, data.frame(name = "custom", id = "Custom", osi = FALSE))
standard_licenses <- rbind(standard_licenses, data.frame(name = "Public Domain", id = "PD", osi = TRUE))
licenses <- DBI::dbReadTable(my_db_con, "CDN_licenses_info")
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)

#change this to personal github token
Github_API_token = "2d260070668afe675673e973faf2ec30b48e831c"

#these are part of the licenses recognized/valid for this researches purpose
#these are the licenses fixed in the standarlize function;
#this serves solely as a list of license; not explicitly used anywhere
dabbed_license = c("AGPL-3.0",
                   "Apache-2.0",
                   "Artistic-2.0",
                   "BSD-2-Clause-FreeBSD",
                   "BSD-2-Clause",
                   "BSD-3-Clause",
                   "Custom",
                   "EPL-1.0",
                   "GPL-2.0",
                   "GPL-3.0",
                   "LGPL-2.1",
                   "LGPL-3.0",
                   "MIT",
                   "MPL-2.0",
                   "OFL-1.1",
                   "PD",
                   "Zlib")

#functions
#hardcoded: standarlize the format of valid licenses
#license is a vector of licenses of a package
#returns the standarlized version of the license vector
standarlize = function (license){

  #helper functions serving as and/or str_detect
  and_checker = function(x){all(str_detect(x, regex(targets, ignore_case = T)))}
  or_checker = function(x){any(str_detect(x, regex(targets, ignore_case = T)))}

  #detect and fix licenses
  targets = c("AGPL", "3")
  license[map_lgl(.x = license, .f = and_checker)] = "AGPL-3.0"

  targets = c("Apache", "2")
  license[map_lgl(.x = license, .f = and_checker)] = "Apache-2.0"

  targets = c("Artistic", "2")
  license[map_lgl(.x = license, .f = and_checker)] = "Artistic-2.0"

  targets = c("BSD", "2", "free")
  license[map_lgl(.x = license, .f = and_checker)] = "BSD-2-Clause-FreeBSD"

  targets = c("BSD", "2")
  license[map_lgl(.x = license, .f = and_checker) & !str_detect(license, regex("free", ignore_case = T))] = "BSD-2-Clause"

  targets = c("BSD", "3")
  license[map_lgl(.x = license, .f = and_checker) & !str_detect(license, regex("clear", ignore_case = T))] = "BSD-3-Clause"

  targets = c("BSD", "new")
  license[map_lgl(.x = license, .f = and_checker) & !str_detect(license, regex("clear", ignore_case = T))] = "BSD-3-Clause"

  targets = "Custom"
  license[map_lgl(.x = license, .f = and_checker)] = "Custom"

  targets = c("Eclipse", "EPL")
  license[map_lgl(.x = license, .f = or_checker)] = "EPL-1.0"

  targets = c("GPL", "2")
  license[map_lgl(.x = license, .f = and_checker) & !str_detect(license, "\\+")] = "GPL-2.0"

  targets = c("GPL", "3")
  license[map_lgl(.x = license, .f = and_checker)] = "GPL-3.0"

  targets = "LGPL-2.1"
  license[map_lgl(.x = license, .f = and_checker)] = "LGPL-2.1"

  targets = c("LGPL", "3")
  license[map_lgl(.x = license, .f = and_checker)] = "LGPL-3.0"


  targets = "MIT"
  license[map_lgl(.x = license, .f = and_checker) & !str_detect(license, regex("GreenSock", ignore_case = T))] = "MIT"

  targets = "Mozilla Public License"
  license[map_lgl(.x = license, .f = and_checker)] = "MPL-2.0"

  targets = c("OFL", "1.1")
  license[map_lgl(.x = license, .f = and_checker)] = "OFL-1.1"

  targets = "Public Domain"
  license[map_lgl(.x = license, .f = and_checker)] = "PD"

  targets = "Zlib"
  license[map_lgl(.x = license, .f = and_checker)] = "Zlib"

  #return the fixed vector
  return(license)
}

#parse the result from licensee
#textfile is the licensee resulting text file's content as a string
#returns a dt containing parsed license info
#PS: this could be from Bayoan
parse_license_type = function(textfile) {

  #detect the owner and pkg name of the corresponfing pkg
  owner = str_extract(string = textfile,

                      pattern = '(?<=Licenses/).*(?=_)')

  name = str_extract(string = textfile,

                       pattern = str_c('(?<=', owner, '_).*(?=.txt)'))

  license_text = readLines(con = textfile)

  #if textfile is empty
  if (is_empty(x = license_text)) {

    license = NA

    confidence = NA

  }
  #if there is no license
  else if (license_text[1] == 'License:  None') {

    license = 'BC'

    confidence = 1e2

  }
  #if there is no confident license
  else if (license_text[1] != 'License:        NOASSERTION') {

    license = str_remove(string = license_text[1],

                         pattern = '\\s*License:\\s+')

    confidence = license_text[str_detect(string =  license_text,

                                         pattern = '  Confidence:\\s+')]

    confidence = str_extract(string = confidence,

                             pattern = '\\d{1,3}.\\d{2}') %>%

      as.numeric()

  }
  #there is at least a license detected, parse it
  else {

    #extract possible licenses
    license = license_text[str_detect(string = license_text,

                                      pattern = '  License:\\s+')]

    license = license[license != '  License:       NOASSERTION']

    if (!is_empty(x = license)) {

      license = str_remove(string = license,

                           pattern = '\\s+License:\\s+')

      confidence = str_extract(string = license_text,

                               pattern = '\\d{1,3}\\.\\d{2}') %>%

        na.omit() %>%

        getElement(name = 1L) %>%

        as.numeric()

    } else {

      license = str_detect(string = license_text,

                           pattern = '\\d{1,3}\\.\\d{2}') %>%

        which() %>%

        getElement(name = 1L)

      confidence = str_extract(string = license_text[license],

                               pattern = '\\d{1,3}\\.\\d{2}') %>%

        as.numeric()

      license = str_extract(string = license_text[license],

                            pattern = '.*(?=similarity)') %>%

        str_trim()

    }

  }

  #output dt
  output = data.table(owner = owner,

                      name = name,

                      license = license,

                      confidence = confidence)

  return(value = output)

}

#detect license using licensee
#repo is the repo url
#PS: this could be from Bayoan
helper = function(repo) {
  filename = str_c('./data/oss/original/CDN/Licenses/',
                   str_extract(string = repo,
                               pattern = '(?<=github\\.com(/|:)).*') %>%
                     str_remove("(/|\\.git)$") %>%
                     str_replace_all("/", "_"),
                   '.txt')
  system(command = str_c('touch ', filename))

  response = str_c('https://api.github.com/',
                   'repos',
                   '/',
                   str_extract(string = repo,
                               pattern = '(?<=github\\.com(/|:)).*') %>%
                     str_remove("(/|\\.git)$"),
                   '/',
                   'contents') %>%
    GET(add_headers(Authorization = str_c('token ', Github_API_token)))
  
  if ((file.info(filename)$size == 0L) & (status_code(response) == 200)) {
    system(command = str_c('OCTOKIT_ACCESS_TOKEN=',
                           Github_API_token,
                           ' licensee detect ',
                           repo,
                           ' > ',
                           filename))
    Sys.sleep(time = 5e-1)
  }
}

#get the first row of a df
#df is a dataframe
#returns the first row of the df
get_top = function(df) {
  if (nrow(df) == 0) {
    return(data.frame())
  }
  return(df[1])
}

#read all the licensee results in as dt
#returns a dt contaning all the licenses corresponding to each pkg by licesee
#PS: this could be from Bayoan
standarlize_licensee = function() {

  filenames = str_c('./data/oss/original/CDN/Licenses',
                    list.files(path = './data/oss/original/CDN/Licenses'),
                    sep = '/')

  licenses_list <- lapply(X = filenames, FUN = parse_license_type)
  output <- lapply(licenses_list, get_top)
  dt <- rbindlist(output, fill = TRUE)

  return(dt)
}

#combines results from hardcoded standarlization (standarlize) and licensee results (parse_license_type)
#per_manual is the result from hardcoded standarlization
#per_licensee is the result from licensee
#returns the merged result df
standarlize_overall = function(per_manual, per_licensee) {
  temp = merge(per_manual, per_licensee, by = "name", all = TRUE)
  temp = mutate(temp, license_selected = ifelse((is.na(license_selected) | str_detect(license_selected, "http")),
                                      yes = license,
                                      no = as.character(license_selected)))

  authors <- DBI::dbReadTable(my_db_con, "cdn_authors_info")
  result = merge(temp, authors)
  result = data.frame(result$name, result$author, result$license_selected)
  return (result)
}

#detect whether a package has a license recognized by osi
#pkg_license is a string of a license
#returns true if the license is recognized by osi, false if otherwise
osi_status = function(pkg_license) {
  if (pkg_license %in% standard_licenses$id) {
    return(standard_licenses$osi[standard_licenses$id == pkg_license])
  }
  return(FALSE)
}
#################################################################
#script

#manual detection
manual_license = data.frame(name = licenses$pkg_name, license_selected = standarlize(licenses$license_selected))
#save csv
write.csv(manual_license, file = "data/oss/final/CDN/license_per_manual.csv", row.names=FALSE)

#extract repos
repos = general_info$repository.url[str_detect(string = general_info$repository.url, pattern = 'github\\.com') %in% TRUE]
list = lapply(X = repos, FUN = fix_url)
list = do.call(what = rbind, args = list)
#slow down the request for licensee
for (i in list) {
  helper(i)
}

#parse licensee result
per_licensee = standarlize_licensee()

#combine manual and licesee results
cdn_license_info = standarlize_overall(manual_license, per_licensee)

#reorder
names(cdn_license_info) <- c('name', 'author', 'license')

#detect osi status
cdn_license_info$osi <- lapply(cdn_license_info$license, osi_status)

cdn_license_info = cdn_license_info %>%
  mutate(osi = unlist(osi))



#upload result
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_license_info",
             value = cdn_license_info,
             row.names = FALSE,
             overwrite = TRUE)


on.exit(dbDisconnect(conn = xxx))
