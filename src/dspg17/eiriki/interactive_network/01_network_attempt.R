#this code never got finished but it is a start on an interactive categorical netowrk of SF projects.

#this script will make a network of categories, and will hopefully be interactive
#I am learning how to code it from this website: http://kateto.net/network-visualization
#comments that explain the code are paraphrased from that website.
library("igraph")
library("network")
library("sna")
library("visNetwork")
library("threejs")
library("networkD3")
library("ndtv")
library('rio')

nodes <- import('src/eiriki/interactive_network/node_mat.RData')
edges <- import('src/eiriki/interactive_network/edge_mat.RData')

net <- graph_from_data_frame(d=edges, vertices = nodes, directed = T)
plot(net)


# Generate colors based on category:
colrs <- palette(rainbow(10))
wheel <- function(col, radius = 1, ...)
  pie(rep(1, length(col)), col = col, radius = radius, ...)
wheel(colrs)

V(net)$color <- colrs[V(net)$category]

# Compute node degrees (#links) and use that to set node size:
deg <- igraph::degree(net, mode="all")
V(net)$size <- deg*3

# The labels are currently node IDs.
# Setting them to NA will render no labels:
V(net)$label <- NA

# Set edge width based on weight:
E(net)$width <- E(net)$weight/6

#change arrow size and edge color:
E(net)$arrow.size <- .2
E(net)$edge.color <- "gray80"
E(net)$width <- 1+E(net)$weight/12
plot(net)
