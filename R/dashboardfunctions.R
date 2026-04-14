# dashboardfunctions.R
# Aurora App — Dashboard page helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06

#' Dashboard helper functions
#'
#' Internal helper functions used by the Aurora Dashboard page.
#' These functions prepare cumulative datasets, generate Plotly
#' visualisations, and create summary tables used throughout the
#' dashboard interface.
#'
#' @keywords internal
NULL

# Helper: Prepare cumulative counts for a given table and date column ====
# Used by dashboard and timeline pages
#' Prepare cumulative counts for a given table and date column
#'
#' Creates a cumulative count dataset based on a specified date column.
#' This helper is used to generate accumulation plots in both the
#' dashboard and timeline pages.
#'
#' @param data Data frame containing a `sample_accession` column and
#'   a date column.
#' @param date_col Character string specifying the name of the
#'   date column to use.
#'
#' @return A data frame ordered by date with cumulative counts in
#'   the `additive` column. Returns `NULL` if the input dataset is
#'   empty or missing.

prepare_cumulative_df <- function(data, date_col) {
  if (is.null(data) || nrow(data) == 0) {
    return(NULL)
  }

  data %>%
    select(sample_accession, !!rlang::sym(date_col)) %>%
    filter(!is.na(.data[[date_col]])) %>%
    mutate("{date_col}" := ymd(.data[[date_col]])) %>%
    arrange(.data[[date_col]]) %>%
    mutate(inx = 1, additive = cumsum(inx))
}

# Generate all dashboard datasets ====
#' Generate all dashboard datasets
#'
#' Builds cumulative datasets for each processing stage used in
#' the Aurora dashboard accumulation plots.
#'
#' @return Named list of cumulative data frames corresponding to
#' provenance, storage, extraction, PCR, library preparation,
#' and sequencing stages.

generate_dashboard_data <- function() {
  list(
    df1 = prepare_cumulative_df(table_SampleProvenance, "provenance_date"),
    df2 = prepare_cumulative_df(table_SampleStorage, "storage_date"),
    df3 = prepare_cumulative_df(table_Extraction, "extract_date"),
    df4 = prepare_cumulative_df(table_PCR, "pcr_date"),
    df5 = prepare_cumulative_df(table_LibraryPreparation, "library_date"),
    df6 = prepare_cumulative_df(table_Sequencing, "sequencing_date")
  )
}

# Generate Timeline Plotly object ====
#' Generate accumulation Plotly object
#'
#' Creates a Plotly scatter plot displaying cumulative sample
#' counts across Aurora processing stages.
#'
#' @param data_list List of cumulative datasets produced by
#'   `generate_dashboard_data()`.
#'
#' @return Plotly scatter plot object showing cumulative
#' inventory over time.

generate_accumulation_plot <- function(data_list) {
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

# Generate Tracker Plotly object ====
#' Generate tracker Plotly object
#'
#' Builds a Plotly scatter plot showing cumulative record counts
#' across all Aurora database tables through time.
#'
#' @param table_Tracker Data frame containing cumulative counts
#' for each database table and a `date` column.
#'
#' @return Plotly scatter plot object representing the tracker
#' dataset.

generate_tracker_plot <- function(table_Tracker) {
  plot_ly(
    data = table_Tracker,
    type = "scatter", mode = "markers",
    x = ~date
  ) %>%
    add_trace(y = ~sample.tracking, name = "SampleTracking") %>%
    add_trace(y = ~sample.classification, name = "SampleClassification") %>%
    add_trace(y = ~sample.provenance, name = "SampleProvenance") %>%
    add_trace(y = ~sample.storage, name = "SampleStorage") %>%
    add_trace(y = ~extraction, name = "Extraction") %>%
    add_trace(y = ~pcr, name = "PCR") %>%
    add_trace(y = ~library.preparation, name = "LibraryPreparation") %>%
    add_trace(y = ~sequencing, name = "Sequencing") %>%
    add_trace(y = ~publication, name = "Publication") %>%
    layout(
      xaxis = list(title = list(text = "Date")),
      yaxis = list(title = list(text = "Cumulative Number")),
      hoverlabel = list(font = list(size = 22))
    )
}

# Generate index purity table ====
#' Generate index purity table
#'
#' Creates a diagnostic table summarising index integrity across
#' Aurora database tables. The table reports total rows, missing
#' `sample_accession` values, and counts of unique accessions.
#'
#' @return Data frame summarising index integrity across database
#' tables.

generate_index_purity_table <- function() {
  a <- nrow(table_SampleTracking %>% filter(is.na(sample_accession)))
  b <- nrow(table_SampleClassification %>% filter(is.na(sample_accession)))
  c <- nrow(table_SampleDetail %>% filter(is.na(sample_accession)))
  d <- nrow(table_SampleProvenance %>% filter(is.na(sample_accession)))
  e <- nrow(table_SampleStorage %>% filter(is.na(sample_accession)))
  f <- nrow(table_Extraction %>% filter(is.na(sample_accession)))
  g <- nrow(table_PCR %>% filter(is.na(sample_accession)))
  h <- nrow(table_LibraryPreparation %>% filter(is.na(sample_accession)))
  i <- nrow(table_Sequencing %>% filter(is.na(sample_accession)))
  j <- nrow(table_Publication %>% filter(is.na(sample_accession)))

  k <- nrow(table_SampleTracking %>% select(sample_accession) %>% distinct())

  data.frame(
    index = c(
      "table_SampleTracking",
      "table_SampleClassification",
      "table_SampleDetail",
      "table_SampleProvenance",
      "table_SampleStorage",
      "table_Extraction",
      "table_PCR",
      "table_LibraryPreparation",
      "table_Sequencing",
      "table_Publication"
    ),
    total_rows = c(
      nrow(table_SampleTracking),
      nrow(table_SampleClassification),
      nrow(table_SampleDetail),
      nrow(table_SampleProvenance),
      nrow(table_SampleStorage),
      nrow(table_Extraction),
      nrow(table_PCR),
      nrow(table_LibraryPreparation),
      nrow(table_Sequencing),
      nrow(table_Publication)
    ),
    sample_accession_is_NA = c(a, b, c, d, e, f, g, h, i, j),
    uniques = c(k, rep(NA, 9))
  ) %>%
    mutate(
      non_unique = total_rows - uniques
    )
}