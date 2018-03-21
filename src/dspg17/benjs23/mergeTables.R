folder<-"users/user_tables"

mergeTables <- function(folder)
{

file_list <- list.files(paste0("./data/oss/original/openhub/",folder))

for(i in 1:length(file_list))
{
  extension <- paste0("./data/oss/original/openhub/",folder,"/", file_list[i])
  if (!exists("dataset")){
    dataset <- get(load(file=extension))
  }
  temp_dataset <- get(load(file=extension))
  dataset <- rbind(dataset, temp_dataset)
  rm(temp_dataset)
  rm(extension)
}
save(dataset, file="./data/oss/working/openhub/users/userTable.RData")
}

