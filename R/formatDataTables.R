# formatDataTables
# Grant Abernethy
# Date: 2023.01.26

# This is an R script for the Aurora application
# When data is imported into the app, this script changes the formatting of certain columns

#' Data formatting helpers for Aurora
#'
#' Utility functions used by the Aurora application to standardise column
#' formatting after data import. These functions convert character columns
#' originating from CSV or spreadsheet files into consistent numeric formats
#' and apply rounding where appropriate.
#'
#' @keywords internal
NULL

# Format data tables ====
#' Format imported Aurora data tables
#'
#' Takes a tibble or data frame that has been imported from a `.csv` or
#' spreadsheet file and standardises the formatting of selected columns.
#' Many Aurora datasets are imported with all columns as character values;
#' this function converts relevant fields to numeric values and applies
#' rounding to an appropriate number of decimal places.
#'
#' Because different Aurora tables contain different subsets of columns,
#' the function safely applies formatting using
#' `intersect(column_list, colnames(inp))`. This prevents errors when a
#' specified column is not present in the input data frame.
#'
#' This function is tailored to the schema used by the Aurora application
#' but can be adapted for other data frames with similar formatting needs.
#'
#' @param inp A tibble or data frame imported from `.csv` or spreadsheet
#' files. Columns are typically character type prior to formatting.
#'
#' @return The input tibble or data frame with numeric columns converted
#' and rounded as appropriate. Values are returned as character strings
#' after rounding to preserve formatting consistency across Aurora tables.
#'
#' @details
#' Columns are formatted according to predefined precision levels:
#'
#' * **1 decimal place** – sample dimensions, volumes, concentrations,
#'   sequencing metrics.
#' * **2 decimal places** – coordinates and spectrophotometer ratios.
#' * **6 decimal places** – latitude/longitude coordinates and selected
#'   quantitative PCR results.
#'
#' Latitude and longitude values are converted to numeric before rounding
#' so they can be used in mapping functions.
#'
#' @examples
#' # Example conversions
#' # inp$extract_conc_ng_ul_1 == "23.09" -> "23.1"
#' # inp$extract_A260_A280   == "1.93322" -> "1.93"
formatDataTables <- function(inp) {
  icols <- colnames(inp)

  inp <- inp %>%
    mutate(
      # Round these columns, if present, to 1 decimal place
      across(
        .cols = intersect(c(
          "sample_length",
          "sample_width",
          "sample_height",
          "sample_weight",
          "sample_volume",
          "depth1",
          "depth2",
          "altitude1",
          "altitude2",
          "elution_volume_ul",
          "extract_conc_ng_ul_1",
          "extract_conc_ng_ul_2",
          "pcr_conc_ng_ul_1",
          "pcr_conc_ng_ul_2",
          "library_volume_ul",
          "library_conc_ng_ul_1",
          "library_conc_ng_ul_2",
          "rr_gc_content",
          "rr_avg_quality",
          "as_depth",
          "as_depth_SD"
        ), icols),
        .fns = ~ as.character(round(as.numeric(.x), 1))
      ),
      # Round these columns, if present, to 2 decimal places
      across(
        .cols = intersect(c(
          "coord_x",
          "coord_y",
          "coord_z",
          "extract_A260_A230",
          "library_A260_A280",
          "library_A260_A230",
          "as_gc_content"
        ), icols),
        .fns = ~ as.character(round(as.numeric(.x), 2))
      ),
      # Round these columns, if present, to 6 decimal places
      across(
        .cols = intersect(c(
          "lat1",
          "long1",
          "lat2",
          "long2",
          "pcr_result_quant"
        ), icols),
        .fns = ~ as.character(round(as.numeric(.x), 6)) # lat and long need to be numeric for map plotting
      )
    )
  return(inp)
}