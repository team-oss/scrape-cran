library(readr)
library(dplyr)
library(MASS)
depsy_net_nodes <- read_csv("~/git/oss/src/gkorkmaz/depsy_dependency_network_nodes.csv")
load(file = "~/git/oss/data/oss/working/depsy/updated_neighb_mat.Rdata")
load(file = "~/git/oss/data/oss/working/depsy/node_mat.Rdata")
node_mat$num_commits <- as.numeric(node_mat$num_commits)
node_mat$num_stars <- as.numeric(node_mat$num_stars)
node_mat$num_committers <- as.numeric(node_mat$num_committers)
node_mat$num_authors <- as.numeric(node_mat$num_authors)
node_mat$num_citations <- as.numeric(node_mat$num_citations)
node_mat$num_downloads <- as.numeric(node_mat$num_downloads)
node_mat$num_contribs <- as.numeric(node_mat$num_contribs)

#node_mat <- node_mat[-which(node_mat$deg == 0),]
full_data <- left_join(depsy_net_nodes[,c(1,4:18)], node_mat[,c(1,13:18,20)], by = c(id = "name"))
full_data <- full_data[,-1]

plot(full_data$num_citations, full_data$num_downloads)


fit1 <- lm(num_citations ~ ., data = full_data)
summary(fit1)

full_data <- full_data[,-c(1,3,11:16, 21, 19, 18)]
fit2 <- lm(num_citations ~ ., data = full_data)
summary(fit2)

full_data <- full_data[,-c(1,2,8)]
fit3 <- lm(I(num_citations^(9/10))~ ., data = full_data)
summary(fit3)


res=fit3$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit3$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit3)
boxcox(fit3)
bc=boxcox(fit3)
bc$x[which.max(bc$y)]
