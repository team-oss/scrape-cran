#Source Forge Analysis
library(ggplot2)
df1=orig_data
ggplot(df1, aes(Category))+ geom_bar()

#there are  1250 observations per category and 10 categories, maknig 12,500 observations total
length(which(df1$Category== "Games"))
length(which(df1$Category== "Audio and Video"))

