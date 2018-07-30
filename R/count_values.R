# counts the number of non missing values in a 'row' (i.e., vector)
count_values <- function(row_dat) {
  nas <- purrr::map_lgl(row_dat, is.na)

  # flipping the sign
  return(sum(!nas, na.rm = TRUE))
}
