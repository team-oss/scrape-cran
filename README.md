# Measuring the Cost and Value of Open Source Software (OSS)

# Setup

1. Get a github personal access token from: https://github.com/settings/tokens
2. Setup your `.Renviron` file (to make it easier run: `usethis::edit_r_environ()`, or edit `~/.Renviron` directly)
  - add a like this to the file: `GH_TOSS_TOKEN='YOUR_TOKEN'`
      - You can use `GH_TOSS_TOKEN='1c06459fc9b515e2a5aa748b06913f3495068a45'`, but may not work since its not your own token.
  - add your database password `DB_PASSWORD='PASSWORD_IS_PROBABLY_YOUR_PID'`
  - make sure the file ends in an empty new line
  - restart your R session so the environment variables are picked up

# Running the CRAN analysis

The cran pull is taken from the packages listed on: https://cran.r-project.org/web/packages/available_packages_by_name.html

### Getting CRAN projects

```bash
Rscript ./src/01-data_collection/scrape/CRAN/01-cran_scrape.R
```

### From CRAN to github

```bash
Rscript ./src/01-data_collection/scrape/CRAN/02_parse_cran.R
Rscript ./src/01-data_collection/scrape/CRAN/03_missingness.R
Rscript ./src/01-data_collection/scrape/CRAN/04_CI_Checks.R
Rscript ./src/01-data_collection/scrape/CRAN/05_CI_OSI_subsets.R
```

### Script descriptions

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
- `14_costs.R`
                Attaching cost calculation to an analysis table

- `15_cost_comparisons.R`
                Exploratory work to look at the difference in lines of code between source files from CRAN and lines of code info from Github.
                Small plotting efforts but nothing that was used in the poster

- `16_HEX.R`
                Exploratory plotting comparing outdegree and cost across Python, Julia, CDN(JS), and R. None of these visuals were used in the poster

Also, there are two other scripts in the repo right now (chk.R and dependencies.R). I’m pretty certain that Bayoan wrote these scripts either to check my work or to do a little bit of work on CRAN. Either way I don’t think I used/edited anything in those scripts.

```r
#load our list of keys, and identify the set of packages that we have missed
keys <- readRDS('./data/oss/working/CRAN_2018/name_slug_keys.RDS') # from script 12
Analysis <- readRDS('./data/oss/working/CRAN_2018/Analysis.RDS') # from uploads (script 11)
missed <- setdiff(keys$slug, Analysis$slug) #this should be 220 packages
After identifying what we missed we get the information and bind it back to our master analysis table
```

# Running the Python pip analysis

Some of the "original" data sets cannot be located, but they have been saved in the database.

- `./data/oss/final/PyPI/complete_osi_info.csv` can be found in the SDAL Database as `postgresql/oss/public/python_general_pkg_info`
- `./data/oss/working/pypi/10_github_api_info.csv` can be found in the SDAL Database as `postgresql/oss/public/python_final`
- `./data/oss/final/PyPI/python_pkg_dependencies.csv` can be found in the SDAL Database as `postgresql/oss/public/python_pkg_dependencies`


### Script descriptions

- `00_final_cleaning.R`
                Using the final data table produced in `10_num_contributors.R`, this script cleans all of the final data.
        - input: `~/oss/data/oss/final/PyPI/complete_osi_info.csv`
        - input: `~/oss/data/oss/working/pypi/10_github_api_info.csv`
        - input: `~/oss/data/oss/final/PyPI/python_pkg_dependencies.csv`
        - output: db: `oss/python_cost_estimates`
- `01_names.R`
                This is the beginning of the Pip data collection and cleaning.
                This script collects all of the names of Python packages from pypi.org in the development categories Production/ Stable and Mature.
        - input: None
        - output: `~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv`
        - output: `~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv`
- `02_all_names_cleaning.R`
                Using the names scraped from pypi.org in the Production/ Stable and Mature categories from the `01_names.R` script,
                this script cleans the data to result in a final clean list of these package names.
        - input: `~/oss/data/oss/working/pypi/02_prod_stable_pkgs_names.csv`
        - intput: `~/oss/data/oss/working/pypi/02_mature_pkgs_names.csv`
        - output: `~/oss/data/oss/working/pypi/03_prod_mature_names.csv`
- `03_librariesio_licenses.R`
                Using the final list of package names produced from `02_all_names_cleaning.R`
                this script scrapes libraries.io to collect licenses for the packages.
        - input: `~/oss/data/oss/working/pypi/03_prod_mature_names.csv`
        - output: `~/oss/data/oss/working/pypi/04_prod_mature_w_licenses.csv`
- `04_licenses_cleaning_sort.R`
                Using the licenses collected in `03_librariesio_licenses.R`
                this script uses an already produced data set of all OSI-approved licenses
                to create a column for each package that indicates if the license for that package is an OSI-approved license.
                This script also includes some exploratory analysis code.
        - input: `~/oss/data/oss/working/pypi/04_prod_mature_w_licenses.csv`
        - input: `~/oss/data/oss/final/PyPI/osi_approved_licenses.csv`
        - output: `~/oss/data/oss/working/pypi/05_prod_mature_names_w_osi_approved_status.csv`
- `05_repository_scraping.R`
                Using the list of just the packages with OSI-approved licenses that was created from `04_licenses_cleaning_sort.R`,
                this script collects repository URLs for these packages using libraries.io.
        - input: `~/oss/data/oss/working/pypi/05_prod_mature_names_w_osi_approved_status.csv`
        - output: `~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv`
        - output: `~/oss/data/oss/working/pypi/07_names_prod_mature_osi_approved.csv`
- `06_github_api.R`
                Using the list of packages with OSI-approved licenses and repository URLs collected from `05_repository_scraping.R`,
                this script uses the Github API to collect repositories for packages where libraries.io had no repository listed and/or
                to ensure that if the package has a Github.com repository,
                the data table has the correct url for the repository on Github to be used later.
                This script also utilizes the Github API to collect information for packages with valid Github repositories about their activity including
                start date, end date, additions, and deletions for the top contributors to the project.
        - input: `~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv`
        - output: `~/oss/data/oss/working/pypi/10_github_api_info.csv`
- `07_dependencies_cleaning.R`
                Using the dependencies collected for all Production/Stable and Mature OSI-approved packages in “dep_script.py”,
                this script parses out just the dependencies for each package.
        - input: `~/oss/data/oss/working/pypi/07_names_prod_mature_osi_approved.csv`
        - input: `~/oss/data/oss/working/pypi/01_dependencies_files/`
        - output: `~/oss/data/oss/final/PyPI/python_pkg_dependencies.csv`
        - output: db: `oss/python_pkg_dependencies`
- `08_github_contd.R`
                Using the list of packages with OSI-approved licenses and repository URLs collected from “05_repository_scraping.R”,
                this script uses the Github API to collect numbers of stars for each package with a valid Github repository.
        - input: `~/oss/data/oss/working/pypi/06_osi_approved_w_repos.csv`
        - output: `~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv`
- `09_additional_info.R`
                Using the data produced in “08_github_contd.R”,
                this script collects the latest release date as well as latest version number for these packages from pypi.org.
        - input: `~/oss/data/oss/working/pypi/09_github_api_info_w_stars.csv`
        - output: `~/oss/data/oss/working/pypi/10_github_and_additional_info.csv`
- `10_num_contributors_loc.R`
                Using the data produced in “09_additonal_info.R”,
                this script sums the number of contributors and lines of code from the contribution information previously collected.
        - input: `~/oss/data/oss/working/pypi/10_github_api_info.csv`
        - input: `~/oss/data/oss/working/pypi/10_github_and_additional_info.csv`
        - output: `~/oss/data/oss/final/PyPI/complete_osi_info.csv`
- `first_try_pypi_scraping.R`
                Initial attempt to scrape pypi.
- `first_try_scraping_func.R`
                Another first attempt to scrape pypi.


# Running the code.gov analysis

The Data is collected from the API from the following script (you only want to run this once)

```bash
Rscript ./src/01-data_collection/scrape/code_gov/use_api/01-get_repos.R
```

### The data preparation

- Tag which repositories are OSI approved
- Domain of the repositoryURL

```bash
Rscript ./src/02-data_processing/code_gov/01-add_columns.R
```

### Exploratory reports

###### Repository domain counts

Looks at the repositoryURL, domains, and licesnses for code.gov.

```bash
Rscript -e "rmarkdown::render(here::here('./src/exploratory/code_gov/repository_domains.Rmd'), output_dir = here::here('./output/code_gov'))"
Rscript -e "bad_html <- './src/exploratory/code_gov/repository_domains.html'; if (file.exists(here::here(bad_html))) file.remove(here::here(bad_html))"
```

# Getting github information

