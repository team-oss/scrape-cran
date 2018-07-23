file_names_list <- read.csv("~/oss/data/oss/final/PyPI/names_prod_mature_osi_approved.csv")
file_names_list <- as.vector(file_names_list$x)
dependencies <- setNames(data.frame(matrix(ncol = 2, nrow = 1)), c("package_name", "dependency_name"))
pos <- 1

for (i in 1:length(file_names_list))
{
  result <- try(file(paste("~/oss/data/oss/working/pypi/", file_names_list[i], ".txt", sep = ""), open = "r"), silent = TRUE)
  close(file(paste("~/oss/data/oss/working/pypi/", file_names_list[i], ".txt", sep = ""), open = "r"))
  if (class(result)[1] == "try-error")
  {
    dependencies$package_name[pos] <- file_names_list[i]
    pos <- pos + 1
    dependencies[pos,] <- NA
    next()
  }

  open_file <- file(paste("~/oss/data/oss/working/pypi/", file_names_list[i], ".txt", sep = ""), open = "r")
  file_lines <-readLines(open_file)
  file_table <- as.data.frame(file_lines)
  file_table$file_lines <- as.character(file_table$file_lines)
  close(open_file)

  if (nrow(file_table) >= 4)
  {
    for (a in 4:nrow(file_table))
    {
      if (!grepl("│   ", file_table$file_lines[a]) && !grepl("    ├", file_table$file_lines[a]) && !grepl("    └", file_table$file_lines[a]))
      {
        dependencies$package_name[pos] <- file_names_list[i]
        if (grepl("└── ", file_table$file_lines[a])) {
          dep <- strsplit(file_table$file_lines[a], "└── ")[[1]][2]
          if (grepl("<", dep))
          {
            dependencies$dependency_name[pos] <- strsplit(dep, "<")[[1]][1]
          } else if (grepl(">", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, ">")[[1]][1]
          } else if (grepl("=", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, "=")[[1]][1]
          } else if (grepl("~", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, "~")[[1]][1]
          } else {
            dependencies$dependency_name[pos] <- strsplit(dep, " ")[[1]][1]
          }
        } else if (grepl("├── ", file_table$file_lines[a])) {
          dep <- strsplit(file_table$file_lines[a], "├── ")[[1]][2]
          if (grepl("<", dep))
          {
            dependencies$dependency_name[pos] <- strsplit(dep, "<")[[1]][1]
          } else if (grepl(">", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, ">")[[1]][1]
          } else if (grepl("=", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, "=")[[1]][1]
          } else if (grepl("~", dep)) {
            dependencies$dependency_name[pos] <- strsplit(dep, "~")[[1]][1]
          } else {
            dependencies$dependency_name[pos] <- strsplit(dep, " ")[[1]][1]
          }
        }
        pos <- pos + 1
        dependencies[pos,] <- NA
      }
    }
  } else {
    dependencies$package_name[pos] <- file_names_list[i]
    dependencies$dependency_name[pos] <- NA
    pos <- pos + 1
    dependencies[pos,] <- NA
  }
}


write.csv(dependencies, "~/oss/data/oss/final/PyPI/01_dependencies.csv")





