library(dplyr)
library(DiagrammeR)
library(plyr)

source("~/git/oss/src/ckelling/analysis/sourceforge/dan_functions.R")
load(file = '~/git/oss/data/oss/working/sourceforge/cleaned_SF.RData')
cleaned_SF <- as.data.frame(cleaned_SF)
agg_dat <- plyr::count(cleaned_SF, c('Category.1', 'Category.2', 'Category.3'))


#Full network
network_graph(agg_dat)

#Audio and Video Graph
av_counts = agg_dat[which(agg_dat$Category.1 == "Audio & Video"),]
network_graph(av_counts)#, title = "Category: Audio and Video")

#Business and Enterprise Graph
be_counts = agg_dat[which(agg_dat$Category.1 == "Business & Enterprise"),]
network_graph(be_counts)

#Communications Graph
comm_counts = agg_dat[which(agg_dat$Category.1 == "Communications"),]
network_graph(comm_counts)

#Development Graph
dev_counts = agg_dat[which(agg_dat$Category.1 == "Development"),]
network_graph(dev_counts)

#Games and Graphics Graph
#need to edit graphics a bit
for(i in 1:nrow(agg_dat)){
  if(agg_dat$Category.1[i]=="Graphics" & is.na(agg_dat$Category.1[i]) == FALSE){
    agg_dat$Category.2[i] <- agg_dat$Category.3[i]
    agg_dat$Category.3[i] <- NA
  }
}
gg_counts = agg_dat[which(agg_dat$Category.1 == "Graphics" | agg_dat$Category.1 == "Games"),]
network_graph(gg_counts)

#Home and Education and Other Graph
he_counts = agg_dat[which(agg_dat$Category.1 == "Home & Education" | agg_dat$Category.1 == "Multimedia" | agg_dat$Category.1 == "Other/Nonlisted Topic"),]
network_graph(he_counts)

#Science and Engineering
se_counts = agg_dat[which(agg_dat$Category.1 == "Science & Engineering"),]
network_graph(se_counts)

# Security and Utilities
su_counts = agg_dat[which(agg_dat$Category.1 == "Security & Utilities"),]
network_graph(su_counts)

#System Administration
sa_counts = agg_dat[which(agg_dat$Category.1 == "System Administration"),]
network_graph(sa_counts)

#NA
#na_counts = agg_dat[which(is.na(agg_dat$Category.1)),]
#network_graph(na_counts
na_val = print(agg_dat[which(is.na(agg_dat$Category.1)),][,4])
paste("Number of NA values: ", na_val, ", which is ", round(na_val/sum(agg_dat$freq),3)*100, "%.", sep="")
