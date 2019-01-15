# INPUT:
#        "~/oss/data/oss/working/pypi/10_github_api_info.csv"
#        "~/oss/data/oss/working/pypi/10_github_and_additional_info.csv"
# OUTPUT:
#        "~/oss/data/oss/final/PyPI/complete_osi_info.csv"

github_info <- read.csv("./data/oss/working/pypi/10_github_api_info.csv")
osi_production_mature <- read.csv("./data/oss/working/pypi/10_github_and_additional_info.csv")
osi_production_mature$num_contributors <- NA
osi_production_mature$lines_of_code <- NA

for (i in 1:nrow(osi_production_mature))
{
  if (is.na(osi_production_mature$slug[i]))
  {
    next
  }
  pkg_slug <- osi_production_mature$slugs[i]

  if (is.na(github_info$user[which(github_info$slug %in% pkg_slug)[1]]))
  {
    next
  }
  osi_production_mature$num_contributors[i] <- sum(github_info$slug %in% pkg_slug)

  if (osi_production_mature$num_contributors[i] != 0)
  {
    contr <- which(github_info$slug %in% pkg_slug)
    loc <- 0
    for (j in 1:length(contr))
    {
      loc <- loc + github_info$additions[contr[j]] + github_info$deletions[contr[j]]

    }
    osi_production_mature$lines_of_code[i] <- loc
  }
}

osi_production_mature$X.5 <- NULL
osi_production_mature$X.4 <- NULL
osi_production_mature$X.3 <- NULL
osi_production_mature$X.2 <- NULL
osi_production_mature$X.1 <- NULL
osi_production_mature$X <- NULL

write.csv(osi_production_mature, "~/oss/data/oss/final/PyPI/complete_osi_info.csv")
