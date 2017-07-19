library(readr)
library(plyr)
depsy_net_nodes <- read_csv("~/git/oss/src/gkorkmaz/depsy_dependency_network_nodes.csv")

agg_dat <- plyr::count(depsy_net_nodes, c('componentnumber'))
mean(agg_dat[-1,2])
