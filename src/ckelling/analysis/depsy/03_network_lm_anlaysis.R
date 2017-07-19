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


fit1 <- lm(num_downloads ~ ., data = full_data)
summary(fit1)
full_data <- full_data[,-c(22, 19, 16, 15, 12, 8, 3, 1)]
fit2 <- lm(num_downloads ~ ., data = full_data)
summary(fit2)

full_data <- full_data[,-c(7,12)]
fit3 <- lm(num_downloads ~ ., data = full_data)
summary(fit3)

full_data <- full_data[,-c(7,9)]
fit4 <- lm(num_downloads ~ ., data = full_data)
summary(fit4)

res=fit4$resid
hist(res,breaks=15)
qqnorm(res)
qqline(res)
yhat=fit4$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit4)
boxcox(fit4)
bc=boxcox(fit4)
bc$x[which.max(bc$y)]

hist(full_data$num_stars[which(full_data$num_stars < 100)])


fit5 <- lm(I(num_downloads^(-0.25)) ~ ., data = full_data)
summary(fit5)
AIC(fit5)

full_data <- full_data[,-c(5,7)]

fit6 <- lm(I(num_downloads^(-0.25)) ~ ., data = full_data)
summary(fit6)

res=fit6$resid
hist(res,breaks=15)
qqnorm(res)
#qqline(res)
abline(0,0.015)
yhat=fit6$fitted.values
plot(yhat,res)
abline(h=0, col='red')
#crPlots(fit1)
AIC(fit6)
boxcox(fit6)
bc=boxcox(fit6)
bc$x[which.max(bc$y)]
