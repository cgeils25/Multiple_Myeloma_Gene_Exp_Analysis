options(repos = c(CRAN = "https://cloud.r-project.org"))

install.packages("renv")
renv::init(bioconductor = TRUE)

renv::install("ggplot2")
renv::install("GEOquery")
renv::install("shiny")
renv::install("plotly")
renv::install("reshape2")
renv::install("ComplexHeatmap")

renv::snapshot()
