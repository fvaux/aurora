# diversityfunctions.R
# Aurora App — Diversity tab helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06

#' Diversity helper functions
#'
#' Internal helper functions used by the Diversity tab of the Aurora Shiny app.
#'
#' These functions help to track and evaluate the taxonomic diversity of samples.
#'
#' @keywords internal
NULL

# Generate diversity summary table ====
#' Generate Diversity Summary Table
#'
#' Creates a summary table counting the number of samples for each
#' combination of two categorical variables (typically taxonomic
#' levels or project groupings).
#'
#' Missing or blank values in the selected columns are replaced with
#' `"Unassigned"` so that incomplete classifications are still counted.
#'
#' @param data A data frame containing sample metadata.
#' @param x_col Character string specifying the column to use as the
#' primary grouping variable (e.g., taxonomic level).
#' @param color_col Character string specifying the column used as a
#' secondary grouping variable.
#'
#' @return A data frame summarising sample counts for each combination
#' of the selected columns.
#'
#' @details
#' The function checks whether the requested columns exist in the
#' provided dataset. If not, a warning is produced and `NULL` is returned.
#'
#' @export
#'
#' @examples
#' generate_diversity_summary(
#'   data = report_data,
#'   x_col = "species_binomial",
#'   color_col = "project"
#' )
generate_diversity_summary <- function(data, x_col, color_col) {
  if (is.null(data)) {
    return(NULL)
  }
  if (!all(c(x_col, color_col) %in% names(data))) {
    warning("Selected taxonomic level not found in data")
    return(NULL)
  }

  # Replace missing/blank values with "Unassigned"
  data[[x_col]] <- ifelse(is.na(data[[x_col]]) | data[[x_col]] == "", "Unassigned", data[[x_col]])
  data[[color_col]] <- ifelse(is.na(data[[color_col]]) | data[[color_col]] == "", "Unassigned", data[[color_col]])

  # Count samples per combination
  data %>%
    group_by(.data[[x_col]], .data[[color_col]]) %>%
    summarise(Sample_Count = n(), .groups = "drop") %>%
    arrange(desc(Sample_Count))
}


# Generate diversity histogram (stacked) ====
#' Generate Diversity Histogram
#'
#' Creates a stacked bar chart showing the number of samples for each
#' category of a selected variable, coloured by a secondary grouping
#' variable. The output is an interactive Plotly histogram.
#'
#' Missing or blank values in the selected columns are replaced with
#' `"Unassigned"` so that incomplete classifications remain visible.
#'
#' @param data A data frame containing sample metadata.
#' @param x_col Character string specifying the column used on the x-axis
#' (e.g., species, genus, or family).
#' @param color_col Character string specifying the column used for
#' colour grouping in the stacked bars.
#'
#' @return A Plotly stacked bar chart object.
#'
#' @details
#' This function aggregates counts for each combination of the selected
#' variables and then visualises them using a stacked bar chart.
#'
#' If either column is missing from the dataset, the function returns `NULL`.
#'
#' @export
#'
#' @examples
#' generate_diversity_histogram(
#'   data = report_data,
#'   x_col = "species_binomial",
#'   color_col = "project"
#' )
generate_diversity_histogram <- function(data, x_col, color_col) {
  if (is.null(data)) {
    return(NULL)
  }
  if (!all(c(x_col, color_col) %in% names(data))) {
    return(NULL)
  }

  # Replace missing/blank values with "Unassigned"
  data[[x_col]] <- ifelse(is.na(data[[x_col]]) | data[[x_col]] == "", "Unassigned", data[[x_col]])
  data[[color_col]] <- ifelse(is.na(data[[color_col]]) | data[[color_col]] == "", "Unassigned", data[[color_col]])

  # Summarise counts
  summary_data <- data %>%
    dplyr::count(.data[[x_col]], .data[[color_col]])

  # Build stacked histogram
  plt <- plotly::plot_ly(
    data = summary_data,
    x = ~ .data[[x_col]],
    y = ~n,
    color = ~ .data[[color_col]],
    type = "bar"
  ) %>%
    plotly::layout(
      barmode = "stack",
      title = paste("Samples by", x_col, "and", color_col),
      xaxis = list(title = x_col),
      yaxis = list(title = "Sample count")
    )

  return(plt)
}
