#upload everything to the database
#calculate big analysis table
library(sdalr)
library(DBI)
library(data.table)

helping <- readRDS('./data/oss/working/CRAN_2018/Cran_git_cleanest.RDS')
help_dates <- group_by(helping, slug)%>% summarise(mindate=min(start_date),maxdate=max(end_date))
help_table <- data.frame(table(helping$slug))
colnames(help_table) <- c("slug","freq")
help_table$slug <- as.character(help_table$slug)
Loc <- readRDS('./data/oss/working/CRAN_2018/Cran_lines_of_code.RDS')
contrib <- readRDS('./data/oss/working/CRAN_2018/Cran_git_contribs_more.RDS')

last_set <- full_join(Loc,contrib, by= "slug")
last_set <- full_join(last_set,help_table,by='slug')
last_set <- full_join(last_set,help_dates,by='slug')


#Important cleaning step: only taking complete cases of the join.
# I choose to do this because I know the github contribution data is OSI CI passing,
# but the Lines of Code data is just all github. So when contribution data is missing, get rid of the
# entire row

last_set <-  last_set[complete.cases(last_set),]

analysis <- data.table(matrix(nrow = nrow(last_set),ncol = 10))
colnames(analysis) <- c("registry","slug","start_date","end_date","kloc","commits","num_of_contributors",
                        "all_contributors","major_contributors","all_commits")
#make all registry R
analysis$registry <- (rep("R",nrow(last_set)))

#fill slugs
analysis$slug <- last_set$slug

#make all start date
analysis$start_date <- last_set$mindate
analysis$end_date <- last_set$maxdate
#fill kloc
analysis$kloc <- last_set$kloc

#fill commits
analysis$commits <- last_set$commits.x

#fill num contrib
analysis$num_of_contributors <- last_set$freq

#fill all contrib
analysis$all_contributors <- last_set$contributors

#major contributors
analysis$major_contributors <- (analysis$kloc / sum(analysis$kloc) > 5e-2)

#all_commits
analysis$all_commits <- last_set$commits.y

#saveRDS(analysis, file ='./data/oss/working/CRAN_2018/Analysis.RDS')

#write to database
# my_db_con <- con_db("oss", pass=sdalr::get_my_password())
# dbWriteTable(con = my_db_con,
#              name = "CRAN_analysis",
#              value = analysis,
#              row.names = FALSE,
#              overwrite = TRUE)

passing <- readRDS('./data/oss/working/CRAN_2018/OSI_CI_PASS.RDS')
passing <- data.table(passing)
#write to database
# my_db_con <- con_db("oss", pass=sdalr::get_my_password())
# dbWriteTable(con = my_db_con,
#              name = "CRAN_OSI_CI_passing",
#              value = passing,
#              row.names = FALSE,
#              overwrite = TRUE)


#Bayoan needs the package name and slug keys
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS')
keys <- data.table(keys)
#write to database
# my_db_con <- con_db("oss", pass=sdalr::get_my_password())
# dbWriteTable(con = my_db_con,
#              name = "CRAN_name_slug_keys",
#              value = keys,
#              row.names = FALSE,
#              overwrite = TRUE)
