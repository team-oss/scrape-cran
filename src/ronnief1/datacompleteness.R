#data completeness for depsy matrices
library(gridExtra)
library(dplyr)
library(ggplot2)
profile_dat <- c()
#iterates through contributor matrix and makes new row for each var describing completeness
for(i in 1:ncol(fullcontrib_mat)){
  print(i)
   x <- fullcontrib_mat[,i]

    # Make all blanks NAs
    x[x == ""] <- NA

    name <- colnames(fullcontrib_mat)[i]
    class <- class(x)

    # Proportion of missing values
    miss <- round(sum(is.na(x))*100/nrow(fullcontrib_mat), digits = 2)

    # How many unique values to the variable?
    vals <- length(unique(x))
    summary <- summary(x)
    # if(vals <= 10){
    #   tab <- table(x)
    #   print(tab)
    # }
  new_row <- c(name, class, miss, vals)
  profile_dat <- rbind(profile_dat, new_row)
}

grid.table(profile_dat)
grid.table(profile_dat2)
profile_dat2 <- c()
#same as for loop above but with node matrix
for(i in 1:ncol(node_mat)){
  print(i)
  x <- node_mat[,i]

  # Make all blanks NAs
  x[x == ""] <- NA

  name <- colnames(node_mat)[i]
  class <- class(x)

  # Proportion of missing values
  miss <- round(sum(is.na(x))*100/nrow(node_mat), digits = 2)

  # How many unique values to the variable?
  vals <- length(unique(x))
  summary <- summary(x)
  # if(vals <= 10){
  #   tab <- table(x)
  #   print(tab)
  # }
  new_row <- c(name, class, miss, vals)
  profile_dat2 <- rbind(profile_dat2, new_row)
}
#lots of histograms and finding unique values for each var
hist(as.numeric(df$impact), main = "Impact Histogram", xlab = "Impact Scores")
hist(as.numeric(df$impact_perc), main = "Impact Percentile Histogram", xlab = "Impact Percentile")
length(unique(df$is_org))
length(unique(df$gitlogin))
length(unique(df$main_lang))
length(unique(df$person_name))
hist(as.numeric(df$person_package_cred), main = "Person Package Credential Histogram", xlab = "Person Package Credential")
length(unique(df$roles))
length(unique(neighb_mat$Source))
length(unique(neighb_mat$Target))
length(neighb_mat$Target)
a <- as.data.frame(tag_mat)
length(unique(a$name))
length(node_mat$citations_pmc == 0)
length(unique(a$tags))
hist(main = "Neighborhood Size Histogram", xlab = "Neighborhood size",as.numeric(node_mat$neighborhood_size[which(as.numeric(node_mat$neighborhood_size) >5 & as.numeric(node_mat$neighborhood_size) < 20)]))
hist(as.numeric(node_mat$citations_pmc[which(as.numeric(node_mat$citations_pmc) < 10)]), main = "PMC Citations", xlab = "PMC Citations Count")
hist(as.numeric(node_mat$citations_harv))
head(distinct(node_mat, git_owner))  #testing out distinct function from dplyr on git_owner variable
t <- as.data.frame(tag_mat) #tag_mat needs to be data frame
length(unique(node_mat$git_owner))
length(unique(node_mat$git_repo_name))
length(unique(node_mat$host))
hist(as.numeric(node_mat$impact), main = "Impact Count", xlab = "Impact")
hist(as.numeric(node_mat$impact_percentile), main = "Impact Percentile Count", xlab = "Impact Percentile")
hist(as.numeric(node_mat$indegree[which(as.numeric(node_mat$indegree) < 9)]), main = "Indegree Count", xlab = "Indegree")
hist(as.numeric(node_mat$num_authors[which(as.numeric(node_mat$num_authors) < 10)]), main = "Number of Authors Count", xlab = "Number of Authors")
hist(as.numeric(node_mat$num_commits[which(as.numeric(node_mat$num_commits) < 800)]), main = "Number of Commits Histogram", xlab = "Number of Commits")
hist(as.numeric(node_mat$num_committers[which(as.numeric(node_mat$num_committers) < 15)]), main = "Number of Committers Histogram", xlab = "Number of Committers")
hist(as.numeric(node_mat$num_contribs[which(as.numeric(node_mat$num_contribs) < 20)]), main = "Number of Contributors Histogram", xlab = "Number of Contributors")
hist(as.numeric(node_mat$num_stars[which(as.numeric(node_mat$num_stars) < 10)]), main = "Number of Stars Histogram", xlab = "Number of Stars")
hist(as.numeric(node_mat$num_downloads[which(as.numeric(node_mat$num_downloads) < 85000)]), main = "Number of Downloads Histogram", xlab = "Number of Downloads")
hist(as.numeric(node_mat$perc_downloads), main = "Percent Downloads Histogram", xlab = "Percent Downloads")
hist(as.numeric(node_mat$num_citations[which(as.numeric(node_mat$num_citations) < 15)]), main = "Number of Citations Histogram", xlab = "Number of Citations")
hist(as.numeric(node_mat$perc_citations), main = "Percent Cited Histogram", xlab = "Percent Cited")
hist(as.numeric(node_mat$num_deprank))
hist(as.numeric(node_mat$num_deprank[which(as.numeric(node_mat$num_deprank) > 0)]), main = "Depsy Rank Histogram", xlab = "Depsy Rank")
hist(as.numeric(node_mat$perc_deprank), main = "Percent Depsy Rank Histogram", xlab = "Percent Depsy Rank")
length(unique(node_mat$is_academic))
length(unique(df$contrib))
hist(as.numeric(df$perc_cit[which(as.numeric(df$perc_cit) > 50)]), main = "Percent Citations Histogram", xlab = "Percent Citations")
plyr::count(df, c('perc_cit'))
role <- plyr::count(df, c('roles'))
hist(as.numeric(df$num_downloads), main = "Number of Downloads Histogram", xlab = "Number of Downloads")
test <- plyr::count(t, c('name'))
sum(test$freq)/nrow(test)
hist(test$freq, main = "Number of Tags per Package", xlab = "Tags per Package")
ggplot(data=test, aes(test$freq), binwidth = 10) + geom_histogram()
qplot(test$freq,
      geom="histogram",
      binwidth = 1,
      main = "Number of Tags Per Package",
      xlab = "Tags Per Package",
      fill = 'red') +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")

test2 <- plyr::count(t, c('tags'))
sum(test2$freq)/nrow(test2)
hist(test2$freq, main = "Number of Packages per Tag", xlab = "Packages per Tag")
qplot(test2$freq,
      geom="histogram",
      binwidth = 30,
      main = "Number of Packages Per Tag",
      xlab = "Packages Per Tag",
      fill = 'red') +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")
qplot(as.numeric(node_mat$num_commits[which(as.numeric(node_mat$num_commits) < 800)]),
      geom="histogram",
      bins = 50,
      main = "Number of Commits Histogram",
      xlab = "Number of Commits",
      fill = 'red') +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")
qplot(as.numeric(node_mat$num_committers[which(as.numeric(node_mat$num_committers) < 15)]),
      geom="histogram",
      bins = 8,
      main = "Number of Committers Histogram",
      xlab = "Number of Committers",
      fill=I("darkblue"),
      col=I("darkblue")) +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")
qplot(as.numeric(node_mat$num_downloads[which(as.numeric(node_mat$num_downloads) < 57000)]),
      geom="histogram",
      bins = 80,
      main = "Number of Downloads Histogram",
      xlab = "Number of Downloads",
      fill=I("darkgreen"),
      col=I("darkgreen")) +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")
qplot(as.numeric(node_mat$num_stars[which(as.numeric(node_mat$num_stars) < 80)]),
      geom="histogram",
      bins = 80,
      main = "Number of Stars Histogram",
      xlab = "Number of Stars",
      fill=I("darkgreen"),
      col=I("darkgreen")) +  theme(plot.title = element_text(size=22), axis.title.x = element_text(size=18), axis.title.y = element_text(size=18), legend.position = "none")
new <- test2[order(-test2$freq),]
mydf <- transform(new, variables = reorder(new$tags, -new$freq))
sum(as.numeric(node_mat$num_stars[which(as.numeric(node_mat$num_stars) < 80)]))

ggplot(new) +
  geom_bar(aes(x=reorder(tags, -freq), y = freq, fill = "F8766D"), stat = "identity") +
  theme(legend.position = "none", plot.title = element_text(size=20),
  axis.text.x = element_text(angle=90, hjust=1, size = 15),
  axis.title.x = element_text(size =18), axis.title.y = element_text(size=18))  +
  xlab("Tags") + ggtitle("Tags by Frequency")
  scale_y_continuous(name = "Count", limits = c(0,300), breaks = seq(0,300, 25))
sum(is.na(t$tags))
t <- as.data.frame(tag_mat)
length(unique(a$name))
df <- as.data.frame(fullcontrib_mat)
length(unique(df$oss_name))
hist(as.numeric(df$perc_downloads), main = "Percent Downloads Histogram", xlab = "Percent Downloads")
hist(as.numeric(df$num_deppagerank[which(as.numeric(df$num_deppagerank) > 50)]), main = "Depsy Page Rank Histogram", xlab = "Depsy Page Rank")
hist(as.numeric(df$perc_deppagerank[which(as.numeric(df$perc_deppagerank) > 50)]), main = "Percentile Depsy Page Rank Histogram", xlab = "Percentile Depsy Page Rank")
hist(as.numeric(df$num_cit[which(as.numeric(df$num_cit) > 35)]), main = "Number of Citations Histogram", xlab = "Number of Citations")
plyr::count(df, c('num_cit'))
length(unique(n))
n <- node_mat$Id
n

s <- plyr::count(node_mat, c('Id'))
unique(s)
dfprof1 <- as.data.frame(profile_dat)
colnames(dfprof3) <- c('Variable Name', 'Class', 'Percent Missing', 'Missing Entries')
grid.table(dfprof1)
dfprof1 <- subset(dfprof1, select = c('Variable Name', 'Percent Missing', 'Missing Entries'))
dfprof2 <- as.data.frame(profile_dat2)
colnames(dfprof2) <- c('Variable Name', 'Class', 'Percent Missing', 'Missing Entries')
dfprof2 <- subset(dfprof2, select = c('Variable Name', 'Percent Missing', 'Missing Entries'))
grid.table(dfprof2)
ddnn <- depsy_dependency_network_nodes
profile_dat3 <- c()
for(i in 1:ncol(dnn)){
  print(i)
  x <- dnn[,i]

  # Make all blanks NAs
  x[x == ""] <- NA

  name <- colnames(dnn)[i]
  class <- class(x)

  # Proportion of missing values
  miss <- round(sum(is.na(x))*100/nrow(dnn), digits = 2)

  # How many unique values to the variable?
  vals <- length(unique(x))
  summary <- summary(x)
  # if(vals <= 10){
  #   tab <- table(x)
  #   print(tab)
  # }
  new_row <- c(name, class, miss, vals)
  profile_dat3 <- rbind(profile_dat3, new_row)
}
dnn <- as.data.frame(ddnn)
dfprof3 <- as.data.frame(profile_dat3)
colnames(dfprof3) <- c('Variable Name', 'Class', 'Percent Missing', 'Missing Entries')
grid.table(dfprof3)
dfprof3 <- subset(dfprof3, select = c('Variable Name', 'Percent Missing', 'Missing Entries'))
grid.table(dfprof3)
length(unique(dnn$id))
sum(is.na(dnn$label))
sum(is.na(dnn$timeset))
sum(is.na(dnn$indegree))
hist(as.numeric(dnn$indegree), main = "In Degree Histogram", xlab = "In Degree")
sum(is.na(dnn$outdegree))
hist(as.numeric(dnn$outdegree[which(as.numeric(dnn$outdegree) < 5)]), main = "Out Degree Histogram", xlab = "Out Degree")
hist(as.numeric(dnn$degree[which(as.numeric(dnn$degree) < 20)]),  main = "Degree Histogram", xlab = "Degree")
hist(as.numeric(dnn$eccentricity), main = "Eccentricity Histogram", xlab = "Eccentricity")
hist(as.numeric(dnn$closnesscentrality), main = "Closeness Centrality Histogram", xlab = "Closeness Centrality")
hist(as.numeric(dnn$harmonicclosnesscentrality), main = "Harmonic Closeness Centrality Histogram", xlab = "Harmonic Closeness Centrality")
hist(as.numeric(dnn$betweenesscentrality[which(as.numeric(dnn$betweenesscentrality) < 5)]), main = "Betweeness Centrality Histogram", xlab = "Betweeness Centrality")
hist(as.numeric(dnn$authority[which(as.numeric(dnn$authority) < .06)]), main = "Authority Histogram", xlab = "Authority")
hist(as.numeric(dnn$hub[which(as.numeric(dnn$hub) < .008)]), main = "Hub Histogram", xlab = "Hub")
hist(as.numeric(dnn$modularity_class), main = "Modularity Class Histogram", xlab = "Modularity Class")
hist(as.numeric(dnn$pageranks[which(as.numeric(dnn$pageranks) < .0003)]), main = "Pagerank Histogram", xlab = "Pageranks")
hist(as.numeric(dnn$componentnumber[which(as.numeric(dnn$componentnumber) <  2)]))
sum(dnn$componentnumber == 0)
hist(as.numeric(dnn$strongcompnum), main = "Strong Component Number Histogram", xlab = "Strong Component Number")
hist(as.numeric(dnn$clustering[which(as.numeric(dnn$clustering) < .4)]), main = "Clustering Histogram", xlab = "Clustering")
hist(as.numeric(dnn$eigencentrality), main = "Eigencentrality Histogram", xlab = "Eigencentrality")
max(node_mat$num_downloads)
min(node_mat$num_downloads)
max <- 0
for(i in 1:length(node_mat$num_downloads)){
  if(as.numeric(node_mat$num_downloads[i]) > max){
    max <- as.numeric(node_mat$num_downloads[i])
  }
}
max(node_mat$num_citations)
