# editfunctions.R
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06
#
# This is an R script for the Aurora application
# It contains helper functions used by the Aurora editing interface
# to retrieve, modify, and save editable data tables.


# Get editable table ====

#' Retrieve Editable Table
#'
#' Loads a data table from the global environment and prepares it for
#' editing within the Aurora application. Optionally calculates and
#' displays duplicate counts based on `sample_accession`.
#'
#' @param check_group Character string identifying the table to load.
#' @param table_mapping Named object mapping `check_group` keys to
#' corresponding table names in the global environment.
#' @param duplicate_mode Logical indicating whether duplicate counts
#' should be calculated and displayed. Defaults to `FALSE`.
#'
#' @return A data frame representing the editable table.
#'
#' @details
#' When `duplicate_mode = TRUE`, the function calculates duplicate
#' occurrences of `sample_accession` using `dplyr::add_count()` and
#' adds a `duplicate` column to assist with identifying repeated
#' entries. When disabled, any existing `duplicate` column is removed.
#'
#' @examples
#' get_edit_table(
#'   check_group = "SampleProvenance",
#'   table_mapping = table_mapping,
#'   duplicate_mode = TRUE
#' )
get_edit_table <- function(check_group, table_mapping, duplicate_mode = FALSE) {
  xdt <- get(table_mapping[check_group], envir = .GlobalEnv)
  
  if (duplicate_mode) {
    xdt <- xdt %>%
      add_count(sample_accession, name = "duplicate") %>%
      select(duplicate, everything()) %>%
      arrange(desc(duplicate), sample_accession)
  } else {
    xdt <- xdt %>%
      select(-any_of(c("duplicate")))
  }
  
  assign(table_mapping[check_group], xdt, envir = .GlobalEnv)
  xdt
}


# Add rows to editable table ====

#' Add Rows to Editable Table
#'
#' Inserts new rows into an editable Aurora data table. Rows can be
#' inserted as empty rows or as duplicates of an existing row.
#'
#' @param check_group Character string identifying the table to modify.
#' @param table_mapping Named object mapping `check_group` keys to
#' corresponding table names in the global environment.
#' @param selected_rows Integer vector indicating which rows are selected
#' in the editing interface.
#' @param dup_count Integer specifying how many duplicate rows should be
#' created from the selected row. If `0`, blank rows are inserted.
#' @param proxy A `DT` proxy object used to update the interactive table
#' display in the Shiny interface.
#'
#' @return Invisibly returns `NULL`. The function is called for its
#' side effects of modifying the table and updating the display.
#'
#' @details
#' If `dup_count > 0`, exactly one row must be selected. The selected
#' row will be duplicated `dup_count` times and inserted directly
#' after the selected position. If multiple rows are selected in this
#' mode, a warning notification is displayed.
#'
#' @examples
#' add_rows_to_edit_table(
#'   check_group = "SampleProvenance",
#'   table_mapping = table_mapping,
#'   selected_rows = 3,
#'   dup_count = 2,
#'   proxy = proxy
#' )
add_rows_to_edit_table <- function(check_group, table_mapping, selected_rows, dup_count, proxy) {
  xdt <- get(table_mapping[check_group], envir = .GlobalEnv)
  
  if (dup_count == 0) {
    for (i in selected_rows) {
      xdt <- xdt %>% add_row(.after = i)
    }
  } else {
    if (length(selected_rows) == 1) {
      newrow <- tibble_row(xdt[selected_rows, ])
      for (j in seq_len(dup_count)) {
        xdt <- xdt %>% add_row(newrow, .after = selected_rows)
      }
    } else {
      toastr_warning("Select only 1 row!", position = "bottom-left")
      return(invisible(NULL))
    }
  }
  
  assign(table_mapping[check_group], xdt, envir = .GlobalEnv)
  replaceData(proxy, xdt, rownames = FALSE, resetPaging = FALSE)
}


# Abandon selected rows ====

#' Remove Selected Rows from Editable Table
#'
#' Deletes selected rows from an editable Aurora data table when the
#' abandon mode is enabled.
#'
#' @param check_group Character string identifying the table to modify.
#' @param table_mapping Named object mapping `check_group` keys to
#' corresponding table names in the global environment.
#' @param selected_rows Integer vector of row indices to remove.
#' @param proxy A `DT` proxy object used to update the interactive table
#' display in the Shiny interface.
#' @param abandon_enabled Logical indicating whether row deletion is
#' currently permitted.
#' @param save_fn Function used to persist the updated table to disk.
#'
#' @return No explicit return value. The function modifies the table
#' and updates the interface as a side effect.
#'
#' @details
#' If `abandon_enabled` is `FALSE`, a warning notification is shown and
#' the table remains unchanged.
#'
#' @examples
#' abandon_rows(
#'   check_group = "SampleProvenance",
#'   table_mapping = table_mapping,
#'   selected_rows = c(2, 5),
#'   proxy = proxy,
#'   abandon_enabled = TRUE,
#'   save_fn = save_fn
#' )
abandon_rows <- function(check_group, table_mapping, selected_rows, proxy, abandon_enabled, save_fn) {
  if (!abandon_enabled) {
    toastr_warning("Need to enable Abandon", position = "bottom-left")
    return()
  }
  
  xdt <- get(table_mapping[check_group], envir = .GlobalEnv)
  xdt <- xdt[-selected_rows, ]
  assign(table_mapping[check_group], xdt, envir = .GlobalEnv)
  replaceData(proxy, xdt, rownames = FALSE, resetPaging = FALSE)
  save_fn()
}


# Save edits to disk ====

#' Save Edited Table to Disk
#'
#' Cleans and saves the currently edited Aurora data table to disk as
#' an `.rds` file. The function removes temporary columns and standardises
#' missing values before writing the file.
#'
#' @param check_group Character string identifying the table to save.
#' @param table_mapping Named object mapping `check_group` keys to
#' corresponding table names in the global environment.
#' @param fpath Function returning the directory where the `.rds`
#' file should be written.
#'
#' @return No explicit return value. The function writes an `.rds`
#' file and produces user notifications.
#'
#' @details
#' The function performs several validation steps before saving:
#' \itemize{
#'   \item Removes temporary columns such as `duplicate`
#'   \item Converts `"NA"` and blank strings to true `NA` values
#'   \item Ensures that `sample_accession` is present for all rows
#' }
#'
#' If validation fails, the table is not saved and the user receives
#' a notification.
#'
#' @examples
#' save_edits(
#'   check_group = "SampleProvenance",
#'   table_mapping = table_mapping,
#'   fpath = fpath
#' )
save_edits <- function(check_group, table_mapping, fpath) {
  tm <- table_mapping[check_group]
  xtemp <- get(tm, envir = .GlobalEnv)
  
  xtemp <- xtemp %>%
    select(-any_of(c("duplicate"))) %>%
    mutate(
      across(.fns = ~ na_if(., "NA")),
      across(.fns = ~ na_if(., ""))
    )
  
  if (nrow(xtemp) == 0) {
    return()
  }
  
  if (nrow(xtemp %>% filter(is.na(sample_accession) | sample_accession == "")) > 0) {
    toastr_error("Check sample_accession", position = "bottom-left")
    toastr_warning("Not Saved", position = "bottom-left")
    return()
  }
  
  assign(tm, xtemp, envir = .GlobalEnv)
  saveRDS(xtemp, file = paste0(fpath(), tm, ".rds"))
  toastr_success("Saved to Disk", position = "bottom-left")
}