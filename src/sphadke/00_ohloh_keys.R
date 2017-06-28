## File contains all API keys for OpenHub
# Source it to

# API keys
# Sayali's key
oh_key_sp <- "f4b26446fe7946dc11e35e1e34e99aa9c2362b4294ce5d9799913fb6edcb7487"

# Sayali's other key
oh_key_ssp <- "8d65198778b2c33c216cc560af86d3d730ac3a936ead6cc297212b5b13bc01ae"

# Alex's key
oh_key_old <- "d32768dd2ec65efd004d19a9f3c7262d7f30cd8959d9009ce4f9b8e7e19ff0ef&v=1"

# Ben's key
oh_key_bjs <- "ea13e69a9fe006292249cffce39e96a5781088724a61cda6dba72fd9e71ecc06"

# Lata's key
oh_key_lk <- "60ec34006651da0607103a505cc688a4bdbf09b076798f5a31a330b4ac20bb32"

# Kyle's key
oh_key_km <- "95fd35a60145093710ed0dee5c2e39d1db1e54fbf09d4093ac29e1e613899bd6"

# Eirik's key
oh_key_ei <- "789849b1179587e1333f41990a1542f48ae139dd43c3cfbf414618278a247380"

# Claire's key
oh_key_ck <- "352e2f22da39903451ab880c1fcbf5ce048d811b1b643d6d7bad879215d5f9fd"

# Kim's key
oh_key_kl <- "c35d07a8fdaf3d4e8e751c8bb6c4a83526d59a01b3bc8dddce86c79a385826d1"

# Lori's key
oh_key_lc <- "b1d57a7b8eee53271e35c5bfe6dc5c22238e8f0fed4b3543255c815e55db1014"

# Simu's key
oh_key_hs <- "8da56929b785b7a5035ed04472b05b94301c374da3cf98f3218b28acfe068f70"

# Chanida's key
oh_key_cl <- "5c32fe933ee240ff26192dd1c1e1eb6b5f44b6a0b80d3ed5f75a0a0ca425f212"


## Test api pull
# Run this on each new key to make sure it works
library(httr)
test_pull <- function(path, page_no, api_key){
  info <- GET(sprintf('https://www.openhub.net%s.xml?%s&api_key=%s',
                      path, #page URL
                      page_no, #must be in form "page=n"
                      api_key))
  return(info)
}

blah <- test_pull("/projects/firefox", "", oh_key_cl)



