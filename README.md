# Multiple Myeloma Gene Expression Analysis
Hello! For my final project in my Data Visualization class, I built a shiny app to visualize gene expression data for multiple myeloma cells resistant to the chemotherapeutic agent carfilzomib. I obtained this data from the gene expression omnibus (GEO). The data gives log-fold expression changes over the course of a 1 week period while deprived of carfolzomib.

Some of my findings for this analysis include:

  - 2 distinct clusters of samples based on a heirarchical clustering
  - an approximately normal distribution of gene expression changes about mean 0
  - A marked increase in expression of the gene MGST1 or microsomal glutathione S-transferase 1, which is associated with inflammation. This suggests that inflammatory response is associated with resistance to Carfilzomib, and could be targeted.

## Setup

To create an renv virtual environment with the necessary packages, run:

```bash
R -f setup.R
```

Next, download the associated dataset with:

```bash
R -f get_data.R
```

Finally, launch the Shiny app with:

```bash
R -f app.R
```
