# filterfunctions.R
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-10-16
#
# Holds helper functions for the "Filter data" tab of the Aurora app.
# This version reuses generate_export_data() to ensure all joins and date fields
# are consistent with export outputs.

#  Generate full joined data frame ====
# This now simply wraps generate_export_data()
generate_report_data <- function() {
  generate_export_data()
}

# Get unique values for filtering ====
get_report_filter_choices <- function(df, column) {
  if (is.null(df) || !column %in% colnames(df)) {
    return(NULL)
  }
  choices <- sort(unique(df[[column]]))
  choices <- choices[!is.na(choices)]
  return(c("All", choices))
}

# Apply a filter to the report data ====
filter_report_data <- function(df, column, value) {
  if (is.null(df) || is.null(column) || is.null(value) || value == "All") {
    return(df)
  }
  df <- df[df[[column]] == value, ]
  df
}