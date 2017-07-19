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
full_data <- full_data[,-c(3,6)]

full_data <- full_data[,-c(1)]
#outlier in terms of number of commits
full_data <- full_data[-1746,]
full_data <- full_data[,-c(5,7:8)]
full_data <- full_data[,-c(4,14)]
full_data <- full_data[,-c(11)]


glm.fit <- glm(num_downloads ~ ., family="poisson", data=full_data, control = list(maxit = 1000))
summary(glm.fit)

# Possible Overdispersion;
# Check of Overdispersion
#check of dispersion parameter: 144288.3
sum(residuals(glm.fit, type="pearson")^2)/glm.fit$df.residual

glm.fit.quasi <- glm( num_downloads ~ ., data=full_data, family="quasipoisson", control = list(maxit = 50))
summary(glm.fit.quasi)

#library(pscl)
#zero.inf <- zeroinfl(num_downloads ~ ., data=full_data, dist="negbin", control = zeroinfl.control(maxit = 500))
#summary(zero.inf)

### Model Diagnostics
fitted.mean <- (predict.glm(glm.fit, type='link'))
fitted.resp <- (predict.glm(glm.fit, type='response'))
fitted.var <- (full_data$num_downloads - fitted.mean)^2

fit.data <- data.frame(fitted.resp, fitted.var, fitted.mean)

#if slope=1 (Poisson) if not 1 (quassipoison) if not line (not poisson)
ggplot(fit.data, aes(x=log(fit.data[,1])) )+
  geom_point(aes(y=log(fit.data[,2]), colour ="orchid3"), size=3)+
  geom_abline(slope = 1, intercept = 0, color="black") +
  theme( legend.position= "none", axis.text=element_text(size=20), axis.title=element_text(size=24),
         text=element_text(size=24) ) +
  xlab(expression( 'Standardized '(hat(mu)) ) ) +
  scale_y_continuous(expression( 'Standardized '(y-hat(mu))^2 ) ) +
  scale_colour_identity() +
  xlim(c(0,20))+
  ggtitle(expression('Fitted Mean vs Fitted Variance') )
