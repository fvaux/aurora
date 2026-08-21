# batcheditfunctions.R
# Aurora App — Batch Edit and Move page helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-21

#' Batch edit and move helper functions
#'
#' Internal helper functions used by the Batch Edit and Move page
#' of the Aurora Shiny app.
#'
#' These functions support exact-match batch editing of storage-related
#' fields and moving sample or extraction boxes between storage units.
#'
#' @keywords internal
NULL


# Clean choices ====
#' Clean Batch Edit Choices
#'
#' Cleans a vector of values before using them as choices in Shiny
#' select inputs.
#'
#' Duplicate values, missing values, and blank character strings are
#' removed, and the remaining values are sorted.
#'
#' @param x A vector containing values to clean.
#'
#' @return A sorted vector containing unique, non-missing and non-blank
#' values.
#'
#' @details
#' This function is primarily used to prepare storage unit and box names
#' for use in the Batch Edit and Move page dropdown menus.
#'
#' @export
#'
#' @examples
#' clean_batch_choices(c("Freezer 2", "Freezer 1", NA, "", "Freezer 1"))
clean_batch_choices <- function(x) {
  
  x <- sort(unique(x))
  
  x[
    !is.na(x) &
      x != ""
  ]
}


# General batch edit ====
#' Batch Edit Values
#'
#' Replaces all exact matches of a selected value within a specified
#' column of a data frame.
#'
#' @param table_data A data frame containing the records to edit.
#' @param col Character string specifying the column to edit.
#' @param old_val Value to search for within the selected column.
#' @param new_val Replacement value to assign to all matching records.
#'
#' @return A list containing:
#' \describe{
#'   \item{data}{The edited data frame.}
#'   \item{rows_changed}{The number of rows modified.}
#' }
#'
#' @details
#' Matching is exact. For example, searching for `"Freezer 1"` will not
#' match `"Freezer 10"` or `"freezer 1"`.
#'
#' The function does not modify objects in the global environment or save
#' any files. These actions are handled separately by the Aurora server.
#'
#' If the selected column does not exist in the supplied data frame, the
#' function stops with an error.
#'
#' @export
#'
#' @examples
#' result <- batch_edit_values(
#'   table_data = table_SampleStorage,
#'   col = "storage_unit",
#'   old_val = "Freezer 1",
#'   new_val = "Freezer 2"
#' )
batch_edit_values <- function(table_data, col, old_val, new_val) {
  
  # Check that selected column exists
  if (!col %in% names(table_data)) {
    stop(paste("Column not found:", col))
  }
  
  # Find matching rows
  rows <- which(table_data[[col]] == old_val)
  
  # Apply edit
  if (length(rows) > 0) {
    table_data[rows, col] <- new_val
  }
  
  list(
    data = table_data,
    rows_changed = length(rows)
  )
}


# Get storage units ====
#' Get Available Storage Units
#'
#' Retrieves the available storage units for either samples or
#' extractions.
#'
#' @param box_type Character string specifying the storage type.
#' Use `"storage"` for sample storage or `"extract"` for extraction
#' storage.
#' @param table_SampleStorage A data frame containing sample storage
#' records.
#' @param table_Extraction A data frame containing extraction storage
#' records.
#'
#' @return A sorted character vector containing unique, non-missing and
#' non-blank storage unit names. If `box_type` is not recognised, an
#' empty character vector is returned.
#'
#' @details
#' Sample storage units are obtained from `storage_unit`, whereas
#' extraction storage units are obtained from `extract_unit`.
#'
#' Values are cleaned using [clean_batch_choices()].
#'
#' @export
#'
#' @examples
#' get_batch_storage_units(
#'   box_type = "storage",
#'   table_SampleStorage = table_SampleStorage,
#'   table_Extraction = table_Extraction
#' )
get_batch_storage_units <- function(box_type,
                                    table_SampleStorage,
                                    table_Extraction) {
  
  if (box_type == "storage") {
    
    unit_choices <- table_SampleStorage$storage_unit
    
  } else if (box_type == "extract") {
    
    unit_choices <- table_Extraction$extract_unit
    
  } else {
    
    return(character(0))
  }
  
  clean_batch_choices(unit_choices)
}


# Get storage boxes ====
#' Get Available Storage Boxes
#'
#' Retrieves storage boxes associated with a selected storage unit for
#' either samples or extractions.
#'
#' @param box_type Character string specifying the storage type.
#' Use `"storage"` for sample storage or `"extract"` for extraction
#' storage.
#' @param current_unit Character string specifying the currently selected
#' storage unit.
#' @param table_SampleStorage A data frame containing sample storage
#' records.
#' @param table_Extraction A data frame containing extraction storage
#' records.
#'
#' @return A sorted character vector containing unique, non-missing and
#' non-blank box names associated with the selected storage unit. If
#' `box_type` is not recognised, an empty character vector is returned.
#'
#' @details
#' For sample storage, boxes are selected from `storage_box` where
#' `storage_unit` matches `current_unit`.
#'
#' For extraction storage, boxes are selected from `extract_box` where
#' `extract_unit` matches `current_unit`.
#'
#' Values are cleaned using [clean_batch_choices()].
#'
#' @export
#'
#' @examples
#' get_batch_storage_boxes(
#'   box_type = "storage",
#'   current_unit = "Freezer 1",
#'   table_SampleStorage = table_SampleStorage,
#'   table_Extraction = table_Extraction
#' )
get_batch_storage_boxes <- function(box_type,
                                    current_unit,
                                    table_SampleStorage,
                                    table_Extraction) {
  
  if (box_type == "storage") {
    
    box_choices <- table_SampleStorage$storage_box[
      table_SampleStorage$storage_unit == current_unit
    ]
    
  } else if (box_type == "extract") {
    
    box_choices <- table_Extraction$extract_box[
      table_Extraction$extract_unit == current_unit
    ]
    
  } else {
    
    return(character(0))
  }
  
  clean_batch_choices(box_choices)
}


# Move storage box ====
#' Move Storage Box
#'
#' Moves all records associated with a selected storage box from one
#' storage unit to another.
#'
#' @param table_data A data frame containing storage records.
#' @param unit_col Character string specifying the storage unit column.
#' @param box_col Character string specifying the storage box column.
#' @param current_unit Character string specifying the current storage unit.
#' @param selected_box Character string specifying the box to move.
#' @param destination_unit Character string specifying the destination
#' storage unit.
#'
#' @return A list containing:
#' \describe{
#'   \item{data}{The edited data frame.}
#'   \item{rows_changed}{The number of rows moved.}
#' }
#'
#' @details
#' Records are matched using both the current storage unit and selected
#' box. This reduces the risk of unintentionally moving records where
#' identically named boxes occur in different storage units.
#'
#' Only the storage unit column is modified; intermediate storage levels
#' such as shelves, racks, slots, plates, or wells are not changed.
#'
#' The function does not modify objects in the global environment or save
#' any files. These actions are handled separately by the Aurora server.
#'
#' If either required column is absent from the supplied data frame, the
#' function stops with an error.
#'
#' @export
#'
#' @examples
#' result <- move_storage_box(
#'   table_data = table_SampleStorage,
#'   unit_col = "storage_unit",
#'   box_col = "storage_box",
#'   current_unit = "Freezer 1",
#'   selected_box = "Box 17",
#'   destination_unit = "Freezer 2"
#' )
move_storage_box <- function(table_data,
                             unit_col,
                             box_col,
                             current_unit,
                             selected_box,
                             destination_unit) {
  
  # Check required columns exist
  if (!unit_col %in% names(table_data)) {
    stop(paste("Column not found:", unit_col))
  }
  
  if (!box_col %in% names(table_data)) {
    stop(paste("Column not found:", box_col))
  }
  
  # Find records matching both current unit and selected box
  rows <- which(
    table_data[[unit_col]] == current_unit &
      table_data[[box_col]] == selected_box
  )
  
  # Move matching records
  if (length(rows) > 0) {
    table_data[rows, unit_col] <- destination_unit
  }
  
  list(
    data = table_data,
    rows_changed = length(rows)
  )
}