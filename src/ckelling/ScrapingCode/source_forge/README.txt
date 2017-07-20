test_cases/
	-all code that was tried first before the actual SF scrape (not used in the final version)


LastYear/
	-code from 2016-2017 CMDA team to scrape from SF (not used for our project)

FULLscrape/
	-this includes the code used to scrape all of SF data
	-FULLscrapeSF.R: to do the second half of the data collection, with downloads
		If I ran this again for i in 1:nrow(masterlist), it would collect the complete data
	scrapewithdownloads/
		scrapewithdownloads.R
			-the code to do the first half of the scraping over, with just the 2 variables that
			were not collected the first time and the OSS name
