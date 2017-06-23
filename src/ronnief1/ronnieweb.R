#this is my attempt at web scraping in R
library(RCurl)
library(xml2)
library(stringr)
library(rvest)


sf_scrape <- function(link){
  #creating the html link to read
  new_link <- paste("https://sourceforge.net", link, sep ="")
  SFLink <- read_html(new_link)

  #Get the Title of OSS
  oss <- SFLink %>%
    html_node('div h1') %>%
    html_text() %>%
    str_trim()

  #Get the Average Rating
  avg_rat <-SFLink %>%
    html_node('section a') %>%
    html_text() %>%
    str_trim()

  #Get the Description
  desc <- SFLink %>%
    html_node('div h2') %>%
    html_text() %>%
    str_trim()
  #looking in another place for descriptions if it returns "Screenshots" (not real description)
  if(desc == 'Screenshots'){
    desc <- SFLink %>%
      html_node('#description') %>%
      html_text() %>%
      str_trim()
  }


  #Get the Last update
  last_update <- SFLink %>%
    html_node('section time') %>%
    html_text() %>%
    str_trim()

  #Get number of Ratings
  num_rat <- SFLink %>%
    html_node('#counts-sharing span') %>%
    html_text() %>%
    str_trim()

  #Get weekly downloads
  week_down <- SFLink %>%
    html_node('#call-to-action-stats') %>%
    html_text() %>%
    str_trim()

  #Tell me that this page is NOT an enterprise page (if it is, it will change to a diff function: detect later)
  is_enterpise <- "Project"

  #Get the categories
  category <- SFLink %>%
    html_nodes('#breadcrumbs li~ li+ li span') %>%
    html_text() %>%
    str_trim()

  #Get the date registered ONLY IF THIS PAGE IS NOT AN ENTERPRISE PAGE. Otherwise, return NA
  if(desc != "Overview") #Enterprise pages will usually return "Overview" for description
  {
    #Get all "additional details" nodes
    date_registered <- SFLink %>%
      html_nodes('#project-additional-trove .content') %>%
      html_text() %>%
      str_trim()

    #filter out for the date
    match <- grep(pattern = '20', x = date_registered)
    date_registered <- date_registered[match]
  }
  else{
    date_registered <- NA
  }

  #Get the authors in "Brought to you by"
  authors <- SFLink %>%
    html_nodes('#maintainers span') %>%
    html_text() %>%
    str_trim() %>%
    paste(collapse = ', ')

  #6/20 the code below does not work. trying xpath stuff to no avail.
  #social_media <- SFLink %>%
  #xml_find_all('//*[@id="aggregateCount"]') %>%
  #xml_text() %>%
  #str_trim()
  #User features: ease, features, design, support (ratings for reach)
  #Intended Audience (ex: developers)
  #Programming Language
  #Language

  #########################################################################################################
  ease <- SFLink %>%
    html_node('.dimensional-rating:nth-child(1) .rating-score') %>%
    html_text() %>%
    str_trim()
  features <- SFLink %>%
    html_node('.dimensional-rating:nth-child(2) .rating-score') %>%
    html_text() %>%
    str_trim()
  design <- SFLink %>%
    html_node('.dimensional-rating:nth-child(3) .rating-score') %>%
    html_text() %>%
    str_trim()
  support <- SFLink %>%
    html_node('.dimensional-rating:nth-child(4) .rating-score') %>%
    html_text() %>%
    str_trim()
  ########################################################################################################
  v = list('OSS Title' = oss, 'Average Rating' = avg_rat, 'Description' = desc, 'Last Update' = last_update,
           'Number of Ratings' = num_rat, 'Weekly Downloads' = week_down, 'Project Type' = is_enterpise,
           'Category 1' = category[1],'Category 2' = category[2], 'Category 3' = category[3],
           'Date registered' = date_registered, 'Authors' = authors, 'Ease' = ease)
  return(data.frame(v, stringsAsFactors = F))
}
#SFLink1 <- read_html("https://sourceforge.net/projects/audacity/?source=directory")

google

#iterate through project google likes urls by changing project name after projects%2F in URL
#same with fb

google_vec <- c()
fb_vec <- c()
for(i in 1:length(list_of_titles)){
  nl <- paste("https://www.facebook.com/plugins/like.php?href=https%3A%2F%2Fsourceforge.net%2Fprojects%2F", list_of_titles[i], sep="", "%2F&send=false&layout=button_count&width=80&show_faces=false&action=like&colorscheme=light&font&height=21")
  fb <- read_html(nl)
  likes <- fb %>%
    html_node('#u_0_2') %>%
    html_text() %>%
    str_trim()
  fb_vec[i] <- likes
  nl2 <- paste("https://apis.google.com/u/0/se/0/_/+1/fastbutton?usegapi=1&size=medium&annotation=bubble&origin=https%3A%2F%2Fsourceforge.net&url=https%3A%2F%2Fsourceforge.net%2Fprojects%2F", list_of_titles[i], sep="", "%2F&gsrc=3p&ic=1&jsh=m%3B%2F_%2Fscs%2Fapps-static%2F_%2Fjs%2Fk%3Doz.gapi.en.3t1xUeVe_Z4.O%2Fm%3D__features__%2Fam%3DAQ%2Frt%3Dj%2Fd%3D1%2Frs%3DAGLTcCN4hcAMb3eb3WPJTJu8oC1Cduzc2g#_methods=onPlusOne%2C_ready%2C_close%2C_open%2C_resizeMe%2C_renderstart%2Concircled%2Cdrefresh%2Cerefresh%2Conload&id=I0_1498069485200&parent=https%3A%2F%2Fsourceforge.net&pfname=&rpctoken=17547165")
  g <- read_html(nl2)
  google <- g %>%
    html_node('#aggregateCount') %>%
    html_text() %>%
    str_trim()
  google_vec[i] <- google
}

