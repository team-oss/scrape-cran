#simply counting the OSI approved in CRAN
data <- readRDS('./data/oss/working/CRAN_2018/Cran_full_table.RDS')
CI <- readRDS('./data/oss/working/CRAN_2018/Cran_CI.RDS')

# make our own rules to string replace
library(stringr)
library(dplyr)
#make database connection and then enter SQL query
con <- sdalr::con_db('oss')
df <- DBI::dbGetQuery(con, "SELECT * FROM licenses")

df$name <- tolower(df$name)

#now clean
#take out OR
data$'License:' <- str_replace_all(data$'License:', " \\|.*", "")
#take out +
data$'License:' <- str_replace_all(data$'License:', " \\+.*", "")


x <- as.data.frame(table(data$License))
x$Var1 <- as.character(x$Var1)
colnames(x) <- c("name", "freq")
x$name <- tolower(x$name)

y <- full_join(x,df,by = "name")

#MANUALLY determine if label IS OSI APPOVED - SAVE TIME
x$'osi-approved' <- c(0)

#export to excel and fill in
#write.csv(x, file= './data/oss/working/CRAN_2018/Licenses.csv')

#after filling in, I have this set here
Licenses_labeled <- read.csv('data/oss/working/CRAN_2018/Licenses_labeled.csv')
only_yes <- filter(Licenses_labeled, Licenses_labeled$osi.approved == 'yes')

#some analysis
#Attach all CI results
#CI <- subset(CI, (Status != 'ERROR') & (Status != 'FAIL')) #this doesn't work when data is wide
#get rid of any errors or fails this way
CI_passing <- CI[!apply(CI, 1, function(r) any(r %in% c("ERROR", "FAIL")))]

colnames(only_yes)[1] <- "License:"
colnames(data)[1] <- "name"
colnames(CI_passing)[1] <- "name"

#attach CI passes to the data
data_passing <- semi_join(data,CI_passing, by = "name")

#attach the OSI to new table
#first clean up license in both fields
data_passing$'License:' <- tolower(data_passing$'License:')
data$'License:' <- tolower(data$'License:')
only_yes$'License:' <- as.character(only_yes$'License')
#attach osi info and then filter by only yes
data_passing_osi <- full_join(data_passing,only_yes,  by = 'License:', copy = TRUE) %>%
  filter(osi.approved == 'yes')

#also save a osi and regular data intersection
only_yes <- as.data.table(only_yes)
data_only_osi <- full_join(data,only_yes,  by = 'License:', copy = TRUE)%>%
  filter(osi.approved == 'yes')

#find intersection with projects on github
# we are going to do this by applying a str detect from slug onto the url field in each pacakge
gits <- readRDS('./data/oss/original/CRAN_2018/cran_git_cleaner.RDS')


what <- data_passing_osi[!is.na(data_passing_osi$'URL:')]
colnames(what)[17] <- 'URL'
what$URL <- str_replace_all(what$URL,",.*","")
what$URL <- str_replace_all(what$URL,"\\s.*","")
what$ULR <- na.omit(what$URL)

#filter github urls
what <- what[str_detect(what$URL,'github')]
what$slug <- seq(1:nrow(what))
what$slug <- as.character(what$slug)
safety_net <- what$'BugReports:' #taking bug reports link if it is a github.io link

what <- data.table(cbind(what$URL,safety_net))
colnames(what)[1] <- 'URL'
#replace .io with real slug, take out anything not a github link
for(i in 1:nrow(what)){
  name <- what$URL[i]
  help <- what$safety_net[i]
  if(str_detect(name, '\\.io$') || !str_detect(name,"\\//github.com")){
    name <- help
  }
  #replace slug with the issues link, if available
  name <- str_remove(name,"/$")
  name <- str_remove(name,"\\/issues")
  what$slug[i] <- name
}

#get slug vector
slugs <- what$slug
#omit na, and then get the parsed slug
slugs <- str_replace_all(slugs,".*github.com/","")
slugs <- str_replace_all(slugs, "/$","")
slugs <- str_replace_all(slugs, "\\.git$","")
slugs <- str_extract(slugs, ".+?\\/([a-zA-Z0-9.\\-\\_,!@$%^&*()]+)")
slugs <- na.omit(slugs)
slugs <- unique(slugs)
length(slugs)
#use to save osi and ci
#saveRDS(data_passing_osi, file= './data/oss/working/CRAN_2018/OSI_CI_PASS.RDS')

#use to save osi and ci AND GITHUB
saveRDS(slugs, file= './data/oss/working/CRAN_2018/OSI_CI_GITHUB_SLUGS.RDS')

