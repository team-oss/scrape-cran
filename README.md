# Measuring the Cost and Value of Open Source Software (OSS)

# Running the CRAN analysis

- `01_cran_scrape.R`
                This is the main function used to parse HTML from Cran and store it on the server.
                Small section of parallelized code to speed up scraping process
- `02_parse_cran.R`
                Transforming the data we scraped from CRAN from large lists to dataframes.
- `03_missingness.R`
                Generates a table of the missingness in variables (columns) scraped from CRAN.
- `04_CI_Checks.R`
                Using links from the original CRAN scrape (script 01),
                we know where the continuous integration checks are located for each package.
                Using a package’s link to its own CI results,
                we then scrape the HTML from that page and store it.
                This script is almost identical to 01_cran_scrape except the goal is to scrape CI checks for each package.
- `05_CI_OSI_subsets`
                0 filtering until this script.
                A lot of filtering in this script.
                TLDR: The goal of this script is to get all packages that have OSI approved licenses, Passing CI tests, and are on valid Github repos.
                In checking if packages were OSI approved,
                we got a list of all OSI approved licenses and used that to label packages as “approved” or not.
                I did this in excel and then imported the data back onto the server as I found it to be faster.
                From the set of all OSI approved packages,
                we then exclude any packages with the CI status “Error” or “Fail” so we are left with CI test passing packages.
                From that set, we filter so that we are left with packages that have Github links.
                Various data cleaning steps were taken to find the link if it was missing (take the link from bug reports, or issues).
                Looked for github related url's in the dataset.

Note: some code in this script breaks because we cannot use the “sdalr” package to get a table from the old SDAL database (lines 9 - 12) .

- `06_github_scrape.R`
                This is the script that gets us Github data.
                We get it by feeding in a slug to some github API calls that Bayoan wrote.
                The same data cleaning steps are performed as in script 05.
                Lines 125 to 132 are attempts to resolve NA repos from the first gitthub scrape,
                we fix this by getting the slugs of the Na repos and feeding it back into the function.
- `07_github_LoC`
                Making the Github lines of code calculations
- `08_CRAN_source_files.R`
                For CRAN packages that are not on github,
                we can calculate their lines of code by downloading the source files and then running a line count on the files.
                This script grabs all the LINKS to the source files for all Cran packages.
- `09_Cran_LOC.R`
                This downloads all of cran and then runs line counts on each package. Calculates cost with same formula as github packages
                .R .c, .h files filtered
- `10_github_contrib.R`
                This function works with github contributors and works with more github API calls.
                The code doesn’t work right now, but it doesn’t write out any data so I believe this was not used for anything.
                Seems like a byoan script.
- `11_uploads.R`
                Combining Cran github information along with lines of code and contributor information, then uploading them to the SDAL database.
                The resulting tables are for packages with OSI, CI passing, and on Github.
- `12_cleaning_keys.R`
                this is a cleaning script to produce a list of OSI approved and CI approved github slugs with package names.
                Mostly data cleaning steps here
- `13_github_fix.R`
                We missed a few packages in data cleaning, so we just make sure to obtain relevant information on what we missed:

```r
#load our list of keys, and identify the set of packages that we have missed
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS') # from script 12
Analysis <- readRDS('./data/oss/working/CRAN_2018/Analysis.RDS') # from uploads (script 11)
missed <- setdiff(keys$slug, Analysis$slug) #this should be 220 packages
After identifying what we missed we get the information and bind it back to our master analysis table
```


# Running the code.gov analysis

The Data is collected from the API from the following script

```bash
Rscript ./src/01-data_collection/scrape/code_gov/use_api/01-get_repos.R
```

The data preparation

- Tag which repositories are OSI approved
- Domain of the repositoryURL

```bash
Rscript ./src/02-data_processing/code_gov/01-add_columns.R
```

Exploratory reports

Repository domain counts

```bash
Rscript -e "rmarkdown::render(here::here('./src/exploratory/code_gov/repository_domains.Rmd'), output_dir = here::here('./output/code_gov'))"
Rscript -e "bad_html <- './src/exploratory/code_gov/repository_domains.html'; if (file.exists(here::here(bad_html))) file.remove(here::here(bad_html))"
```
