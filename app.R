library(shiny)
library(bslib)
library(ggplot2)
library(plotly)
library(reshape2)
library(ComplexHeatmap)

data_path <- "data/GDS5826.csv"

df <- read.csv(data_path)

column_names <- colnames(df)

gene_labels <- column_names[1:2]

sample_names <- column_names[3:length(column_names)]

ui <- fluidPage(
  theme = bslib::bs_theme(version = 4, bootswatch = "minty"),
  titlePanel(
    "Gene Expression Data for Multiple Myeloma Cell Lines With Acquired 
    Resistance to Chemotherapeutic Agent Carfilzomib"
  ),
  sidebarLayout(
    sidebarPanel(
      h3('Choose Sample(s) to Visualize'),
      # choose which samples to display
      checkboxGroupInput(
        inputId = "samples",
        label = "Available Samples",
        choices = sample_names,
        selected = sample_names
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Data and Project Description", 
          textOutput("data_and_project_description")
        ),
        tabPanel("Raw Data", tableOutput("raw_data")),
        tabPanel("Gene Expression Histogram", plotlyOutput("gene_exp_hist")),
        tabPanel(
          "Most and Least Altered Gene Expression", 
          numericInput("num_to_show", "Number of Genes to Show (for both increase & decrease)", 10),
          plotlyOutput("altered_gene_exp")
        ),
        tabPanel("Sample Correlation Heatmap", plotOutput("sample_corr_heatmap"))
      )
    )
  )
)

server <- function(input, output) {

  rv <- reactiveValues()

  observe({
    # only include the gene labels and the selected samples
    rv$data <- df[, c(gene_labels, input$samples)]
    rv$samples <- input$samples
  })

  output$data_and_project_description <- renderText({
    paste(
      "This dataset contains gene expression data for multiple myeloma cell lines with acquired resistance to the chemotherapeutic agent carfilzomib.\n
      
      The data was obtained from the Gene Expression Omnibus (GEO) database, with the accession number GDS5826.\n
      
      There are 12 human samples in total.\n
      
      The expression data is represented as fold changes from the baseline expression level, over the course of 14 days without the presence of carfilzomib.\n\n

      The main motivation behind this analysis is to identify genes that are associated with acquired resistance to carfilzomib in multiple myeloma cell lines. If this can 
      be done successfully, thene these genes could be targeted for treatment. \n
      
      You can explore the data by selecting the samples you want to visualize in the sidebar.\n\n

      Finally, there are four tabs available to explore the data:
      1. Raw Data: Displays the first 10 genes and their corresponding fold-changes of the selected samples.\n
      2. Gene Expression Histogram: Shows distribution of gene expression change for the selected samples.\n
      3. Most and Least Altered Gene Expression: Displays the genes with the greatest increase and decrease in expression from the baseline. Optionally, you can specify the number of genes to show.\n
      4. Sample Correlation Heatmap: Shows the correlation between gene expression changes in the selected samples.\n
      "
    )
  })

  output$raw_data <- renderTable({
    return(head(rv$data[, c(gene_labels, input$samples)], 10))
  })

  output$gene_exp_hist <- renderPlotly({
    # flatten fold change values in dataframe into a single vector
    if (length(input$samples) == 0) {
      return (NULL)
    }
    else if (length(input$samples) == 1) {
      fold_chng_flat <- rv$data[,input$samples]

      sample_names_flat <- rep(input$samples, length(fold_chng_flat))

      df_fold_chng <- data.frame(fold_change = fold_chng_flat, sample_names = sample_names_flat)
    } else {
    fold_chng_flat <- do.call("c", rv$data[,input$samples])

    # get length of vector for each sample
    len_vec <- sapply(rv$data[,input$samples], length)

    # create a vector of sample names that is the same length as fold_chng_flat
    sample_names_flat <- rep(input$samples, len_vec)

    # create a dataframe with the flattened fold change values and sample names
    df_fold_chng <- data.frame(fold_change = fold_chng_flat, sample_names = sample_names_flat)
    }

    # make a histogram of gene expression for all samples
    plot = ggplot(data = df_fold_chng, mapping = aes(x = fold_change, color = sample_names)) + 
      geom_histogram(binwidth = .1) +
      ggtitle('Distribution of Gene Expression Change for Different Samples') +
      labs(x = "Factor of Expression Change from Baseline", y = "Frequency", color = "Sample Name")

    return(plotly::ggplotly(plot))

  })

  output$altered_gene_exp <- renderPlotly({
    num_to_show = input$num_to_show

    # take the mean over each row
    fold_change_means <- apply(df[, input$samples], 1, mean)

    # argsort the fold changes
    sorted_fold_changes_idx <- order(fold_change_means, decreasing = TRUE)

    sorted_fold_changes <- fold_change_means[sorted_fold_changes_idx]

    # safety check
    all(sort(fold_change_means, decreasing = TRUE) == fold_change_means[sorted_fold_changes_idx])

    # get the top num_to_show genes
    top_genes <- df$IDENTIFIER[sorted_fold_changes_idx[1:num_to_show]]
    top_genes_fold_changes <- sorted_fold_changes[1:num_to_show]

    # get the bottom num_to_show genes
    bottom_genes <- df$IDENTIFIER[sorted_fold_changes_idx[(length(sorted_fold_changes_idx) - num_to_show + 1):length(sorted_fold_changes_idx)]]
    bottom_genes_fold_changes <- sorted_fold_changes[(length(sorted_fold_changes_idx) - num_to_show + 1):length(sorted_fold_changes_idx)]

    # a bar plot of the top and bottom genes
    top_bottom_genes <- data.frame(
      gene = c(top_genes, bottom_genes),
      fold_change = c(top_genes_fold_changes, bottom_genes_fold_changes),
      top_bottom = c(rep("greatest increase", num_to_show), rep("greatest decrease", num_to_show))
    )

    p = ggplot(data = top_bottom_genes, aes(x = gene, y = fold_change, fill = top_bottom)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
      ggtitle('Most Altered Gene Expressions from Baseline') +
      labs(x = "Gene Name", y = "Factor of Expression Change from Baseline")

    return(p)
  })

  output$sample_corr_heatmap <- renderPlot({
    # calculate correlation matrix
    correlation_matrix <- cor(df[, input$samples])

    # plot the correlation matrix
    p <- Heatmap(correlation_matrix, show_row_names = TRUE, show_column_names = TRUE)

    return(p)
  })
}

shinyApp(ui, server, options = list(launch.browser = TRUE, port=9999))
