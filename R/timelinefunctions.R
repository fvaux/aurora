# timelinefunctions.R
# Aurora App — Timeline tab helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-10-17

#' Timeline helper functions
#'
#' Internal helper functions used by the Timeline tab of the Aurora Shiny app.
#'
#' These functions generate timeline datasets and Plotly visualisations.
#'
#' @keywords internal
NULL


# Generate all timeline datasets ====
#' Generate all timeline datasets
#'
#' Builds cumulative timeline datasets for each Aurora processing stage.
#'
#' @param report_data Data frame containing sample metadata and processing dates.
#'
#' @return Named list of cumulative data frames used by the timeline dashboard.

generate_timeline_dashboard_data <- function(report_data) {
  # Expect report_data to contain the relevant tables used throughout your app
  list(
    df1 = prepare_cumulative_df(report_data, "provenance_date"),
    df2 = prepare_cumulative_df(report_data, "storage_date"),
    df3 = prepare_cumulative_df(report_data, "extract_date"),
    df4 = prepare_cumulative_df(report_data, "pcr_date"),
    df5 = prepare_cumulative_df(report_data, "library_date"),
    df6 = prepare_cumulative_df(report_data, "sequencing_date")
  )
}

# Generate timeline accumulation plot Plotly object ====
#' Generate timeline accumulation plot
#'
#' Creates a Plotly scatter plot showing cumulative sample counts
#' for each processing stage.
#'
#' @param data_list List of cumulative datasets produced by
#'   `generate_timeline_dashboard_data()`.
#'
#' @return Plotly scatter plot object.

generate_timeline_accumulation_plot <- function(data_list) {
  plot_ly(type = "scatter", mode = "markers", marker = list(size = 14)) %>%
    add_trace(data = data_list$df1, x = ~provenance_date, y = ~additive, name = "Provenance") %>%
    add_trace(data = data_list$df2, x = ~storage_date, y = ~additive, name = "Sample Storage") %>%
    add_trace(data = data_list$df3, x = ~extract_date, y = ~additive, name = "Extract") %>%
    add_trace(data = data_list$df4, x = ~pcr_date, y = ~additive, name = "PCR") %>%
    add_trace(data = data_list$df5, x = ~library_date, y = ~additive, name = "Library Preparation") %>%
    add_trace(data = data_list$df6, x = ~sequencing_date, y = ~additive, name = "Sequencing") %>%
    layout(
      xaxis = list(title = list(text = "Date")),
      yaxis = list(title = list(text = "Cumulative Inventory")),
      hoverlabel = list(font = list(size = 22))
    )
}

# Generate per-sample processing timeline datasets ====
#' Generate per-sample processing timeline dataset
#'
#' Converts wide-format processing dates into long format for
#' per-sample timeline visualisation.
#'
#' @param report_data Data frame containing sample metadata and
#'   processing date columns.
#'
#' @return Long-format data frame with sample, stage, and date columns.

generate_timeline_process_data <- function(report_data) {
  # Select the key date columns, keeping only non-empty ones
  date_cols <- c(
    "provenance_date",
    "storage_date",
    "extract_date",
    "pcr_date",
    "library_date",
    "sequencing_date"
  )
  valid_cols <- date_cols[date_cols %in% names(report_data)]

  df <- report_data %>%
    select(sample_accession, all_of(valid_cols)) %>%
    tidyr::pivot_longer(
      cols = all_of(valid_cols),
      names_to = "stage",
      values_to = "date"
    ) %>%
    filter(!is.na(date)) %>%
    mutate(date = lubridate::ymd(date))

  df
}

# Generate sample processing timeline plot ====
#' Generate sample processing timeline plot
#'
#' Creates a Plotly plot showing the processing timeline
#' for each individual sample.
#'
#' @param process_data Long-format dataset produced by
#'   `generate_timeline_process_data()`.
#'
#' @return Plotly scatter plot. Returns `NULL` if no data exist.
# Generate sample processing timeline plot

generate_timeline_process_plot <- function(process_data) {
  if (nrow(process_data) == 0) {
    return(NULL)
  }

  plot_ly(process_data,
    x = ~date,
    y = ~sample_accession,
    color = ~stage,
    type = "scatter",
    mode = "markers",
    marker = list(size = 10)
  ) %>%
    layout(
      xaxis = list(title = "Date"),
      yaxis = list(
        title = "Sample", categoryorder = "array",
        categoryarray = sort(unique(process_data$sample_accession))
      ),
      hoverlabel = list(font = list(size = 22)),
      legend = list(title = list(text = "Processing Stage"))
    )
}