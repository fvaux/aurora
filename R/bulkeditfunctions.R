# bulk_edit_functions.R
# Aurora App — Bulk Edit tab helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06
#
# This is an R script for the Aurora application
# It contains helper functions used by the Bulk Edit tab to export
# and import Aurora data tables for external editing in CSV format.


# Helper: Generate consistent bulk edit filename ====

#' Generate Bulk Edit Filename
#'
#' Creates a consistent filename and file path used when exporting or
#' importing Aurora data tables for bulk editing. The function determines
#' whether the application is currently operating on example data and
#' adjusts the filename prefix accordingly.
#'
#' @param table_key Character string identifying the data table being
#' exported or imported. This key corresponds to entries in
#' `table_mapping`.
#' @param fpath_fn Function returning the current Aurora data directory
#' path.
#' @param examplepath Character string specifying the path used when
#' Aurora is running with example data.
#' @param dir_path Character string specifying the directory where the
#' CSV file should be written or read.
#'
#' @return A character string representing the full file path for the
#' bulk-edit CSV file.
#'
#' @details
#' When example data are being used, the filename is prefixed with
#' `"example "` to distinguish it from user data exports.
#'
#' @examples
#' bulk_edit_filename(
#'   table_key = "SampleProvenance",
#'   fpath_fn = fpath_fn,
#'   examplepath = examplepath,
#'   dir_path = "./mungeproofed_csvs"
#' )
bulk_edit_filename <- function(table_key, fpath_fn, examplepath, dir_path) {
  # Determine if example data is being used
  if (fpath_fn() == examplepath) {
    ex <- "example "
  } else {
    ex <- ""
  }
  
  # Return the full path for the file
  file.path(dir_path, paste0("MP_", ex, table_key, ".csv"))
}


# Export a single data table to CSV for bulk editing ====

#' Export Table for Bulk Editing
#'
#' Exports a single Aurora data table to a CSV file that can be edited
#' outside the application. The exported table is first processed using
#' `mungeProof()` to ensure that it is safe for external editing.
#'
#' @param table_key Character string identifying the table to export.
#' This key must exist within the `table_mapping` object.
#' @param fpath_fn Function returning the current Aurora data directory
#' path.
#' @param examplepath Character string specifying the example dataset
#' path used by the application.
#'
#' @return This function is called for its side effect of writing a CSV
#' file to disk. No explicit value is returned.
#'
#' @details
#' The exported file is written to the `./mungeproofed_csvs` directory
#' using a standardised filename produced by `bulk_edit_filename()`.
#'
#' @examples
#' bulk_export_table(
#'   table_key = "SampleProvenance",
#'   fpath_fn = fpath_fn,
#'   examplepath = examplepath
#' )
bulk_export_table <- function(table_key, fpath_fn, examplepath) {
  outfile <- get(table_mapping[table_key])
  outfile <- mungeProof(outfile)
  
  # Generate the filename
  export_path <- bulk_edit_filename(
    table_key = table_key,
    fpath_fn = fpath_fn,
    examplepath = examplepath,
    dir_path = "./mungeproofed_csvs"
  )
  
  # Save CSV
  write.csv(outfile, file = export_path, row.names = FALSE)
}


# Import a single data table from CSV after bulk editing ====

#' Import Bulk Edited Table
#'
#' Imports a CSV file previously exported for bulk editing and restores
#' it to the Aurora application environment. The imported data are
#' processed using `mungeReverse()` before replacing the corresponding
#' in-memory data table.
#'
#' @param table_key Character string identifying the table to import.
#' This key must exist within the `table_mapping` object.
#' @param fpath_fn Function returning the current Aurora data directory
#' path.
#' @param mungepath Character string specifying the directory where the
#' edited CSV files are stored.
#' @param examplepath Character string specifying the example dataset
#' path used by the application.
#'
#' @return Logical value indicating whether the import was successful.
#' Returns `TRUE` if the table was successfully loaded and assigned,
#' otherwise returns `FALSE`.
#'
#' @details
#' If the file cannot be read, a user notification is generated via
#' `toastr_error()`. When successful, the function replaces the
#' corresponding table in the global environment and saves the updated
#' table as an `.rds` file in the Aurora data directory.
#'
#' @examples
#' bulk_import_table(
#'   table_key = "SampleProvenance",
#'   fpath_fn = fpath_fn,
#'   mungepath = "./mungeproofed_csvs",
#'   examplepath = examplepath
#' )
bulk_import_table <- function(table_key, fpath_fn, mungepath, examplepath) {
  # Generate the filename
  import_path <- bulk_edit_filename(
    table_key = table_key,
    fpath_fn = fpath_fn,
    examplepath = examplepath,
    dir_path = mungepath
  )
  
  infile <- NULL
  
  tryCatch(
    {
      infile <- read_csv(file = import_path)
    },
    error = function(w) {
      toastr_error("Check File Exists", position = "bottom-left")
    }
  )
  
  if (!is.null(infile)) {
    infile <- infile %>% mungeReverse()
    
    assign(table_mapping[table_key], infile, envir = .GlobalEnv)
    saveRDS(infile, file = paste0(fpath_fn(), table_mapping[table_key], ".rds"))
    return(TRUE)
  }
  
  return(FALSE)
}