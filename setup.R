options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages('renv')
renv::init(bioconductor = TRUE)

renv::install('pathfindR')
renv::install('ggplot2')
renv::install("GEOquery")
renv::install("DESeq2")
renv::install("shiny")

renv::snapshot()
