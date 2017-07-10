library("animation")
ani.options(outdir = getwd())


im.convert("~/git/oss/src/ckelling/images/se_graph.pdf", output = "se.png")


title <- unique(complete_data$OSS.Title)
load("~/git/oss/data/oss/working/openhub/randomProjects/all_random_projects_table.RData")

title2 <- unique(randomProjectTable$project_name)
View(head(as.data.frame(title2)))

# full <- c(title, title2)
# head(full)
# length(full)

title <- na.omit(title)
title <- tolower(title)
title <- gsub('[0-9]+', '', title)
title <- str_replace_all(title,"[[:punct:]]","")
#title <- wordStem(title)
#title <- tm_map(title, removePunctuation)


?wordStem

title2 <- na.omit(title2)
title2 <- tolower(title2)
title2 <- gsub('[0-9]+', '', title2)
title2 <- str_replace_all(title2,"[[:punct:]]","")
#title2 <- wordStem(title2)
#title2 <- tm_map(title2, removePunctuation)

title <- unique(title)
title2 <- unique(title2)

full <- c(title, title2)


length(full)-length(unique(full))
table(duplicated(full))
