# loadprimarydata
# Grant Abernethy
# Date: 2023.07.31
#
# This is an R script for the Aurora application
# loadprimarydata loads data into the app
# This function includes steps to transform the formatting of the data (via formatDataTables)
# Also converts year, month and day columns into dates (via updateDate)

# loadprimarydata ====

#' Load Primary Aurora Data
#'
#' Reads Aurora application data tables from `.rds` files, applies
#' formatting transformations, and loads the tables into the global
#' environment for use within the application.
#'
#' The function performs several post-loading transformations, including:
#' \itemize{
#'   \item Standardising numeric and character formatting using
#'   `formatDataTables()`
#'   \item Generating a `species_binomial` column in
#'   `table_SampleClassification`
#'   \item Converting separate year, month, and day fields into combined
#'   date columns using `updateDate()`
#'   \item Reordering columns according to the `default.cols` specification
#' }
#'
#' @param table_mapping Named object containing the mapping between
#' Aurora table identifiers and the `.rds` filenames used to store them.
#' @param path Character string specifying the directory containing
#' the `.rds` data files.
#'
#' @return No explicit return value. The function loads multiple data
#' tables into the global environment as a side effect.
#'
#' @details
#' Each table listed in `table_mapping` is loaded individually from an
#' `.rds` file and assigned into the global environment using the
#' mapped table name. Formatting and structural transformations are
#' applied immediately after loading.
#'
#' The `species_binomial` field is automatically generated for
#' `table_SampleClassification` by combining `genus` and `species`
#' columns where valid species names are present.
#'
#' After all tables are loaded, the `updateDate()` function merges
#' year, month, and day columns into unified date fields, and columns
#' are reordered according to the predefined `default.cols` structure.
#'
#' @examples
#' loadprimarydata(
#'   table_mapping = table_mapping,
#'   path = "./aurora_data/"
#' )
loadprimarydata <- function(table_mapping, path) {
  # Load each file once and record the modification time of that version.
  # safesave() expects ltisim_list in .GlobalEnv, indexed by full file path.
  timestamps <- list()
  
  for (i in unname(table_mapping)) {
    f <- file.path(path, paste0(i, ".rds"))
    if (!file.exists(f)) stop("Missing Aurora data file: ", f)
    
    mtime_before <- file.info(f)$mtime
    x <- readRDS(f)
    mtime_after <- file.info(f)$mtime
    if (is.na(mtime_before) || is.na(mtime_after) ||
        !identical(as.numeric(mtime_before), as.numeric(mtime_after))) {
      stop("Aurora data file changed while loading: ", f)
    }
    timestamps[[normalizePath(f, winslash = "/", mustWork = TRUE)]] <- mtime_after
    
    x <- formatDataTables(x)
    if (i == "table_SampleClassification") {
      x <- x %>%
        mutate(species_binomial = if_else(
          is.na(species) | species == "", NA_character_, paste(genus, species)
        ))
    }
    assign(i, x, envir = .GlobalEnv)
  }
  
  # Retain the original derived-date and column-ordering behaviour.
  updateDate()
  for (i in unname(table_mapping)) {
    table_name <- names(table_mapping)[table_mapping == i]
    x <- get(i, envir = .GlobalEnv)
    if (table_name %in% names(default.cols)) {
      x <- x[, default.cols[[table_name]], drop = FALSE]
      assign(i, x, envir = .GlobalEnv)
    }
  }
  
  # Publish timestamps only after the entire load succeeds.
  assign("ltisim_list", timestamps, envir = .GlobalEnv)
  invisible(NULL)
}
