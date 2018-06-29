#HEXXXXX

library(dplyr)
library(ggplot2)
library(stringr)

R <- read.csv('./data/oss/working/Hex_data/R_properties.csv')
Julia <- read.csv('./data/oss/working/Hex_data/Julia_properties.csv')
CDN <- read.csv('./data/oss/working/Hex_data/CDN_properties.csv')
Python <- read.csv('./data/oss/working/Hex_data/Python_properties.csv')

Julia_c = Julia %>%
  filter(str_detect(string = Id, pattern = '\\.jl$')) %>%
  mutate(Id = str_remove(string = Id,
                         pattern = '\\.jl$')) %>%
  select(Id, cost)
Julia_o = Julia %>%
  filter(!str_detect(string = Id, pattern = '\\.jl$')) %>%
  select(Id, outdegree)
Julia_g = merge(x = Julia_c,
                y = Julia_o,
                all.x = TRUE,
                fill = 0)
Julia <- Julia_g

R<- select(R,cost,outdegree)
CDN<- select(CDN,cost,outdegree)
Julia<- select(Julia,cost,outdegree)
Python<- select(Python,cost,outdegree)



R$Source <- rep("R",nrow(R))
Julia$Source <- rep("Julia",nrow(Julia))
CDN$Source <- rep("CDN",nrow(CDN))
Python$Source <- rep("Python",nrow(Python))


compare <- rbind(R,Python,CDN,Julia)
compare2 <- compare[complete.cases(compare),]


#plots?
ggplot(data=compare,mapping=aes(x=cost,y=outdegree)) + geom_hex(bins = 70) + theme_minimal()


x <- ggplot(data=compare,mapping=aes(x=outdegree,y=cost, fill =Source)) + geom_hex(bins = 70) + theme_minimal() + theme(panel.grid.major.x = element_blank(),
                                                                                                              panel.grid.minor.x = element_blank(),
                                                                                                              panel.grid.major.y = element_blank(),
                                                                                                              panel.grid.minor.y = element_blank()) +
  scale_y_log10() +
  scale_x_log10()
x

#filter zeros
compare <- filter(compare, outdegree != 0 )
x <- ggplot(data=compare,mapping=aes(x=cost,y=outdegree)) + geom_hex(bins = 70) + theme_minimal() + theme(panel.grid.major.x = element_blank(),
                                                                                                          panel.grid.minor.x = element_blank(),
                                                                                                          panel.grid.major.y = element_blank(),
                                                                                                          panel.grid.minor.y = element_blank()) +

  scale_x_log10()
x

x <- ggplot(data=compare2,mapping=aes(x=outdegree/cost)) + geom_density()+scale_y_log10() +
  scale_x_log10()
x

#boxplot
x <- ggplot(data=compare,mapping=aes(x=outdegree,y=cost, group=Source,fill=Source)) + geom_boxplot()+scale_y_log10() +
  scale_x_log10()
x
