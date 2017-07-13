

#cat_bar.png
# ggplot(agg_dat1)+ geom_bar(aes(x=Category.1, y=freq,fill = Category.2), stat= "identity")+ theme(legend.position="none",axis.text.x = element_text(angle = 90, hjust = 1)) + ggtitle("Categories and Subcategories")

#date_reg_time.png
# ggplot(summary, aes(x=date, y=freq))+
#   geom_line(aes(group = 1,colour = substr(date,6,7))) +
#   #geom_point() +
#   ggtitle("Date Registered Over Time") +
#   labs(x = "Date", y = "Total Update") +
#   theme(plot.title = element_text(hjust = 0.5))+
#   scale_colour_discrete(name="Month")

# #full_graph.png
# network_graph(agg_dat)
# network_graph(agg_dat) %>%
#   export_svg %>% charToRaw %>% rsvg_png("~/git/oss/src/ckelling/images/new_images/full_graph.pdf")
# library("animation")
# ani.options(outdir = "~/git/oss/src/ckelling/images")
# im.convert("~/git/oss/src/ckelling/images/full_graph.pdf", output = "full_graph.png")


#last_up_time.png
# ggplot(summary, aes(x=date, y=freq))+
#   geom_line(aes(group = 1,colour = substr(date,6,7))) +
#   #geom_point() +
#   ggtitle("Last Update Over Time") +
#   labs(x = "Date", y = "Total Update") +
#   theme(plot.title = element_text(hjust = 0.5))+
#   scale_colour_discrete(name="Month")

#profile_table.png
# library(gridExtra)
# png(filename="~/git/oss/src/ckelling/images/new_images/profile_table.png",
#     units="in",
#     width=10,
#     height=10,
#     #pointsize=20,
#     res=72
# )
# p<-tableGrob(profile_dat)
# grid.arrange(p)
# dev.off()

#se_graph.png
# network_graph(se_counts)
# network_graph(se_counts) %>%
#   export_svg %>% charToRaw %>% rsvg_png("~/git/oss/src/ckelling/images/new_images/se_graph.pdf")
# ani.options(outdir = "~/git/oss/src/ckelling/images/new_images")
# im.convert("~/git/oss/src/ckelling/images/new_images/se_graph.pdf", output = "se_graph.png")

#wordcloud_common.png
commonality.cloud(test, max.words = 400, random.order = FALSE, colors = brewer.pal(8, "Dark2"))


#worldcloud_compar, must run after common
comparison.cloud(test_compar, random.order=FALSE, colors = c("indianred3","steelblue3"),
                 title.size=2.5, max.words=400)


library(gridExtra)
png(filename="~/git/oss/src/ckelling/images/new_images/top_cat.png",
    units="in",
    width=10,
    height=10,
    #pointsize=20,
    res=72
)
p<-tableGrob(top_cat)
grid.arrange(p)
dev.off()

View(head(fullcontrib_mat, n=10))
