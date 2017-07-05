#Source Forge Analysis
load(file = '~/git/oss/data/oss/working/sourceforge/cleaned_SF.RData')
cleaned_SF <- as.data.frame(cleaned_SF)
library(ggplot2)
library(plyr)
#source("http://bioconductor.org/biocLite.R")
#biocLite("ggtree")

#cleaned_SF <- cleaned_SF[1:100,]

profile_dat <- c()
for(i in 1:ncol(cleaned_SF)){
  print(i)
  if(i == 12){
    x <- cleaned_SF[,i]

    # Make all blanks NAs
    x[x == ""] <- NA

    name <- colnames(cleaned_SF)[i]
    class <- class(x)

    # Proportion of missing values
    miss <- round(sum(is.na(x))*100/nrow(cleaned_SF), digits = 2)

    # How many unique values to the variable?
    auth <- c()
    for(j in 1:length(x)){
      print(j)
      new_auth <- trimws(unlist(str_split(x[j], ",")))
      auth <- c(auth, new_auth)
    }

    vals <- length(unique(auth))
    # summary <- summary(x)
    #if(vals <= 10){
    #  tab <- table(x)
    #  print(tab)
    #}
  }else{
    x <- cleaned_SF[,i]

    # Make all blanks NAs
    x[x == ""] <- NA

    name <- colnames(cleaned_SF)[i]
    class <- class(x)

    # Proportion of missing values
    miss <- round(sum(is.na(x))*100/nrow(cleaned_SF), digits = 2)

    # How many unique values to the variable?
    vals <- length(unique(x))
    # summary <- summary(x)
    #if(vals <= 10){
    #  tab <- table(x)
    #  print(tab)
    #}
  }
  new_row <- c(name, class, miss, vals)
  profile_dat <- rbind(profile_dat, new_row)
}
colnames(profile_dat) <- c("Column Name", "Class", "% Missing" , "Unique Values")
save(profile_dat, file = '~/git/oss/data/oss/working/sourceforge/profile_dat.RData')

load( file = '~/git/oss/data/oss/working/sourceforge/profile_dat.RData')

par(mfrow=c(3,3))




#for tree diagram, must aggregate
agg_dat1 <- count(cleaned_SF, c('Category.1', 'Category.2'))
agg_dat <- count(cleaned_SF, c('Category.1', 'Category.2', 'Category.3'))
length(which(cleaned_SF$OSS.Title==""))
#dput(agg_dat)


ggplot(agg_dat, aes(Category.1))+ geom_bar(data=agg_dat, colour=Category.2)+ theme(axis.text.x = element_text(angle = 90, hjust = 1))
ggplot(test) + geom_bar(aes(x=a, y=b, fill=c), colour="black", stat="identity")

ggplot(agg_dat1)+ geom_bar(aes(x=Category.1, y=freq,fill = Category.2), stat= "identity")+ theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 1))


#length(which(df1$Category== "Games"))
#length(which(df1$Category== "Audio and Video"))



create_edges_3 <- function(x, y, z, freq) {
  data.frame('source' = c(x, y),
             'target' = c(y, z),
             'freq' = c(-1, freq)
  )
}

create_edges_2 <- function(x, y, freq) {
  data.frame('source' = c(x),
             'target' = c(y),
             'freq' = c(freq)
  )
}

create_edges_1 <- function(x, freq) {
  data.frame('source' = c(x),
             'target' = c(x),
             'freq' = c(freq)
  )
}

create_edges_0 <- function(freq) {
  data.frame('source' = c('EMPTY'),
             'target' = c('EMPTY'),
             'freq' = c(freq)
  )
}

create_edges <- function(x, y, z, freq) {
  num_complete <- 3 - sum(is.na(c(x, y, z)), na.rm = TRUE)

  if (num_complete == 0) {
    return(create_edges_0(freq))
  } else if (num_complete == 1) {
    return(create_edges_1(x, freq))
  } else if (num_complete == 2) {
    return(create_edges_2(x, y, freq))
  } else if (num_complete == 3) {
    return(create_edges_3(x, y, z, freq))
  } else {
    stop('got something i didnt expect')
  }
}

# df$num_na <- apply(X = df, MARGIN = 1, FUN = function(x){sum(is.na(x))})

edges <- mapply(FUN = create_edges,
                x = agg_dat$Category.1,
                y = agg_dat$Category.2,
                z = agg_dat$Category.3,
                freq = agg_dat$freq,
                SIMPLIFY = FALSE)

el <- data.table::rbindlist(edges)
head(el)


library(networkD3)
simpleNetwork(el, zoom = FALSE)#, linkColour=el$freq, zoom=FALSE)
?simpleNetwork

forceNetwork()

diagonalNetwork(List=edges)
?diagonalNetwork
library(igraph)
plot(graph.data.frame(el),rescale = FALSE, ylim=c(1,4),xlim=c(-17,24), asp = 0)

plot(graph.data.frame(el),layout = layout.reingold.tilford )

plot( graph.data.frame(el), layout = layout.reingold.tilford,
      edge.width = 1,
      edge.arrow.width = 0.3,
      vertex.size = 5,
      edge.arrow.size = 0.5,
      vertex.size2 = 3,
      vertex.label.cex = 1,
      asp = 0.35,
      margin = -0.1)


library(ggraph)
library(igraph)

new_dat <- igraph_to_networkD3(graph.data.frame(el),frequency(el$freq))
?new_dat
test<- graph.data.frame(el)

radialNetwork(List=new_dat)
