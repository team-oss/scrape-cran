tagString <-list()
tagStringMozilla <- list()
tagStringMozilla <- str_split(projectRelevantMaster$tags[1], pattern = ";")
tempString <- NA
matches <- list()

for( i in 2:length(projectRelevantMaster$tags))
{
  tagString[i] <- str_split(projectRelevantMaster$tags[i], pattern = ";")
}

for(j in 2:length(tagString))
{
matches[[j-1]] <- na.omit(match(tagStringMozilla[[1]], tagString[[j]]))
}

matches[[1]]

matchedTags <- NA

for(j in 2:length(tagString))
{
  for(k in 1:length(matches[[j-1]]))
  {
    tempString <- c(tempString, tagString[[j]][(matches[[j-1]][k])])
    
    if(length(tempString) > 0)
    {
      
      tempString <- na.omit(tempString)
      tempString <- paste(tempString, collapse = ";")
    }
    else
    {
      tempString = ''
    }
  }
  
  matchedTags[j] <- tempString
  tempString<-NA
  
}

save(matchedTags, file="~/git/oss/data/oss/working/openhub/relevantProjects/matchedTags.RData")
matchedTags <- as.data.frame(matchedTags)
rm(matchedTags)
