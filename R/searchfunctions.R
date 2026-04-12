# searchfunctions.R
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06
#
# This is an R script for the Aurora application
# It contains helper functions used by the search interface to build
# combined data tables and determine available column selections.


# Build a search results table
# search_tables: vector of table names from constants$table_names
# table_mapping: named vector mapping friendly names -> object names in global env
# select_cols: vector of column names to select
# special_need: NULL or name of a preset search need
# constants: global constants list

#' Build Search Results Table
#'
#' Creates a combined search results table by joining one or more Aurora
#' data tables based on the `sample_accession` column. The resulting table
#' can then be filtered to include a subset of columns defined by either
#' user selection or predefined search configurations.
#'
#' @param search_tables Character vector specifying the tables to include
#' in the search. Values typically correspond to entries in
#' `constants$table_names`.
#' @param table_mapping Named vector mapping friendly table names to
#' the corresponding object names stored in the global environment.
#' @param select_cols Optional character vector specifying columns to
#' include in the output table.
#' @param special_need Optional character string identifying a predefined
#' column selection stored in `constants$sp_needs`.
#' @param constants List containing global configuration objects used
#' by the Aurora application.
#'
#' @return A data frame containing the combined search results.
#'
#' @details
#' The function loads the selected tables from the global environment
#' and joins them sequentially using `sample_accession` as the key.
#'
#' If `special_need` is provided, the column selection is taken from the
#' predefined configuration in `constants$sp_needs`. Otherwise, the
#' columns specified in `select_cols` are used. If neither option is
#' provided, all columns from the joined tables are retained.
#'
#' The resulting table is also assigned to the global environment as
#' `search_table` for use elsewhere in the Aurora application.
#'
#' @examples
#' report_cols(
#'   search_tables = c("SampleProvenance", "SampleClassification"),
#'   table_mapping = table_mapping,
#'   select_cols = c("sample_accession", "species_binomial"),
#'   constants = constants
#' )
report_cols <- function(search_tables, table_mapping, select_cols = NULL,
                        special_need = NULL, constants) {
  len <- length(search_tables)
  if (len == 0) {
    return(NULL)
  }
  
  # Start with the first table
  tb <- get(table_mapping[search_tables[1]], envir = .GlobalEnv)
  
  # Join any others
  if (len > 1) {
    for (i in search_tables[2:len]) {
      tb <- left_join(tb,
                      get(table_mapping[i], envir = .GlobalEnv),
                      by = "sample_accession"
      )
    }
  }
  
  # Column selection
  if (!is.null(special_need)) {
    tb <- tb %>% select(any_of(get(constants$sp_needs[special_need], envir = .GlobalEnv)))
  } else if (!is.null(select_cols)) {
    tb <- tb %>% select(any_of(select_cols))
  }
  
  assign("search_table", tb, envir = .GlobalEnv)
  tb
}


# Determine available/default columns based on selected tables
# constants: global constants list

#' Determine Column Choices for Search Interface
#'
#' Determines which columns are available and which columns should be
#' selected by default when building a search table from one or more
#' Aurora data tables.
#'
#' @param search_tables Character vector specifying the tables selected
#' by the user.
#' @param constants List containing configuration objects including
#' column definitions (`tab.cols`) and default column selections
#' (`default.cols`).
#'
#' @return A list containing two elements:
#' \describe{
#'   \item{all}{Character vector of all available columns across the
#'   selected tables}
#'   \item{default}{Character vector of default columns to display}
#' }
#'
#' @details
#' The function aggregates column definitions across the selected tables
#' using the metadata stored in `constants$tab.cols` and
#' `constants$default.cols`.
#'
#' If no tables are selected, the function returns placeholder empty
#' vectors for both elements.
#'
#' @examples
#' get_column_choices(
#'   search_tables = c("SampleProvenance", "SampleClassification"),
#'   constants = constants
#' )
get_column_choices <- function(search_tables, constants) {
  len <- length(search_tables)
  if (len == 0) {
    return(list(all = c(""), default = c("")))
  }
  
  col_all <- constants$tab.cols[[search_tables[1]]]
  col_default <- constants$default.cols[[search_tables[1]]]
  
  if (len > 1) {
    for (i in search_tables[2:len]) {
      col_all <- c(col_all, constants$tab.cols[[i]])
      col_default <- c(col_default, constants$default.cols[[i]])
    }
  }
  
  list(all = col_all, default = col_default)
}