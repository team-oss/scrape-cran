# double bar plot
library(gridExtra)
library(ggplot2)
load(file = '~/git/oss/data/oss/working/sourceforge/DONE_SFclean.RData')
agg_dat <- plyr::count(cleaned_SF, c('Category.1'))
agg_dat1 <- agg_dat[-nrow(agg_dat),]
ggplot(agg_dat1)+ geom_bar(aes(x=Category.1, y=freq,fill = Category.1), stat= "identity")+ theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("Project Count")

agg_dat2 <- plyr::count(cleaned_SF, c('Category.1', 'Total.Downloads'))
agg_dat3 <- agg_dat2 %>% dplyr::group_by(Category.1) %>%
  dplyr::summarise(sum = sum(Total.Downloads, na.rm = TRUE))
agg_dat3$average <- agg_dat3$sum / agg_dat$freq
agg_dat3$freq <- agg_dat$freq
agg_dat3 <- agg_dat3[-13,]


library(grid)
g.mid<-ggplot(agg_dat3,aes(x=1,y=Category.1))+geom_text(aes(label=Category.1), size=5)+
geom_segment(aes(x=0.94,xend=0.96,yend=Category.1))+
geom_segment(aes(x=1.04,xend=1.065,yend=Category.1))+
ggtitle("")+
ylab(NULL)+
scale_x_continuous(expand=c(0,0),limits=c(0.94,1.065))+
theme(axis.title=element_blank(),
panel.grid=element_blank(),
axis.text.y=element_blank(),
axis.ticks.y=element_blank(),
panel.background=element_blank(),
axis.text.x=element_text(color=NA),
axis.ticks.x=element_line(color=NA),
plot.margin = unit(c(1,-1,1,-1), "mm"))+
  theme(text = element_text(size=25))+theme(axis.text.x=element_text(size=20))


g1 <- ggplot(data = agg_dat3, aes(x = Category.1, y = freq)) +
  geom_bar(stat = "identity", aes(fill = Category.1)) + ggtitle("Number of Projects") +
  theme(axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        plot.margin = unit(c(1,-1,1,0), "mm")) +
  scale_y_reverse() + coord_flip()+theme(legend.position="none")+
  theme(text = element_text(size=15))+theme(axis.text.x=element_text(size=15))



g2 <- ggplot(data = agg_dat3, aes(x = Category.1, y = average)) +xlab(NULL)+
  geom_bar(stat = "identity", aes(fill = Category.1)) + ggtitle("Average Downloads per Project") +
  theme(axis.title.x = element_blank(), axis.title.y = element_blank(),
        axis.text.y = element_blank(), axis.ticks.y = element_blank(),
        plot.margin = unit(c(1,0,1,-1), "mm")) +  coord_flip()+theme(legend.position="none")+
  theme(text = element_text(size=15))+theme(axis.text.x=element_text(size=15))


gg1 <- ggplot_gtable(ggplot_build(g1))
gg2 <- ggplot_gtable(ggplot_build(g2))
gg.mid <- ggplot_gtable(ggplot_build(g.mid))

grid.arrange(gg1,gg.mid,gg2,ncol=3,widths=c(3.5/10,3/10,3.5/10))

data <- agg_dat3
colnames(data) <- c("category", "total_down", "av_down", "num_proj")
save(data, file = '~/git/oss/data/oss/working/sourceforge/dual_barplot_dat.Rdata')

save(data, file = '~/git/oss/src/ckelling/analysis/sourceforge/06_dual_barplot.R')
