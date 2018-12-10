#comparisons between the Lines of code on github and the lines of code directly from cran
library(dplyr)
library(ggplot2)
library(stringr)
cran_full <- readRDS('./data/oss/working/CRAN_2018/Cran_Direct_download_costs.RDS')
write.csv(cran_full,'./data/oss/working/CRAN_2018/tempcsv/cran_direct_download.csv',row.names = F)
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS')
github <- readRDS('./data/oss/working/CRAN_2018/quick_fix_analysis_table.RDS')
colnames(cran_full)[1] <- 'name'
github <- full_join(github,keys,by='slug')


compare <- left_join(github,cran_full, by= 'name')
compare <- select(compare, name,slug,kloc.x,kloc.y,cost.x,cost.y,all_commits,all_contributors)
#looks like we get some missing here

#continue onwards with cleaning up the data frame
colnames(compare)<- c('name','slug','kloc_git','kloc_cran','cost_git','cost_cran','all_commits','all_contributors')
#length is 3454 right now
#exclude nas
compare <- compare[complete.cases(compare),]
#now we get 3317 ... hmmmm

#plots?
ggplot(compare,aes(x=name,y=(kloc_git-kloc_cran)))+geom_col()

comp <- ggplot(data=compare,mapping=aes(x=cost_git,y=cost_cran)) + geom_hex(bins = 70) + theme_minimal()
comp

ggplot(data=compare,mapping=aes(x=kloc_git,y=kloc_cran)) + geom_hex(bins = 70) + theme_minimal()
x <- ggplot(data=compare,mapping=aes(x=cost_git,y=cost_cran)) + geom_hex(bins = 70) + theme_minimal() + theme(panel.grid.major.x = element_blank(),
                                                                                                              panel.grid.minor.x = element_blank(),
                                                                                                              panel.grid.major.y = element_blank(),
                                                                                                              panel.grid.minor.y = element_blank()) +
  scale_y_log10() +
  scale_x_log10()
x
ggsave(x, filename = './output/cran/hex.png',units = 'in',width = 11,height=8)


p <- ggplot(mpg, aes(class, hwy))
p + geom_boxplot()
