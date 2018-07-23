library(stringr)
library(dplyr)
library(rvest)
library(jsonlite)
library(data.table)
general_info <- read.csv("data/oss/final/CDN/general_info.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)

general_info$github <- str_detect(general_info$repository.url, "github")
###########################################################################
fix_url = function(repo) {
  fixed = str_replace(repo, "^.*(?<=github.com.)", "https://github.com/") %>%
    str_remove("(/|\\.git)$")
  return(fixed)
}
#str(general_info)
check_lang = function(github, repo) {
  if (!is.na(github) & github) {
    response = str_c('https://api.github.com/',
                     'repos',
                     '/',
                     str_extract(string = repo,
                                 pattern = '(?<=github\\.com(/|:)).*') %>%
                       str_remove("(/|\\.git)$"),
                     '/',
                     'languages') %>%
      GET(add_headers(Authorization = 'token 2d260070668afe675673e973faf2ec30b48e831c'))
    Sys.sleep(time = 5e-1)

    if (status_code(response) == 200) {
      output = response %>%
        content(as = 'text', encoding = 'UTF-8') %>%
        fromJSON()

      return(unlist(output))
    }
  }
  return(as.integer(0))
}
lang_percentage = function(langs) {
  total = sum(langs)
  if (total != 0L) {
    each = as.integer(round(langs/total * 100, 0))
    return(data.frame(language = names(langs), percentage = each))
  } else {
    return(data.frame())
  }
}
prob_lang = function (name) {
  percentage = lang_df$percentage[lang_df$name == name][1]
  if (!is.na(percentage) & percentage >= 50) {
    return(lang_df$language[lang_df$name == name][1])
  }
  return("Other")
}
confirm_lang = function(row) {
  if (str_detect(row[1], regex("javascript", TRUE)) |
      str_detect(row[1], regex("js", TRUE)) |
      str_detect(row[1], regex("angular", TRUE))) {
    return("JavaScript")
  } else if (str_detect(row[1], regex("css", TRUE))) {
    return("CSS")
  } else if (str_detect(row[1], regex("html", TRUE))) {
    return("HTML")
  }

  if (str_detect(row[2], regex("javascript", TRUE)) |
      str_detect(row[2], regex("js", TRUE))) {
    return("JavaScript")
  }  else if (str_detect(row[2], regex("css", TRUE))) {
    return("CSS")
  }  else if (str_detect(row[2], regex("html", TRUE))) {
    return("html")
  }

    return(row[3])
}
###########################################################################
general_info$repo <- lapply(general_info$repository.url, fix_url) %>% unlist()
#manually fix a case where reop is switched to github
general_info$repo[776] = "https://github.com/datejs/Datejs"
general_info$github[776] = TRUE
general_info$repo[2418] = "https://github.com/ternarylabs/porthole"
general_info$github[2418] = TRUE
general_info$repo[1599] = "https://github.com/juven14/Collapsible"
general_info$github[1599] = TRUE
general_info$repo[803] = "https://github.com/google/diff-match-patch"
general_info$github[803] = TRUE
general_info$repo[1563] = "https://github.com/crfroehlich/jquery-ui-map"
general_info$github[1563] = TRUE
general_info$repo[2269] = "https://github.com/wikimedia/oojs-ui"
general_info$github[2269] = TRUE
general_info$repo[2270] = "https://github.com/wikimedia/oojs"
general_info$github[2270] = TRUE
general_info$repo[3073] = "https://gitlab.com/epistemex/transformation-matrix-js"


# repos = general_info$repo[general_info$github %in% TRUE]
# repos = repos[1:10]
lang_results = list()
for(i in 1:length(general_info$repo)) {
  components = check_lang(general_info$github[], general_info$repo[i]) %>% lang_percentage()
  if (is_empty(components)) {
    components = data.frame(name = general_info$name[i], language = NA, percentage = NA)
  } else {
    components = data.frame(name = general_info$name[i], language = components$language, percentage = components$percentage)
  }
  lang_results[[i]] <- components

  print(i)
}

lang_df = do.call(what = rbind, args = lang_results)
write.csv(lang_df, file = "data/oss/working/CDN/pkg_langs.csv", row.names=FALSE)
write.csv(lang_df, file = "data/oss/final/CDN/general_info.csv", row.names=FALSE)

# if only the language with most percentage is needed, lang_df is not useful; do all the operation with lang_results
dominant_pkg_lang = lapply(general_info$name, prob_lang)
dominant_pkg_lang = do.call(what = rbind, args = dominant_pkg_lang)
temp = data.frame(name = general_info$name, description = general_info$description, percentage_lang = dominant_pkg_lang,
                  stringsAsFactors = FALSE)
temp1 = lapply(temp, confirm_lang)

general_info$slugs = str_extract(general_info$repo, "(?<=github\\.com(/|:)).*")
general_info$language = temp1$selected_language

write.csv(temp1, file = "data/oss/working/CDN/pkg_langs_finalized.csv", row.names=FALSE)
write.csv(general_info, file = "data/oss/final/CDN/general_info.csv", row.names=FALSE)

library(DBI)
library(sdalr)
my_db_con <- con_db("oss", pass=sdalr::get_my_password())
dbWriteTable(con = my_db_con,
             name = "cdn_general_info",
             value = general_info[c("name", "slugs", "language", "description", "github", "repo")],
             row.names = FALSE,
             overwrite = TRUE)
##############################
lang_df <- read.csv("data/oss/working/CDN/pkg_langs.csv",
                         stringsAsFactors = FALSE, check.names=FALSE)
