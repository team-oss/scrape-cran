#this script is for analysis of the sourceforge data, specifically looking at total downloads.
knitr::opts_chunk$set(echo = FALSE)
load(file = 'data/oss/working/sourceforge/cleaned_SF.RData')
uncomp_SF <- cleaned_SF
load(file = 'data/oss/working/sourceforge/DONE_SFclean.RData')
cleaned_SF <- as.data.frame(cleaned_SF)
library(ggplot2)
library(plyr)
library(dplyr)
library(DiagrammeRsvg)
library(DiagrammeR)
library(magrittr)
library(rsvg)
library(data.table)
library(scales)

#start exploring
max(cleaned_SF$Total.Downloads, na.rm = T)
summary(cleaned_SF$Total.Downloads)

agg_dat <- plyr::count(cleaned_SF, c('Category.1', 'Category.2'))
#agg_dat1 <- plyr::count(cleaned_SF, c('Category.1', 'Category.2'))
agg_dat1 <- plyr::count(agg_dat, c('Category.1', 'Category.2'))
agg_dat1 <- agg_dat1[-nrow(agg_dat1),]

ggplot(agg_dat1)+ geom_bar(aes(x=Category.1, y=freq,fill = Category.2), stat= "identity")+ theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("Categories and Subcategories")

for(i in 1:nrow(agg_dat)){
  if(agg_dat$Category.1[i]=="Graphics" & is.na(agg_dat$Category.1[i]) == FALSE){
    agg_dat$Category.2[i] <- agg_dat$Category.3[i]
    agg_dat$Category.3[i] <- NA
  }
}


#this is where i am doing total downloads only
agg_dat2 <- plyr::count(cleaned_SF, c('Category.1', 'Category.2', 'Total.Downloads'))

# the letter s is total downloads
d <- agg_dat2 %>% dplyr::group_by(Category.1, Category.2) %>%
  dplyr::summarise(s = sum(Total.Downloads, na.rm = TRUE))

#plotting Total Downloads
ggplot(d)+ geom_bar(aes(x=Category.1, fill = Category.2, y=s), stat= "identity")+
  xlab('Category') +
  theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(name = "Total Downloads", labels = comma) +
  ggtitle("Total Downloads by Category")

#same but with boxplots
ggplot(cleaned_SF[which(cleaned_SF$Total.Downloads < 100000 & cleaned_SF$Total.Downloads > 100),])+
  geom_boxplot(aes(x=Category.1, y = Total.Downloads))+
  xlab('Category') +
  theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(name = "Total Downloads", labels = comma) +
  ggtitle("Total Downloads by Category")


#make a table to compare total downloads and rank of agg data
agg_dat
agg_dat_2_table <- cbind(agg_dat, d$s)
#remove the na row
agg_dat_2_table <- agg_dat_2_table[-nrow(agg_dat_2_table),]

#scatterplot that plots subcategories
ggplot(agg_dat_2_table)+
  geom_point(aes(x=freq, fill = Category.1, y= `d$s`), stat= "identity")+
  xlab('Projects per category') +
  theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(name = "Total Downloads", labels = comma) +
  ggtitle("Total Downloads by Projects per Category")






temp1 <- plyr::count(cleaned_SF, c('Category.1'))
# the letter s is total downloads
d2 <- temp1 %>% dplyr::group_by(Category.1) %>%
  dplyr::summarise(s = sum(Total.Downloads, na.rm = TRUE))
temp2 <- cbind(temp1, d2$s)
temp2$avg <- temp2$`d2$s` / temp2$freq
#fixed plot
fixed_plot <- ggplot(temp2)+ geom_bar(aes(x=Category.1, fill =Category.1, y= avg ), stat= "identity")+
  xlab('Category') +
  theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(name = "Average Downloads per project", labels = comma) +
  ggtitle("Average Downloads per project by Category")

#top downloaded projects
top_down <- subset(cleaned_SF, Total.Downloads > 100000000)
top_down <- top_down[,c(1,3,17)]
new_top_down <- top_down[order(top_down$Total.Downloads, decreasing = TRUE),]

#use this to save
png(filename="~/git/oss/src/ckelling/images/new_images/new_cat_bar.png",
units="in",
width=10,
height=10,
pointsize=12,
res=72,
bg = "transparent"
 )
 ggplot(temp2)+ geom_bar(aes(x=Category.1, fill =Category.1, y= avg ), stat= "identity")+
xlab('Category') +
  theme(legend.position="none",axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(name = "Average Downloads per project", labels = comma) +
  ggtitle("Average Downloads per project by Category")

+
  theme(axis.text.x = element_text(size = 15, angle = 90, hjust = 1))+
  theme(text = element_text(size=25))+theme(axis.text.x=element_text(size=20))

dev.off()
