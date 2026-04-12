# updateDate
# Grant Abernethy
# Date: 2024.09.29

# This is an R script for the Aurora application
# It allows the app to process dates from separate year, month and day columns

#' Date handling utilities for Aurora
#'
#' Helper functions used by the Aurora application to construct and update
#' date fields derived from separate year, month, and day columns stored in
#' Aurora database tables.
#'
#' These utilities ensure that consistent `YYYY-MM-DD` formatted dates are
#' available for downstream plotting, filtering, and export tasks.
#'
#' @keywords internal
NULL

# getDate ====
#' getDate
#' Construct a date from year, month, and day vectors
#'
#' Converts three vectors representing year, month, and day into a single
#' vector of dates formatted as `"YYYY-MM-DD"`. The function is designed
#' for Aurora datasets where date components are stored in separate columns.
#'
#' Invalid or incomplete dates are safely handled. If a constructed date
#' cannot be parsed, the function replaces the value with **January 1st of
#' the current year** to ensure downstream processes do not fail.
#'
#' @param y Numeric vector representing the year (`YYYY`).
#' @param m Numeric vector representing the month (`1–12`).
#' @param d Numeric vector representing the day (`1–31`).
#'
#' @return Character vector of dates in `"YYYY-MM-DD"` format.
#'
#' @details
#' The function first constructs a character representation of the date,
#' then parses it using `lubridate::ymd()`. Parsing warnings are suppressed
#' to allow invalid combinations (e.g., 31 February) to be handled gracefully.
#'
#' Any `NA` values resulting from invalid date construction are replaced
#' with the first day of the current year.
#'
#' @examples
#' getDate(sample_year, sample_month, sample_day)
#' getDate(2024, 9, 29)
#'
#' @export

getDate <- function(y = lubridate::year(lubridate::today()), m = 1, d = 1) { # If no variable, use current year and 1st January (as needed)
  charDate <- paste0(y, "-", m, "-", d) # Converts numbers to text
  suppressWarnings(out <- lubridate::ymd(charDate, truncated = 2)) # Converting to YYYY-MM-DD format
  out <- replace_na(out, lubridate::ymd(paste0(y = lubridate::year(lubridate::today()), "-01-01"))) # If 'out' is NA (e.g., invalid date input), replace it with 1st January of the current year
  out <- as.character(out)
  return(out)
}

# updateDate ====
#' Update derived date columns in Aurora tables
#'
#' Rebuilds formatted date columns for multiple Aurora database tables using
#' their associated year, month, and day component columns. The function
#' overwrites the existing tables in the global environment with updated
#' versions containing recalculated date fields.
#'
#' This function is typically executed when the Aurora application launches
#' or when the underlying datasets are fully reloaded.
#'
#' ⚠️ If new date fields are added to Aurora tables, they must be included
#' manually in this function following the same pattern used for existing
#' tables.
#'
#' @return No value is returned. The function operates via **side effects**
#' by modifying Aurora data tables in the global environment.
#'
#' @details
#' The following tables are updated:
#'
#' * `table_SampleProvenance`
#' * `table_SampleStorage`
#' * `table_Extraction`
#' * `table_PCR`
#' * `table_LibraryPreparation`
#' * `table_Sequencing`
#'
#' Each table receives a derived `*_date` column generated from the
#' corresponding `*_year`, `*_month`, and `*_day` columns.
#'
#' @examples
#' updateDate()
#'
#' @export

updateDate <- function() {
  x <- table_SampleProvenance %>%
    mutate(provenance_date = getDate(sample_year, sample_month, sample_day)) %>%
    select(1, provenance_date, setdiff(names(.), c("sample_year", "sample_month", "sample_day")), sample_year, sample_month, sample_day)
  assign("table_SampleProvenance", x, envir = .GlobalEnv)

  x <- table_SampleStorage %>%
    mutate(storage_date = getDate(storage_year, storage_month, storage_day)) %>%
    select(1, storage_date, setdiff(names(.), c("storage_year", "storage_month", "storage_day")), storage_year, storage_month, storage_day)
  assign("table_SampleStorage", x, envir = .GlobalEnv)

  x <- table_Extraction %>%
    mutate(extract_date = getDate(extract_year, extract_month, extract_day)) %>%
    select(1, 2, extract_date, setdiff(names(.), c("extract_year", "extract_month", "extract_day")), extract_year, extract_month, extract_day)
  assign("table_Extraction", x, envir = .GlobalEnv)

  x <- table_PCR %>%
    mutate(pcr_date = getDate(pcr_year, pcr_month, pcr_day)) %>%
    select(1, 2, 3, pcr_date, setdiff(names(.), c("pcr_year", "pcr_month", "pcr_day")), pcr_year, pcr_month, pcr_day)
  assign("table_PCR", x, envir = .GlobalEnv)

  x <- table_LibraryPreparation %>%
    mutate(library_date = getDate(library_year, library_month, library_day)) %>%
    select(1, 2, 3, library_date, setdiff(names(.), c("library_year", "library_month", "library_day")), library_year, library_month, library_day)
  assign("table_LibraryPreparation", x, envir = .GlobalEnv)

  x <- table_Sequencing %>%
    mutate(sequencing_date = getDate(sequencing_year, sequencing_month, sequencing_day)) %>%
    select(1, 2, sequencing_date, setdiff(names(.), c("sequencing_year", "sequencing_month", "sequencing_day")), sequencing_year, sequencing_month, sequencing_day)
  assign("table_Sequencing", x, envir = .GlobalEnv)
}

# Note for methods testing: there are 92 Example Data entries with missing values for year, month or day in table_SampleProvenance
