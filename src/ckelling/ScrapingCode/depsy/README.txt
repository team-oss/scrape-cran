LastYear/
	-code from 2016-2017 CMDA team to scrape from SF (not used for our project)

01_cran_scrape.R
	-code to scrape all available packages from CRAN

02_error_detection.Rmd
	-figures out which packages are not listed on Depsy, and record where these errors occur

03_row_function.R
	-this creates functions to scrape all information from Depsy

04_depsy_api_scrape.Rmd
	-using the functions in the previous file, I scrape all of the information for the nodes (packages) from Depsy

contrib_scrape/
	full_scrape/
		full_contrib.R
			***scrapes all available information for the contributors from Depsy
	contrib_scrape.R
		scrapes just the contributor names, no other information

neighb_scrape/
	neighb_scrape.R
		scrapes all of the dependencies from Depsy

run_overnight.R
	code to get the rest of the Depsy data, that would take a while overnight

tag_scrape/
	tag_scrape.R
		scrapes all of the tag information from Depsy (just package name and tag name)

top_contrib/
	top_contrib.R
		scrapes only the top contributors listed on Depsy

top_neighb/
	top_neighb.R
		scrapes only the top dependencies from Depsy