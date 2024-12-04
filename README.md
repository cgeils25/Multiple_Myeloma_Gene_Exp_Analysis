## Setup

To create an renv virtual environment with the necessary packages, run:

```bash
R -f setup.R
```

Note: for the R package pathfindR to work, you need to have Java >= 8.0 installed and the path to it must be in the PATH environment variable.

[Java for Mac](https://www.java.com/en/download/)
[Java for Windows](https://www.java.com/download/ie_manual.jsp)


Next, download the associated dataset with:

```bash
R -f get_data.R
```

Finally, launch the Shiny app with:

```bash
R -f app.R
```
