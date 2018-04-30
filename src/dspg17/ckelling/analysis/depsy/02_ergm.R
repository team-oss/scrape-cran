library(igraph)
library(dplyr)
library(network)
library(readr)
library(car)
library(MASS)
library(ergm)
library(latticeExtra)
library(intergraph)
#library(ggnet2)

load(file = "~/git/oss/data/oss/working/depsy/neighb_mat.Rdata")
load(file = "~/git/oss/data/oss/working/depsy/node_mat.Rdata")
load(file = "~/git/oss/data/oss/original/depsy/tag_mat.Rdata")
tag_mat <- as.data.frame(tag_mat)
neighb_mat <- as.data.frame(neighb_mat)
neighb_mat$Source <- as.character(neighb_mat$Source)
node_mat$num_commits <- as.numeric(node_mat$num_commits)
node_mat$num_stars <- as.numeric(node_mat$num_stars)
node_mat$num_committers <- as.numeric(node_mat$num_committers)
node_mat$num_authors <- as.numeric(node_mat$num_authors)
node_mat$num_citations <- as.numeric(node_mat$num_citations)
node_mat$num_contribs <- as.numeric(node_mat$num_contribs)
node_mat$num_downloads <- as.numeric(node_mat$num_downloads)

#subset- only take first tag row
tag_mat_subset <- tag_mat[!duplicated(tag_mat$name),]

node_mat <- full_join(node_mat, tag_mat_subset, by=c(name = "name"))

count <- c()
for(i in 1:nrow(neighb_mat)){
  if(!(neighb_mat$Source[i] %in% node_mat$name & neighb_mat$Target[i] %in% node_mat$name)){
    count <- rbind(count, paste(i))
  }
}
count <- as.vector(count[,1])

#take out the nodes that are in the edge matrix but not the node_matrix
#these are packages that are not in CRAN repository or are very new
neighb_mat <- neighb_mat[-as.numeric(count),]


node_mat_new <- node_mat
for(i in c(13:18,20)){
    node_mat_new[which(is.na(node_mat_new[,i])),i] <- 0
}

# head(count)
# which(node_mat$name == "treescape")
# which(neighb_mat$Source == "stima")
# which(neighb_mat$Target == "stima")
# neighb_mat$Source[141]
# neighb_mat$Target[141]

net <- graph_from_data_frame(d=neighb_mat, vertices=node_mat_new, directed=T)
class(net)
#igraph to network
depsy.net <- asNetwork(net)
class(depsy.net)


## Started as such model building process from here
## Optional: estimate = "MPLE"
## Also optional: propoposaltype = "tnt"
## And also optional: reference = ""
# Third model: just gender and attractiveness rating related parameters
# http://svitsrv25.epfl.ch/R-doc/library/ergm/html/ergm-terms.html


model.01 <- ergm(depsy.net ~ edges + nodematch("tags") +
                   nodeicov("num_citations") + nodeocov("num_citations")+
                   nodeicov("num_contribs") + nodeocov("num_contribs") +
                   nodeicov("num_commits") + nodeocov("num_commits")+
                   absdiff("num_citations") + absdiff("num_contribs") + absdiff("num_commits")+absdiff("num_downloads")+
                   gwesp(0.5, fixed = T),
                 maxNumDyads = network.size(depsy.net),
                 control=control.ergm(MCMC.burnin=500, MCMC.interval=1000,
                                      MCMC.samplesize=500000), verbose = T)
#nodematch- if they share this characteristic, how increase likelihood of having edge?
#nodemix- same but every possible combination
#nodeicov and nodeocov- continuous variables (incoming and outgoing)
#edgecov- continuous covariate for the edge
#absdiff- how the absolute difference affects likelihood of edge
#gwesp- maybe not important?
#maxNumDyads - network size? not specified
#control - MCMC specifications, verbose true throws out what is happening behind the code


# Model summary
summary(model.03)

# Checking goodness of fit
model.03.gof <- gof(model.03)
par(mfrow=c(2,2))
plot(model.03.gof)

# Checking MCMC diagnostics
par(mfrow=c(5,2))
mcmc.diagnostics(model.03)

abc <- simulate(model.03)
