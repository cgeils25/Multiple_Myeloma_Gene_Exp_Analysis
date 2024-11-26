library(GEOquery)
library(R.utils)

data_dir = 'data/'

if (!file.exists(data_dir)) 
{
  dir.create(data_dir)
}

if (!file.exists('data/GDS5826.soft')) 
{
    gse_path = getGEOfile(GEO = "GDS5826", destdir = data_dir, amount = "data")

    gunzip(gse_path)
}
else {
    gse = getGEO(filename = 'data/GDS5826.soft')
}


# not used but this is how you get the metadata
metadata = Meta(gse)

# extract expression count data as R data frame
data = as.data.frame(Table(gse))

# save expression count data
write.csv(data, 'data/GDS5826.csv', row.names = FALSE)
