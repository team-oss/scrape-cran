# Measuring the Cost and Value of Open Source Software (OSS)

1. Get a github personal access token from: https://github.com/settings/tokens
2. Setup your `.Renviron` file (to make it easier run: `usethis::edit_r_environ()`)
  - add a like this to the file: `GH_TOSS_TOKEN='YOUR_TOKEN'`
  - You can use `GH_TOSS_TOKEN='1c06459fc9b515e2a5aa748b06913f3495068a45'`, but may not work since its not your own token.

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

### Getting github information

