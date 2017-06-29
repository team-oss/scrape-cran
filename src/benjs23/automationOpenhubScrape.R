### Created by: benjs23
### Date: 6/29/2017

####### This code automates the scraping from OpenHub. It loads a list of API keys
####### and takes a function name as input. It automatically runs through every API
####### key, pulls the user specified tables, and tracks what information has been 
####### collected.



source("~/git/oss/src/sphadke/00_ohloh_keys.R")
keyTable <- data.frame(keyName = character(), key = character(), stringsAsFactors = TRUE)

for(i in 1:length(keys)){

}


keyTable[1,1] <-  keys[1]
keyTable[1,2] <-get(keys[1])
keyTable[2,] <- cbind( keys[2], get(keys[2]))
print(keyTable)

keyTable[2,]
keyTable[1,1] <- 1
