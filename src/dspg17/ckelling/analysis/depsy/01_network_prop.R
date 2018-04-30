library(igraph)
library(dplyr)
library(network)
library(readr)
library(car)
library(MASS)
#library(ggnet2)

load(file = "~/git/oss/data/oss/working/depsy/neighb_mat.Rdata")
load(file = "~/git/oss/data/oss/working/depsy/node_mat.Rdata")

neighb_mat <- as.data.frame(neighb_mat)
neighb_mat$Source <- as.character(neighb_mat$Source)

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

save(neighb_mat, file = "~/git/oss/data/oss/working/depsy/updated_neighb_mat.Rdata")


# head(count)
# which(node_mat$name == "treescape")
# which(neighb_mat$Source == "stima")
# which(neighb_mat$Target == "stima")
# neighb_mat$Source[141]
# neighb_mat$Target[141]

net <- graph_from_data_frame(d=neighb_mat, vertices=node_mat, directed=T)
#plot(net)

#ggnet(net, mode = "fruchtermanreingold")

deg <- degree(net, mode="all")
deg <- as.data.frame(deg)
deg$name <- rownames(deg)
node_mat <- left_join(node_mat, deg, by = c(name = "name"))

hist(deg$deg[which(deg$deg < 40)], main="Histogram of node degree")
length(deg$deg[which(deg$deg > 100)])

indeg <- degree(net, mode="in")
indeg <- as.data.frame(indeg)
indeg$name <- rownames(indeg)
node_mat <- left_join(node_mat, indeg, by = c(name = "name"))

nrow(node_mat[which(node_mat$deg == 0),])
nrow(node_mat)- nrow(node_mat[which(node_mat$deg == 0),])

outdeg <- degree(net, mode="out")
outdeg <- as.data.frame(outdeg)
outdeg$name <- rownames(outdeg)
node_mat <- left_join(node_mat, outdeg, by = c(name = "name"))

deg.dist <- degree_distribution(net, cumulative=T, mode="all")

plot( x=0:max(deg$deg), y=1-deg.dist, pch=19, cex=1.2, col="orange",
      xlab="Degree", ylab="Cumulative Frequency")

#this is not working - this is returning the same value as total degree
#Compute eigenvector centrality scores
centr_deg <- centr_eigen(net, directed = TRUE)
centr_deg <- as.data.frame(centr_deg)$vector
centr_deg <- centr_degree(net, mode="total", normalized=F)
centr_deg <- as.data.frame(centr_deg$res)
#centr_deg$name <- rownames(centr_deg)
node_mat <- cbind(node_mat, centr_deg)
#which(node_mat$`centr_deg$res` != node_mat$deg)

closeness <- closeness(net, mode="all", weights=NA)
closeness <- as.data.frame(closeness)
closeness$name <- rownames(closeness)
node_mat <- left_join(node_mat, closeness, by = c(name = "name"))

cent_close <- centr_clo(net, mode="all", normalized=T)
cent_close <- cent_close$res
cent_close <- as.data.frame(cent_close)
node_mat <- cbind(node_mat, cent_close)

#test <- betweenness(net, directed=T, weights=NA)
# edge_betweenness(net, directed=T, weights=NA)
# centr_betw(net, directed=T, normalized=T)
# mean_distance(net, directed=T)

#community detection
#ceb <- cluster_edge_betweenness(net)  #based on edge betweenness (Newman-Girvan)
#plot(ceb, net, vertex.label=NA)
#save(ceb, file= "~/git/oss/data/oss/working/depsy/ceb.Rdata")

node_mat$num_commits <- as.numeric(node_mat$num_commits)
node_mat$num_stars <- as.numeric(node_mat$num_stars)
node_mat$num_committers <- as.numeric(node_mat$num_committers)
node_mat$num_authors <- as.numeric(node_mat$num_authors)
node_mat$num_citations <- as.numeric(node_mat$num_citations)
node_mat$num_downloads <- as.numeric(node_mat$num_downloads)
fit1 <- lm(num_downloads ~ cent_close+closeness+indeg+outdeg+num_citations+num_commits+num_authors+num_stars+num_committers, data = node_mat)
summary(fit1)

#fit1$coefficients
res=fit1$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit1$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit1)
bc=boxcox(fit1)
bc$x[which.max(bc$y)]

#removing variables
fit2 <- lm(num_downloads ~ cent_close+indeg+outdeg+num_commits+num_authors+num_stars+num_committers, data = node_mat)
summary(fit2)

#fit1$coefficients
res=fit2$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit2$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit2)
bc=boxcox(fit2)
bc$x[which.max(bc$y)]

#trying a negative binomial regression
fit3 <- glm.nb(num_downloads ~ cent_close+indeg+outdeg+num_commits+num_authors+num_stars+num_committers, data = node_mat)
#doesn't converge?
summary(fit3)

#removing authors
fit4 <- glm.nb(num_downloads ~ cent_close+indeg+outdeg+num_commits+num_stars+num_committers, data = node_mat)
#doesn't converge?
summary(fit4)

res=fit4$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit4$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit4)
bc=boxcox(fit4)
bc$x[which.max(bc$y)]

#transformation of response
fit5 <- glm.nb(I(round(num_downloads^(0.5))) ~ cent_close+indeg+outdeg+num_commits+num_stars+num_committers, data = node_mat)
#doesn't converge?
summary(fit5)
res=fit5$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit5$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit5)
bc=boxcox(fit5)
bc$x[which.max(bc$y)]


#now, I will try the 0-inflated model for num.downloads
nrow(node_mat[which(node_mat$num_downloads<100),])
nrow(node_mat[which(node_mat$num_downloads>1000000),])
boxplot(node_mat$num_downloads)
hist(node_mat[which(node_mat$num_downloads<7000),18])

#trying to subset data without extreme values
large_val <- node_mat[which(node_mat$num_downloads>1000000),]
large_val <- large_val[order(-large_val$num_downloads),]
new_dat <- node_mat[which(node_mat$num_downloads<1000000),]
boxplot(new_dat$num_downloads)

#trying again with subsetted data
fit1 <- lm(num_downloads ~ cent_close+closeness+indeg+outdeg+num_citations+num_commits+num_authors+num_stars+num_committers, data = new_dat)
summary(fit1)

#fit1$coefficients
res=fit1$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit1$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit1)
bc=boxcox(fit1)
bc$x[which.max(bc$y)]


fit2 <- lm(num_downloads ~ cent_close+closeness+indeg+outdeg+num_commits+num_authors+num_stars+num_committers, data = new_dat)
summary(fit2)

#fit1$coefficients
res=fit2$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit2$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit1)
bc=boxcox(fit1)
bc$x[which.max(bc$y)]

fit3 <- lm(num_downloads ~ cent_close+closeness+outdeg+num_commits+num_stars+num_committers, data = new_dat)
#fit1$coefficients
res=fit3$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit3$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit1)
bc=boxcox(fit1)
bc$x[which.max(bc$y)]

fit4 <- lm(I(num_downloads^(-1/3)) ~ cent_close+outdeg+num_commits+num_stars+num_committers, data = new_dat)
summary(fit4)
#fit1$coefficients
res=fit4$resid
hist(res,breaks=15)
qqnorm(res)
abline(0,0.01)
qqline(res)
yhat=fit4$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit1)
bc=boxcox(fit1)
bc$x[which.max(bc$y)]


#trying a negative binomial model, just for kicks
fit5 <- glm.nb(num_downloads ~ cent_close+outdeg+num_commits+num_stars+num_committers, data = new_dat)
#doesn't converge?
summary(fit5)

res=fit5$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit5$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit1)
boxcox(fit4)
bc=boxcox(fit4)
bc$x[which.max(bc$y)]

length(which(node_mat$deg==0))
