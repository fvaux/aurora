# safeSave.R
# Aurora App — safeSave functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2026-10-13

# This is an R script for the Aurora application

# Checks whether an RDS file has changed since it was loaded.
# Uses the global ltisim_list maintained by loadprimarydata.R, keyed by full file path.
# This is an optimistic timestamp check, not a file lock.

#' Safely save a main Aurora data table
#' @param data Data frame/tibble to save.
#' @param filepath Directory containing the RDS files (character path).
#' @param file Filename without the .rds extension.
#' @param toastr Display an internal notification? Set FALSE if the caller
#'   handles its own success/failure notifications or when called outside Shiny.
#' @return TRUE if saved, FALSE if refused or writing failed.
safesave <- function(data, filepath, file, toastr = TRUE) {
  notify <- function(success, message) {
    if (isTRUE(toastr)) {
      if (success) {
        shinytoastr::toastr_success(message, position = "bottom-left")
      } else {
        shinytoastr::toastr_warning(message, position = "bottom-left")
      }
    }
  }
  
  if (!is.character(filepath) || length(filepath) != 1L ||
      is.na(filepath) || !nzchar(filepath) ||
      !is.character(file) || length(file) != 1L ||
      is.na(file) || !nzchar(file)) {
    notify(FALSE, "File not saved: invalid file path or name.")
    return(FALSE)
  }
  
  f <- file.path(filepath, paste0(file, ".rds"))
  if (!file.exists(f)) {
    notify(FALSE, paste0("File not saved: ", file, ".rds is missing."))
    return(FALSE)
  }
  
  if (!exists("ltisim_list", envir = .GlobalEnv, inherits = FALSE)) {
    notify(FALSE, "File not saved: modification timestamps are not initialised.")
    return(FALSE)
  }
  
  key <- normalizePath(f, winslash = "/", mustWork = TRUE)
  expected <- get("ltisim_list", envir = .GlobalEnv, inherits = FALSE)[[key]]
  current <- file.info(f)$mtime
  if (length(expected) != 1L || is.na(expected) ||
      length(current) != 1L || is.na(current)) {
    notify(FALSE, paste0("File not saved: no valid timestamp for ", file, "."))
    return(FALSE)
  }
  
  if (!identical(as.numeric(current), as.numeric(expected))) {
    notify(FALSE, paste0("File not saved: ", file,
                         " has changed on disk. Restart Aurora to reload the latest data."))
    return(FALSE)
  }
  
  if (!inherits(data, "data.frame")) {
    notify(FALSE, "File not saved: data must be a data frame or tibble.")
    return(FALSE)
  }
  
  ok <- tryCatch({
    saveRDS(data, file = f)
    TRUE
  }, error = function(e) {
    warning("safesave failed for ", f, ": ", conditionMessage(e))
    FALSE
  })
  if (!ok) {
    notify(FALSE, paste0("File not saved: writing ", file, " failed."))
    return(FALSE)
  }
  
  timestamps <- get("ltisim_list", envir = .GlobalEnv, inherits = FALSE)
  timestamps[[key]] <- file.info(f)$mtime
  assign("ltisim_list", timestamps, envir = .GlobalEnv)
  notify(TRUE, paste0(file, " saved successfully."))
  TRUE
}
