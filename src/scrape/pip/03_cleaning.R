library(stringr)
library(dplyr)
dataset <- read.csv("~/oss/data/oss/final/PyPI/pypi.csv")

pypi_data <- dataset[2:151 , 2:10]

pypi_data$license <- as.character(pypi_data$license)

for (i in 1:150) {
  pypi_data$license[i] <- as.character(strsplit(as.character(pypi_data$license), split = "(?=(?>\\s+\\S*){3}$)\\s", perl = TRUE)[[i]][2])
}

rownames(pypi_data) <- seq(length=nrow(pypi_data))


write.csv(pypi_data, '~/oss/data/oss/final/PyPI/clean_pypi.csv')
