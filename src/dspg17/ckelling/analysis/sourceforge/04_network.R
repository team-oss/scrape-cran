library(plyr)
load(file = '~/git/oss/data/oss/working/sourceforge/DONE_SFclean.RData')


agg_dat <- plyr::count(cleaned_SF, c('Category.1', 'Category.2', 'Category.3'))
#agg_dat = agg_dat[which(agg_dat$Category.1 == "Science & Engineering"),]


for(i in 1:nrow(agg_dat)){
    if(agg_dat$Category.1[i]=="Graphics" & is.na(agg_dat$Category.1[i]) == FALSE){
        agg_dat$Category.2[i] <- agg_dat$Category.3[i]
        agg_dat$Category.3[i] <- NA
    }
}

agg_dat1 <- plyr::count(agg_dat, c('Category.1', 'Category.2'))
agg_dat1 <- agg_dat1[-nrow(agg_dat1),]
agg_dat <- agg_dat[-nrow(agg_dat),]
agg_dat2 <- plyr::count(agg_dat1, c('Category.1'))

node_mat1 <- agg_dat2
node_mat2 <- agg_dat1[which(!is.na(agg_dat1$Category.2)),2:3]
node_mat3 <- agg_dat[which(!is.na(agg_dat$Category.3)),3:4]

n_names <- c("node", "freq")
colnames(node_mat1) <- n_names
colnames(node_mat2) <- n_names
colnames(node_mat3) <- n_names
node_mat <- rbind(node_mat1, node_mat2, node_mat3)
#length(unique(node_mat$node))
node_mat_dup <- node_mat[duplicated(node_mat$node),]

#need to aggregate data for repeated nodes
for(i in 1:nrow(node_mat_dup)){
  indices <- which(node_mat$node == node_mat_dup[i,1])
  node_mat$freq[indices[2]] <- sum(node_mat$freq[indices])
  node_mat$freq[indices[1]] <- node_mat$freq[indices[2]]
}
node_mat <- node_mat[!duplicated(node_mat$node),]

# This is the category
library(data.table)
#node_mat[ ,4] <- sample(1:5, nrow(node_mat), TRUE, rep(0.2, 5))
agg_dat <- data.table(agg_dat)
node_mat[,3] <- c()
for(i in 1:nrow(node_mat)){
  node_mat[i,3] <- (agg_dat[Category.1 == node_mat$node[i] | Category.2 == node_mat$node[i] | Category.3 == node_mat$node[i], Category.1])[1]
}
colnames(node_mat)[3] <- "category"

edge_mat1 <- unique(agg_dat[which(!is.na(agg_dat$Category.2)),1:2])
edge_mat2 <- unique(agg_dat[which(!is.na(agg_dat$Category.3)),2:3])

e_names <- c("source", "target")
colnames(edge_mat1) <- e_names
colnames(edge_mat2) <- e_names

edge_mat <- rbind(edge_mat1, edge_mat2)
agg_dat <- as.data.frame(agg_dat)

library(network)
#now, I will try to plot the network
sf.net <- network(edge_mat,
                       directed = TRUE, matrix.type = "edgelist")


#### Basic plot of the network
plot(sf.net)
set.vertex.attribute(sf.net, names(node_mat), node_mat)
plot(sf.net, displaylabels = F,
     #label = get.vertex.attribute(sf.net, "female"),
     vertex.cex = get.vertex.attribute(sf.net, "freq"))#vertex.col = get.vertex.attribute(sf.net, "freq"))
?plot.network
get.vertex.attribute(sf.net, "female")

plot.network(sf.net, displaylabels = FALSE, mode= "fruchtermanreingold", interactive = FALSE)


library(GGally)
library(network)
library(sna)
library(ggplot2)
library(ggnetwork)
library(geomnet)

ggnet2(sf.net, node.size = )


ggplot(n, aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_edges(aes(linetype = type), color = "grey50") +
  geom_nodes(aes(color = family, size = importance)) +
  theme_blank()

sf.net %v% "importance" <- sample(1:3, 10, replace = TRUE)



data(madmen, package = "geomnet")
data(madmen)

# code for geom_net
# data step: merge edges and nodes by the "from" column


MMnet <- fortify(as.edgedf(madmen$edges), madmen$vertices)
test <- fortify(as.edgedf(edge_mat), node_mat)

edge_mat <- as.data.frame(edge_mat)
# ggplot(data = MMnet, aes(from_id = from_id, to_id = to_id)) +
#   geom_net(aes(colour = Gender), layout.alg = "kamadakawai",
#            size = 2, labelon = TRUE, vjust = -0.6, ecolour = "grey60",
#            directed =TRUE, fontsize = 3, ealpha = 0.5, ) +
#   scale_colour_manual(values = c("#FF69B4", "#0099ff")) +
#   xlim(c(-0.05, 1.05)) +
#   theme_net() +
#   theme(legend.position = "bottom")

ggplot(data = test, aes(from_id = from_id, to_id = to_id)) +
  geom_net(aes(size= freq), layout.alg = "fruchtermanreingold",
           labelon = FALSE, vjust = -0.6, ecolour = "grey60",
           directed =TRUE, fontsize = 4, ealpha = 0.25, arrowsize = 0.5, repel = TRUE) +
  xlim(c(-0.05, 1.05)) +
  theme_net() +
  theme(legend.position = "bottom")






# ggplot(data = test,aes(from_id = from_id, to_id = to_id)) +
#   geom_net(layout.alg = "fruchtermanreingold",
#            aes(fontsize = freq), directed = TRUE,
#            labelon = FALSE, size = 1, labelcolour = 'black',
#            ecolour = "grey70", arrowsize = 0.5,
#            linewidth = 0.5, repel = TRUE) +
#   theme_net() +
#   xlim(c(-0.05, 1.05))
