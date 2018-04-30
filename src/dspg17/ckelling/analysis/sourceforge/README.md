This is all of the code to analyze the sourceforge data, in multiple steps

00_data_organization.R
  taking all of the data from multiple locations and saves a complete data file for   all 450,000 projects on SF

01_data_cleaning.R
  functions to clean the data, cleans the data, and stores it
  
02_sf_analysis.Rmd
  this is a majority of the SF analysis, including categories and networks

03_oh_overlap.R
  tries to figure out the overlap between the Openhub projects and SF projects

04_network.R
  tries to use ggplot to create a network (not successful)

05_better_network.R
  creates the visualization of the network that is in the poster
  
06_dual_barplot.R
  creates the dual barplot that is used in the poster (both #projects and #avg   
  downloads/category)

07_top_packages.R
  finds the top packages by downloads

08_top_percentages.R
  allows me to find the top subcategories by percentages of the full categories

99_analysis.R
  attempting to create a network (doesn't work)

99_network_image.R
  attempting to create a network (doesn't work)

dan_functions.R
  dan's functions to create a network from the aggregated dataset (used to create 
  science and engineering network in file 02)
