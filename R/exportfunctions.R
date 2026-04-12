# exportfunctions.R
# Aurora App — Export tab helper functions
# Grant Abernethy & Felix Zareie-Vaux
# Date: 2025-08-06

# This is an R script for the Aurora application

#' Export helper functions
#'
#' Internal helper functions used by the Export tab of the Aurora Shiny app.
#'
#' These functions gather and export data in different formats.
#'
#' @keywords internal
NULL

# Generate full export dataset ====
#' Generate full export dataset
#'
#' Builds the complete Aurora export dataset by joining all sample-related
#' tables into a single data frame.
#'
#' @return A data frame containing combined sample tracking, taxonomy,
#' provenance, storage, extraction, PCR, library preparation, sequencing,
#' and publication metadata.
#'
#' @details
#' Date columns are reconstructed from year, month, and day components if
#' they are not already present. The resulting dataset is intended for
#' export or downstream analysis.

generate_export_data <- function() {
  # Ensure date columns exist (rebuild from year, month, day if needed)
  table_SampleProvenance2 <- table_SampleProvenance %>%
    mutate(
      provenance_date = if ("provenance_date" %in% names(.)) {
        provenance_date
      } else {
        getDate(sample_year, sample_month, sample_day)
      }
    ) %>%
    select(1, provenance_date, everything())

  table_SampleStorage2 <- table_SampleStorage %>%
    mutate(
      storage_date = if ("storage_date" %in% names(.)) {
        storage_date
      } else {
        getDate(storage_year, storage_month, storage_day)
      }
    ) %>%
    select(1, storage_date, everything())

  table_Extraction2 <- table_Extraction %>%
    mutate(
      extract_date = if ("extract_date" %in% names(.)) {
        extract_date
      } else {
        getDate(extract_year, extract_month, extract_day)
      }
    ) %>%
    select(1, extract_accession, extract_date, everything())

  table_PCR2 <- table_PCR %>%
    mutate(
      pcr_date = if ("pcr_date" %in% names(.)) {
        pcr_date
      } else {
        getDate(pcr_year, pcr_month, pcr_day)
      }
    ) %>%
    select(1, pcr_accession, pcr_date, everything())

  table_LibraryPreparation2 <- table_LibraryPreparation %>%
    mutate(
      library_date = if ("library_date" %in% names(.)) {
        library_date
      } else {
        getDate(library_year, library_month, library_day)
      }
    ) %>%
    select(1, library_accession, library_date, everything())

  table_Sequencing2 <- table_Sequencing %>%
    mutate(
      sequencing_date = if ("sequencing_date" %in% names(.)) {
        sequencing_date
      } else {
        getDate(sequencing_year, sequencing_month, sequencing_day)
      }
    ) %>%
    select(1, sequencing_accession, sequencing_date, everything())

  # Combine all tables
  export_data <- table_SampleTracking %>%
    left_join(table_SampleClassification, by = "sample_accession") %>%
    left_join(
      table_SampleTaxonomy %>%
        select(-species_binomial, -genus, -family, -match_level),
      by = "sample_accession"
    ) %>%
    left_join(table_SampleProvenance2, by = "sample_accession") %>%
    left_join(table_SampleDetail, by = "sample_accession") %>%
    left_join(table_SampleStorage2, by = "sample_accession") %>%
    left_join(table_Extraction2, by = "sample_accession") %>%
    left_join(table_PCR2, by = "sample_accession") %>%
    left_join(table_LibraryPreparation2, by = "sample_accession") %>%
    left_join(table_Sequencing2, by = "sample_accession") %>%
    left_join(table_Publication, by = "sample_accession")

  return(export_data)
}

# Export a dataset to CSV and RDS ====
#' Export a dataset to CSV and RDS
#'
#' Writes a dataset to both CSV and RDS formats using a timestamped filename.
#'
#' @param df Data frame to export.
#' @param prefix Character string used as the filename prefix.
#'
#' @return No return value. Files are written to disk in the configured
#' export directory.
#'
#' @details
#' The CSV export is cleaned using `mungeProof()` to remove formatting issues,
#' while the RDS export uses `formatDataTables()` to preserve formatting for
#' later reloading into the Aurora application.

export_dataset <- function(df, prefix) {
  # Generate a timestamp: YYYYMMDD_HHMMSS (e.g., 20251016_100349)
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")

  # CSV export (cleaned)
  cleaned_csv <- mungeProof(df)
  write_csv(cleaned_csv, file = paste0(exportpath, prefix, "_", timestamp, ".csv"))

  # RDS export (formatted)
  formatted_rds <- formatDataTables(df)
  saveRDS(formatted_rds, file = paste0(exportpath, prefix, "_", timestamp, ".rds"))
}

# Filter sequenced samples ============================
filter_sequenced_samples <- function(df) {
  df %>% filter(!sequencing_accession == "_NA")
}