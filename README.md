# Measuring the Cost and Value of Open Source Software (OSS)

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
