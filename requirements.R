required_packages <- c(
  "tidyverse", "janitor", "skimr", "broom", "knitr", "rmarkdown"
)

install.packages(setdiff(required_packages, rownames(installed.packages())))

