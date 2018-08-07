# INPUT:
#        "~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv"
#        "~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv"
# OUTPUT:
#        "~/oss/data/oss/working/pypi/03_prod_mature_names.csv"

prod_stable_names <- read.csv("~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv")
mature_names <- read.csv("~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv")

prod_stable_names <- temp1[2:10001,]

prod_stable_names$X <- NULL
mature_names$X <- NULL

all_prod_mature <- rbind(prod_stable_names, mature_names)

write.csv(all_prod_mature, "~/oss/data/oss/working/pypi/03_prod_mature_names.csv")
