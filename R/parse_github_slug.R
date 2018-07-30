#' takes in a github url, returns the org/repo slug
#' @examples
#' parse_github_slug('github.com/bi-sdal/sdalr')
parse_github_slug <- function(github_url) {
  if (is.na(github_url)) {
    return(NA)
  } else if (stringr::str_detect(github_url, 'github.com')) {
    # regex for another time, let's not throw the kitchen sink when we don't have to
    # stringr::str_extract(github_url, '(?<=github\\.com/)(.*?/.*?/?)')
    after_github <- stringr::str_split_fixed(github_url, 'github.com(/|:)', 2)[, 2]
    slug_components <- stringr::str_split_fixed(after_github, '/', 3)[, c(1, 2)]
    collapsed <- paste(slug_components, collapse = '/')

    final_slug <- stringr::str_replace(collapsed, '\\.git', '')
    return(final_slug)
  } else {
    return(NA)
  }
}

testthat::expect_equal(parse_github_slug('github.com/bi-sdal/sdalr'), 'bi-sdal/sdalr')
testthat::expect_true(is.na(parse_github_slug('yahoo.com')))
testthat::expect_true(is.na(parse_github_slug(NA)))
testthat::expect_equal(parse_github_slug('https://github.com/usnationalarchives/AVI-MetaEdit/tree/master/Release'),
                       'usnationalarchives/AVI-MetaEdit')
testthat::expect_equal(parse_github_slug('https://github.com/usgin/ContentModelCMS'), 'usgin/ContentModelCMS')
testthat::expect_equal(parse_github_slug('https://github.com/bi-sdal/sdalr.git'), 'bi-sdal/sdalr')
testthat::expect_equal(parse_github_slug('git@github.com:bi-sdal/sdalr.git'), 'bi-sdal/sdalr')
