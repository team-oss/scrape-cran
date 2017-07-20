library(knitr)
opts_knit$set(progress=TRUE, tidy=TRUE)
#install.packages("devtools")
#install.packages('digest')
devtools::install_github("cboettig/knitcitations@v1")
library(knitcitations); cleanbib()
cite_options(citation_format = "pandoc", check.entries=FALSE)
library(bibtex)
library(magrittr)
library(ggplot2)
library(dplyr)
library(broom)
#install.packages("RJDBC")
#install.packages("rJava")
library(rJava)
library(RJDBC)

# To access the database, you'll need  the PostgreSQL driver.
# 1) go here and download the driver JAR file: https://jdbc.postgresql.org/download.html
# 2) put the downloaded JAR in the same directory as this file.
# 3) make sure the line below points to your newly-downloaded JAR file with the right name
# 4) done!
pgsql <- JDBC("org.postgresql.Driver", "postgresql-9.4-1203.jdbc4.jar", "`")
my_db <- dbConnect(pgsql,
                   "jdbc:postgresql://ec2-54-83-205-154.compute-1.amazonaws.com:6482/ddstg43butl93u?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory",
                   password="p16bm4ts99dvf63p9mrsbub5of7",
                   user="u3181cudsmcf62")

academic_packages = dbGetQuery(my_db, "
                               select
                               id,
                               host,
                               impact,
                               impact_percentile,
                               num_downloads,
                               num_downloads_percentile,
                               num_citations,
                               num_citations_percentile,
                               pagerank,
                               pagerank_score,
                               pagerank_percentile,
                               indegree,
                               neighborhood_size
                               from package
                               where is_academic = true")

## get data ready for dplyr
dp_aca = tbl_df(academic_packages)

## see what we've got
glimpse(dp_aca)

# now have a look at all package, academic or not, because need to query some of them
all_packages = dbGetQuery(my_db, "
                          select
                          id,
                          host,
                          is_academic,
                          has_best_import_name
                          from package")
dp_all = tbl_df(all_packages)
glimpse(dp_all)

# some graphs we might add later

# dp_aca %>% group_by(host) %>% ggplot(aes(num_downloads, pagerank, color=host)) +
#    geom_point(alpha=0.5) +
#    scale_y_log10() + scale_x_log10(labels=comma)

# dp_aca %>% group_by(host) %>% ggplot(aes(num_downloads, num_citations, color=host)) +
#    geom_point(alpha=0.5) +
#    stat_smooth_func(geom="text",method="lm",hjust=0,parse=TRUE)  +
#    scale_y_log10() + scale_x_log10(labels=comma)

# dp_aca %>% ggplot(aes(x=num_downloads, y=pagerank, colour=host)) + geom_point(alpha=.2) + geom_rug(alpha=0.1) + scale_y_log10() + scale_x_log10() + geom_smooth(method="lm", formula=y~x)
