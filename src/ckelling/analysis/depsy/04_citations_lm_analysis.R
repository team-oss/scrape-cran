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

full_data[is.na(full_data)] <- 0

mean(full_data$num_citations)
mean(full_data$num_downloads)
class(full_data)

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





fit1=glm(num_citations ~ ., data = full_data,family="poisson")
muhat=predict(fit1,type="response")
ysim=rpois(length(muhat),lambda=muhat)
## fit the simulated data
fit.sim=glm(ysim~.,family="poisson",data=full_data)
## residual plots
par(mfrow=c(2,4))
plot(fit1)
plot(fit.sim)






#try to with making NA's 0
fit1 <- lm(num_citations ~ ., data = full_data)
summary(fit1)

full_data <- full_data[,-c(3,11:15,9)]
fit2 <- lm(num_citations ~ ., data = full_data)
summary(fit2)

full_data <- full_data[,-c(1,11)]
fit3 <- lm(num_citations~ ., data = full_data)
summary(fit3)

full_data <- full_data[,-c(10)]
fit3 <- lm(num_citations~ ., data = full_data)
summary(fit3)

full_data <- full_data[,-c(10)]
fit3 <- lm(num_citations~ ., data = full_data)
summary(fit3)

full_data <- full_data[,-c(9)]
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



#try with glm
full_data <- left_join(depsy_net_nodes[,c(1,4:18)], node_mat[,c(1,13:18,20)], by = c(id = "name"))
full_data <- full_data[,-1]
full_data[is.na(full_data)] <- 0
full_data <- full_data[,-c(3)]

fit1=glm(num_citations ~ ., data = full_data,family="quasipoisson", control = list(maxit = 50))
summary(fit1)

fit1=glm.nb(num_citations ~ ., data = full_data)
summary(fit1)

rqpois <- function(n, mu, theta) {
  rnbinom(n = n, mu = mu, size = mu/(theta-1))
}

muhat=predict(fit1,type="response")
ysim=rpois(length(muhat),lambda=muhat)
deviance(fit1)
ysim <- rqpois(length(muhat), mu=muhat, theta=deviance(fit1))
## fit the simulated data
fit.sim=glm(ysim~.,family="quasipoisson",data=full_data)
## residual plots
par(mfrow=c(2,4))
plot(fit1)
plot(fit.sim)
