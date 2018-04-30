#Initial Analysis

load(file = "~/git/oss/data/oss/original/depsy/fullcontrib_mat.Rdata")
load(file = "~/git/oss/data/oss/original/depsy/node_mat.Rdata")

library(SnowballC)
library(stringr)
library(tm)
library(wordcloud)

## Word cloud of dps descriptions
dps_chrg_corpus <- Corpus(VectorSource(node_mat$summary))
#dps_chrg_corpus <- tm_map(dps_chrg_corpus, PlainTextDocument)
dps_chrg_corpus <- tm_map(dps_chrg_corpus, content_transformer(tolower))

dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, stopwords('english'))
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, c("functions", "data", "package", "based", "can", "provides", "set", "used", "project", "using", "contains", "function"))
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeNumbers)
dps_chrg_corpus <- tm_map(dps_chrg_corpus, removePunctuation)

#dps_chrg_corpus <- tm_map(dps_chrg_corpus, stemDocument)

dps_temp_stemmed <- data.frame(text = sapply(dps_chrg_corpus, as.character), stringsAsFactors = FALSE)

dps_dtm <- TermDocumentMatrix(dps_chrg_corpus)
dps_m <- as.matrix(dps_dtm)
dps_v <- sort(rowSums(dps_m),decreasing=TRUE)
dps_d <- data.frame(word = names(dps_v),freq = dps_v)
#View(dps_d)


png(filename="~/git/oss/src/ckelling/images/wordcloud_dps_contrib.png",
    units="in",
    width=10,
    height=10,
    #pointsize=12,
    res=72
)
wordcloud(dps_d$word, dps_d$freq, min.freq = 5,  random.order = FALSE, colors=brewer.pal(8, "Dark2"))
dev.off()


#now for the contributor frequency on packages
 fullcontrib_mat <- as.data.frame(fullcontrib_mat)
 dps_chrg_corpus <- Corpus(VectorSource(fullcontrib_mat$oss))
 dps_chrg_corpus <- tm_map(dps_chrg_corpus, content_transformer(tolower))
 dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, stopwords('english'))
 dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeWords, c("functions", "data", "package", "based", "can", "provides", "set", "used", "project", "using", "contains", "function"))
 dps_chrg_corpus <- tm_map(dps_chrg_corpus, removeNumbers)
 dps_chrg_corpus <- tm_map(dps_chrg_corpus, removePunctuation)
 dps_temp_stemmed <- data.frame(text = sapply(dps_chrg_corpus, as.character), stringsAsFactors = FALSE)
 dps_dtm <- TermDocumentMatrix(dps_chrg_corpus)
 dps_m <- as.matrix(dps_dtm)
 dps_v <- sort(rowSums(dps_m),decreasing=TRUE)
 dps_d <- data.frame(word = names(dps_v),freq = dps_v)


 wordcloud::wordcloud(dps_d$word, dps_d$freq, min.freq = 3, random.order = FALSE, colors=brewer.pal(8, "Dark2"))

 dev.off()

 dps_d <- dps_d[1:1000,]

 letterCloud(demoFreq, word = "R", size = 3)

 class(wordcloud2(data = demoFreq))

 letterCloud(dps_d, word = "R", size= 2)

 demoFreq <- demoFreq
 class(demoFreq)
 class(dps_d)

 wordcloud2(data= dps_d)

 png(filename="~/git/oss/src/ckelling/images/7_17_images/wordcloud_dps_contrib.png",
     units="in",
     width=10,
     height=10,
     #pointsize=12,
     res=72
 )

 wordcloud::wordcloud(dps_d$word, dps_d$freq, min.freq = 10, random.order = FALSE, colors=brewer.pal(8, "Dark2"))


dev.off()

mean(dps_d$freq)
