library(data.table)
agg_dat <- plyr::count(cleaned_SF, c('Category.1', 'Category.2', 'Category.3'))
#agg_dat1 <- plyr::count(cleaned_SF, c('Category.1', 'Category.2'))

for(i in 1:nrow(agg_dat)){
  if(agg_dat$Category.1[i]=="Graphics" & is.na(agg_dat$Category.1[i]) == FALSE){
    agg_dat$Category.2[i] <- agg_dat$Category.3[i]
    agg_dat$Category.3[i] <- NA
  }
}
agg_dat1 <- plyr::count(agg_dat, c('Category.1', 'Category.2'))
agg_dat1 <- agg_dat1[-nrow(agg_dat1),]
agg_dat <- agg_dat[-nrow(agg_dat),]

top_cat  <- data.table(agg_dat1, key="Category.1")
top_cat <- top_cat[order(Category.1, -freq),]
top_cat <- top_cat[, head(.SD, 3), by=Category.1]
#taking out the NA row
top_cat <- top_cat[-nrow(top_cat),]
View(top_cat)
top_cat$total <- rep(sum(agg_dat1$freq), nrow(top_cat))

agg_dat4 <- plyr::count(cleaned_SF, c('Category.1'))

#library(dplyr)
test <- left_join(top_cat, agg_dat4, by = c(Category.1 = "Category.1"))
test$avg <- test$freq.x/test$freq.y
test$avg <- round(test$avg, digits=2)
