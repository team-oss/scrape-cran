# INPUT:
#        "~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv"
#        "~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv"
# OUTPUT:
#        "~/oss/data/oss/working/pypi/03_prod_mature_names.csv"

prod_stable_names <- read.csv("~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv")
mature_names <- read.csv("~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv")

pre_len <- nrow(prod_stable_names)

prod_stable_names<- prod_stable_names[complete.cases(prod_stable_names), ]

post_len <- nrow(prod_stable_names)
stopifnot(pre_len - post_len == 1) # only 1 row (the first should've been dropped)

prod_stable_names$X <- NULL
mature_names$X <- NULL

all_prod_mature <- rbind(prod_stable_names, mature_names)

write.csv(all_prod_mature, "~/oss/data/oss/working/pypi/03_prod_mature_names.csv")
