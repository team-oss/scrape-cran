temp1 <- read.csv("~/oss/data/oss/final/PyPI/temp1_names.csv")
temp2 <- read.csv("~/oss/data/oss/final/PyPI/temp2_names.csv")

temp1 <- temp1[2:10001,]

temp1$X <- NULL
temp2$X <- NULL

all_prod_mature <- rbind(temp1, temp2)

write.csv(all_prod_mature, "~/oss/data/oss/final/PyPI/all_production_mature.csv")
