# samplevarfunctions.R
# Aurora App — Sample variation page helper functions
# Felix Zareie-Vaux
# Date: 2026-08-18

#' Sample variation helper functions
#'
#' Internal helper functions used by the Sample variation page of the Aurora
#' Shiny app. These functions prepare sample-level data, generate summary
#' tables, and create interactive Plotly figures.
#'
#' @keywords internal
NULL

# Prepare sample variation data ====
#' Prepare Sample Variation Data
#'
#' Selects sample-level fields used by the Sample variation page and removes
#' exact duplicate rows that can arise when the joined report dataset contains
#' multiple downstream records for the same sample.
#'
#' @param data A data frame containing Aurora report data.
#'
#' @return A data frame containing sample-level variation fields.
#'
#' @export
prepare_sample_variation_data <- function(data) {
  required_cols <- c(
    "sample_accession", "sample_type", "sex", "developmental_stage",
    "sample_length", "sample_weight"
  )
  
  # Return an empty correctly structured table if no data are available
  if (is.null(data) || nrow(data) == 0) {
    return(tibble::tibble(
      sample_accession = character(),
      sample_type = character(),
      sex = character(),
      developmental_stage = character(),
      sample_length = numeric(),
      sample_weight = numeric()
    ))
  }
  
  # Add missing optional columns so customised Aurora versions fail gracefully
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    for (col in missing_cols) {
      data[[col]] <- NA
    }
  }
  
  data %>%
    select(all_of(required_cols)) %>%
    distinct()
}

# Generate categorical summary table ====
#' Generate Sample Variation Summary
#'
#' Counts unique sample records by a categorical sample characteristic.
#' Missing or blank values are omitted. If no usable values are present,
#' an empty summary table is returned.
#'
#' @param data A data frame produced by prepare_sample_variation_data().
#' @param column Character string naming the categorical column to summarise.
#'
#' @return A data frame containing the category and Sample_Count.
#'
#' @export
generate_sample_variation_summary <- function(data, column) {
  if (is.null(data) || !column %in% names(data)) {
    return(NULL)
  }
  
  summary_data <- data %>%
    mutate(
      !!sym(column) := as.character(.data[[column]])
    ) %>%
    filter(
      !is.na(.data[[column]]),
      trimws(.data[[column]]) != ""
    ) %>%
    count(.data[[column]], name = "Sample_Count") %>%
    arrange(desc(Sample_Count), .data[[column]])
  
  summary_data
}

# Generate categorical histogram ====
#' Generate Sample Variation Histogram
#'
#' Creates an interactive Plotly bar chart showing sample counts for a
#' categorical sample characteristic. If no usable values are present,
#' an empty Plotly panel is returned.
#'
#' @param summary_data A summary table produced by generate_sample_variation_summary().
#' @param x_col Character string naming the category column.
#' @param x_title X-axis title.
#' @param title Optional plot title.
#'
#' @return A Plotly bar chart object.
#'
#' @export
generate_sample_variation_histogram <- function(summary_data, x_col, x_title, title = NULL) {
  if (is.null(summary_data) || nrow(summary_data) == 0) {
    return(
      plotly::plot_ly() %>%
        plotly::layout(
          title = title,
          xaxis = list(title = x_title),
          yaxis = list(title = "Sample count")
        )
    )
  }
  
  plotly::plot_ly(
    data = summary_data,
    x = ~ .data[[x_col]],
    y = ~Sample_Count,
    type = "bar",
    hovertemplate = paste0(
      x_title, ": %{x}<br>",
      "Sample count: %{y}<extra></extra>"
    )
  ) %>%
    plotly::layout(
      title = title,
      xaxis = list(title = x_title, automargin = TRUE),
      yaxis = list(title = "Sample count", rangemode = "tozero"),
      margin = list(b = 100)
    )
}

# Generate body-size table ====
#' Generate Body Size Data
#'
#' Prepares sample length and weight values for the body-size scatter plot.
#' Rows lacking either measurement are removed. If no complete measurements
#' are present, an empty table is returned.
#'
#' @param data A data frame produced by prepare_sample_variation_data().
#'
#' @return A data frame containing sample accession, sample length and sample
#' weight.
#'
#' @export
generate_body_size_data <- function(data) {
  if (is.null(data) || nrow(data) == 0) {
    return(tibble::tibble(
      sample_accession = character(),
      sample_length = numeric(),
      sample_weight = numeric()
    ))
  }
  
  data %>%
    transmute(
      sample_accession,
      sample_length = suppressWarnings(as.numeric(sample_length)),
      sample_weight = suppressWarnings(as.numeric(sample_weight))
    ) %>%
    filter(!is.na(sample_length) & !is.na(sample_weight)) %>%
    distinct()
}

# Generate body-size scatter plot ====
#' Generate Body Size Scatter Plot
#'
#' Creates an interactive Plotly scatter plot with sample length on the X axis
#' and sample weight on the Y axis. If no paired measurements are present,
#' an empty Plotly panel is returned.
#'
#' @param body_size_data A data frame produced by generate_body_size_data().
#'
#' @return A Plotly scatter plot object.
#'
#' @export
generate_body_size_scatter <- function(body_size_data) {
  if (is.null(body_size_data) || nrow(body_size_data) == 0) {
    return(
      plotly::plot_ly() %>%
        plotly::layout(
          xaxis = list(title = "Sample length"),
          yaxis = list(title = "Sample weight")
        )
    )
  }
  
  hover_text <- paste0(
    "Sample: ", body_size_data$sample_accession,
    "<br>Length: ", body_size_data$sample_length,
    "<br>Weight: ", body_size_data$sample_weight
  )
  
  plotly::plot_ly(
    data = body_size_data,
    x = ~sample_length,
    y = ~sample_weight,
    type = "scatter",
    mode = "markers",
    text = hover_text,
    hoverinfo = "text"
  ) %>%
    plotly::layout(
      xaxis = list(title = "Sample length", rangemode = "tozero"),
      yaxis = list(title = "Sample weight", rangemode = "tozero")
    )
}
