# This is the global code for the Aurora application
# Developers: Grant Abernethy and Felix Zareie-Vaux

# Load packages ==============================
# Load required R packages into library 
suppressPackageStartupMessages({
  library(shiny) # Base package for R Shiny apps
  library(tidyverse) # Base package for bioinformatics
  library(lubridate) # Base handling functions
  library(DT) # Creating Java data tables
  library(rmarkdown) # For generating reports 🌱 Can this be replaced with Quarto (in base RStudio)?
  library(readxl) # For upload from Excel, from dplyr
  library(shinyWidgets) # Provides nicer input widgets
  library(knitr) # For formatting tables in rmarkdown
  options(kableExtra.auto_format = FALSE) # This line must be run before loading KableExtra
  library(kableExtra) # For formatting tables in rmarkdown
  library(shinytoastr) # For posting alerts such as success, warning etc.
  library(plotly) # For interactive plots
  library(leaflet) # For interactive maps
  library(htmlwidgets) # For exporting html reports
  library(glue) # For string formatting - used for for exporting html reports
  library(tools) # For filtering on Filter tab (is a base R package but need to load)
  library(writexl) # For writing Excel reports
  #library(quarto) # For exporting html reports
})

# Source R files ============================
# Reads in all files stored in the Aurora app's R folder
# ⚠️ Be careful not to save any unwanted R files that folder - will be read in and may cause crash
list.files(path = "R", full.names = T) %>%
  walk(source)

# File paths ============================
# Define file paths and locations used within the Aurora app folder
# ⚠️ If desired, users can change these locations
filepath <- "./RDataFiles/" # File path for the Data Table .rds files and other key files
examplepath <- "./exampledata/"
mungepath <- "./mungeproofed_csvs/"
srqpath <- "./Upload/aurora_queue.xlsx" # Location of the Aurora MS Excel file used for uploading samples
srqsheet <- "Upload" # The name of the aurora_queue.xlsx tab used for the sample upload
taxonomypath <- "./Taxonomy/taxonomy_source.xlsx" # Location of the taxonomy source table used for broad-level taxonomic information
exportpath <- "./Export/" # File path for exported data
reportpath <- "./Reports/" # _sFile path for reports

# Table mapping ============================
# Mapping of Data Tables within the app
# Left-hand side are names used in UI Widgets
# Right-hand side are names of tibbles and corresponding .rds file names
# ⚠️ Any newly developed Data Tables (.rds files) need to be mapped here
table_mapping <- c(
  "Sample Tracking" = "table_SampleTracking", # Tracks samples (includes sample_accession)
  "Sample Classification" = "table_SampleClassification", # Records sample classification
  "Sample Detail" = "table_SampleDetail", # Details about samples
  "Sample Provenance" = "table_SampleProvenance", # Provenance/origin of samples
  "Sample Storage" = "table_SampleStorage", # Where samples are physically kept
  "Extraction" = "table_Extraction", # Genetics: Nucleic acid extractions of samples
  "PCR" = "table_PCR", # Genetics: Polymerase chain reaction (PCR) amplifications of samples
  "Library Preparation" = "table_LibraryPreparation", # Genetics: Sequencing library preparations of samples
  "Sequencing" = "table_Sequencing", # Genetics: Molecular sequencing of samples
  "Publication" = "table_Publication" # Publications/reports associated with samples
)

# Define columns ============================
# default.cols defines the default sorting of columns/fields within each Data Table
# Sorting used here is default sorting shown in app's tables (e.g. Search and Edit tabs)
# ⚠️ Users can change the order of columns here to customise their version of the app
# ⚠️ New Data Tables and columns should be listed here (also need adding to the aurora_queue.xlsx file)
default.cols <- list(
  "Sample Tracking" = c("sample_accession", "key_word", "project", "project_code", "external_facility1", "external_accession1", "external_facility2", "external_accession2", "access", "access_note", "priority"),
  "Sample Classification" = c("sample_accession", "family", "genus", "species_binomial", "subspecies", "variety", "serotype", "presumptive_id", "confirmed_id", "gn_classifier1", "gn_classifier2", "gn_classifier3", "common_group", "common_name", "classified_by", "classification_method", "presumptive_method", "confirmation_method", "classification_note", "species"),
  "Sample Detail" = c("sample_accession", "sex", "age", "developmental_stage", "host", "morphology", "photograph", "sample_type", "sample_group", "sample_length", "sample_width", "sample_height", "sample_volume", "sample_weight", "sample_size_units", "sample_method", "sample_tag", "sample_filter", "sample_note"),
  "Sample Provenance" = c("sample_accession", "provenance_date", "political_country", "political_state", "geographic_region", "geographic_subregion", "sample_location", "sample_point", "location_note", "sample_point_id", "sample_trip", "sample_transect", "transect_note", "sample_group_id", "substrate", "environment_category", "lat1", "long1", "lat2", "long2", "depth1", "depth2", "altitude1", "altitude2", "position_method", "coord_x", "coord_y", "coord_z", "coord_map", "collected_by", "sample_permit", "sample_year", "sample_month", "sample_day", "sample_hour", "sample_minute"),
  "Sample Storage" = c("sample_accession", "containment_status", "storage_date", "storage_method", "storage_unit", "storage_shelf", "storage_rack", "storage_slot", "storage_box", "storage_plate", "storage_well", "storage_label", "sample_status", "storage_note", "storage_year", "storage_month", "storage_day"),
  "Extraction" = c("sample_accession", "extract_accession", "extract_date", "extract_lab", "extracted_by", "extract_source", "extract_type", "extract_method", "elution_volume_ul", "extract_conc_ng_ul_1", "extract_conc_ng_ul_2", "extract_A260_A280", "extract_A260_A230", "extract_book", "extract_note", "extract_unit", "extract_shelf", "extract_rack", "extract_slot", "extract_box", "extract_plate", "extract_well", "extract_status", "extract_storage_note", "extract_year", "extract_month", "extract_day"),
  "PCR" = c("sample_accession", "pcr_accession", "pcr_batch", "pcr_plate", "pcr_well", "pcr_date", "pcr_lab", "pcr_by", "pcr_source", "pcr_type", "pcr_description", "pcr_result", "pcr_result_quant", "pcr_result_note", "pcr_volume_ul", "pcr_conc_ng_ul_1", "pcr_conc_ng_ul_2", "pcr_year", "pcr_month", "pcr_day"),
  "Library Preparation" = c("sample_accession", "library_accession", "library_number", "library_plate", "library_well", "library_date", "library_year", "library_month", "library_day", "library_prep_lab", "library_by", "library_source", "library_type", "library_method", "library_selection", "library_description", "library_layout", "library_index_plate", "library_index", "library_volume_ul", "library_conc_ng_ul_1", "library_conc_ng_ul_2", "library_A260_A280", "library_A260_A230"),
  "Sequencing" = c("sample_accession", "sequencing_accession", "sequencing_date", "sequencing_lab", "sequencing_run", "sequencing_platform", "instrument_model", "sequencing_length", "sequencing_status", "rr_number_reads", "rr_basepair_yield", "rr_gc_content", "rr_calc_length", "rr_avg_quality", "rr_avg_length", "rr_N50", "as_full_length", "as_Ns", "as_none_ATGC", "as_number_contigs", "as_longest_contig", "as_shortest_contig", "as_n50", "as_l50", "as_gc_content", "as_depth", "as_depth_SD", "as_method", "gn_internal_store", "gn_filetype", "gn_filename1", "gn_filename2", "gn_public_archive", "gn_archive_project", "gn_archive_accession1", "gn_archive_accession2", "gn_archive_note", "sequencing_year", "sequencing_month", "sequencing_day"),
  "Publication" = c("sample_accession", "key_publication", "key_publication_url", "publication_year", "publication_type")
)

## Load data ============================
# Data loaded into application and transformed using loadprimarydata function
loadprimarydata(table_mapping, filepath)

# Manage columns ============================
## Get column names ============================
# Create lists of columns per table (tab.cols), and overall list of all columns (template.cols) and default cols
# ⚠️ New columns not defined in the default mapping (above) will still be read here
tab.cols <- list()
template.cols <- NULL

for (i in names(table_mapping)) {
  tab.cols[[i]] <- colnames(get(table_mapping[i]))
  # bind_rows also removes duplicate names as a side effect; but creates a tibble
  template.cols <- bind_rows(template.cols, get(table_mapping[i])[0, ])
}

## Special needs  ============================
# Define columns for special needs search cases in Search tab
# 'Special needs' are pre-selected searches using particular columns across the Data Tables
# e.g. columns to find a specimen in storage or to check the identity of a specimen
# ⚠️ Users can add and modify special need cases here
sp_needs1 <- c("sample_accession", "external_accession1", "external_accession2", "storage_label", "extract_accession", "pcr_accession", "library_accession", "sequencing_accession", "gn_archive_project", "gn_archive_accession1", "gn_archive_accession2")
sp_needs2 <- c("sample_accession", "storage_label", "storage_unit", "storage_shelf", "storage_rack", "storage_box", "storage_plate", "storage_well", "sample_status", "storage_note")
sp_needs3 <- c("sample_accession", "extract_accession", "extract_unit", "extract_shelf", "extract_rack", "extract_box", "extract_plate", "extract_well", "extract_status", "extract_storage_note")
sp_needs4 <- c("sample_accession", "priority", "extract_accession", "pcr_accession", "library_accession", "sequencing_accession", "provenance_date", "storage_date", "extraction_date", "pcr_date", "library_date", "sequencing_date")
sp_needs5 <- c("sample_accession", "project", "access", "access_note", "sample_permit", "containment_status")
sp_needs6 <- c("sample_accession", "species_binomial", "subspecies", "variety", "serotype", "presumptive_id", "confirmed_id", "classification_method", "presumptive_method", "confirmation_method", "gn_classifier1", "gn_classifier2", "gn_classifier3")

# Create a map of sp_needs empty tibbles, which will map to the sp_case input widget
# ⚠️ Modify this section to change the special need cases listed in the app's Search tab
sp_needs <- c(
  "Check accessions" = "sp_needs1",
  "Find samples" = "sp_needs2",
  "Find extractions" = "sp_needs3",
  "Check priority" = "sp_needs4",
  "Check permissions" = "sp_needs5",
  "Check identification" = "sp_needs6"
)

# Manage taxonomy ============================
# Global function to load the taxonomy_source reference table (Excel file) for broad-level taxonomic information
# e.g. domain, kingdom, phylum, class, order
# ⚠️ Users can add new rows (i.e. new species, genera or families) by editing the taxonomy_source Excel file
# ⚠️ Users can add additional columns (i.e. taxonomic levels) as required (e.g. subphylum, infraclass, tribe) by editing the taxonomy_source Excel file
# We have provided a GBIF Excel file to help (code to generate also in utility.r)
# 🚨 Code currently can't distinguish between homonyms/records with matching genera or families (when no specific epithet)
# e.g. Morganella bacteria vs Morganella fungi
# 🌱 Potential solution: separate using common_group (or add back Kingdom?)

#' Generate Taxonomy Table for Aurora Samples
#'
#' Builds a taxonomy lookup table for samples in the Aurora application by
#' matching sample classifications to an external taxonomy reference table.
#'
#' The function attempts hierarchical matching in three steps:
#' \enumerate{
#'   \item Match by `species_binomial`
#'   \item Match remaining samples by `genus`
#'   \item Match remaining samples by `family`
#' }
#'
#' Each sample is matched at the **most specific available taxonomic level**,
#' and the level used for the match is recorded in the `match_level` column.
#'
#' @param classification_table Data frame containing sample classification
#' information. Expected to include at minimum the columns
#' `sample_accession`, `genus`, `family`, and `species_binomial`.
#'
#' @param taxonomypath Character string giving the path to the Excel file
#' containing the taxonomy reference table. The taxonomy data are read from
#' the first worksheet.
#'
#' @return A data frame containing taxonomy information matched to each
#' `sample_accession`. The output includes taxonomy fields from the reference
#' table along with an additional column:
#'
#' \describe{
#'   \item{match_level}{The taxonomic level used to match the sample
#'   (`species_binomial`, `genus`, or `family`).}
#' }
#'
#' @details
#' The taxonomy reference table is first filtered to ensure unique rows at
#' each taxonomic level (`species_binomial`, `genus`, and `family`) to avoid
#' ambiguous joins.
#'
#' Matching is performed sequentially:
#' \itemize{
#'   \item Samples with valid `species_binomial` values are matched first.
#'   \item Remaining unmatched samples are matched by `genus`.
#'   \item Remaining unmatched samples are matched by `family`.
#' }
#'
#' When matches occur at higher taxonomic levels (genus or family), lower
#' taxonomic fields are cleared to prevent misleading species assignments.
#'
#' @examples
#' taxonomy_table <- generate_taxonomy_table(
#'   classification_table = table_SampleClassification,
#'   taxonomypath = "taxonomy_reference.xlsx"
#' )
generate_taxonomy_table <- function(classification_table, taxonomypath) {
  taxonomy_table <- read_excel(taxonomypath, sheet = 1)

  # Create species_lookup with sample_accession, species_binomial, genus, and family
  species_lookup <- table_SampleClassification %>%
    transmute(
      sample_accession,
      genus,
      family,
      species_binomial
    )

  # Ensure taxonomy table has only unique rows per species_binomial, genus, family
  taxonomy_species <- taxonomy_table %>%
    filter(!is.na(species_binomial)) %>%
    distinct(species_binomial, .keep_all = TRUE)
  taxonomy_genus <- taxonomy_table %>%
    filter(!is.na(genus)) %>%
    distinct(genus, .keep_all = TRUE)
  taxonomy_family <- taxonomy_table %>%
    filter(!is.na(family)) %>%
    distinct(family, .keep_all = TRUE)

  # Step 1: Match samples based on species_binomial
  matched_species <- species_lookup %>%
    filter(!is.na(species_binomial)) %>%
    select(sample_accession, species_binomial) %>%
    left_join(taxonomy_species, by = "species_binomial")

  # Step 2: Match samples based on genus (only unmatched so far)
  matched_genus <- species_lookup %>%
    filter(!(sample_accession %in% matched_species$sample_accession)) %>%
    filter(!is.na(genus)) %>%
    select(sample_accession, genus) %>%
    left_join(taxonomy_genus, by = "genus") %>%
    mutate(
      species_binomial = NA_character_ # Clear species_binomial for genus-only matches
    )

  # Step 3: Match samples based on family (only unmatched so far)
  matched_family <- species_lookup %>%
    filter(!(sample_accession %in% c(matched_species$sample_accession, matched_genus$sample_accession))) %>%
    filter(!is.na(family)) %>%
    select(sample_accession, family) %>%
    left_join(taxonomy_family, by = "family") %>%
    mutate(
      genus = NA_character_, # Clear genus and species_binomial for family-only matches
      species_binomial = NA_character_
    )

  # Record the taxonomic level used to match samples
  matched_species <- matched_species %>% mutate(match_level = "species_binomial")
  matched_genus <- matched_genus %>% mutate(match_level = "genus")
  matched_family <- matched_family %>% mutate(match_level = "family")

  bind_rows(matched_species, matched_genus, matched_family)
}

# Combine final result for app held table_SampleTaxonomy (on launch)
# ⚠️ This table is made on app launch, it isn't automatically saved as an .rds file (also not available under Bulk Edit)
# ⚠️ Users can export any of these columns for downstream analyses though
table_SampleTaxonomy <- generate_taxonomy_table(table_SampleClassification, taxonomypath)

# Constants ============================
# These objects are retained in memory while the app is running
constants <- list(
  srqpath = srqpath,
  srqsheet = srqsheet,
  table_names = names(table_mapping),
  tab.cols = tab.cols,
  template.cols = template.cols,
  template.colnames = colnames(template.cols),
  default.cols = default.cols, # not sure if needed?
  search_sp_need = names(sp_needs),
  sp_needs = sp_needs
)

# Values ============================
# These values are used to define levels/factors when handling the data in the app
values <- list(
  # Samples
  # 🌱 unique() does same as  levels(as.factor), but faster on big table: NA?
  unitChoices = levels(as.factor(table_SampleStorage$storage_unit)),
  shelfChoices_samples = levels(as.factor(table_SampleStorage$storage_shelf)),
  boxChoices_samples = levels(as.factor(table_SampleStorage$storage_box)),
  plateChoices_samples = levels(as.factor(table_SampleStorage$storage_plate)),
  wellChoices_samples = levels(as.factor(table_SampleStorage$storage_well)),
  # Extractions
  unitChoices_extractions = levels(as.factor(table_Extraction$extract_unit)),
  shelfChoices_extractions = levels(as.factor(table_Extraction$extract_shelf)),
  plateChoices_extractions = levels(as.factor(table_Extraction$extract_plate)),
  boxChoices_extractions = levels(as.factor(table_Extraction$extract_box)),
  wellChoices_extractions = levels(as.factor(table_Extraction$extract_well))
)
template.selected <- default.cols[table_mapping[[1]]]
choice.selected <- list()

values$reportFilterColumns <- c(
  "project", "key_word", "sample_trip", "family",
  "genus", "species_binomial", "sequencing_run", "key_publication"
)

# Protected columns ====
# Columns protected from batch editing
protected_columns <- c(
  "sample_accession",
  "species_binomial",
  "sample_accession",
  "extract_accession"
)

# Dashboard statistics ============================
# Keep a running update every time Aurora app is opened
# These statistics allow any instability in database size to be monitored
# See the Dashboard tab in the app
# ⚠️ New Data Tables should be listed here
t <- tibble_row(
  date = today(),
  sample.tracking = nrow(table_SampleTracking),
  sample.classification = nrow(table_SampleClassification),
  sample.detail = nrow(table_SampleDetail),
  sample.provenance = nrow(table_SampleProvenance),
  sample.storage = nrow(table_SampleStorage),
  extraction = nrow(table_Extraction),
  pcr = nrow(table_PCR),
  library.preparation = nrow(table_LibraryPreparation),
  sequencing = nrow(table_Sequencing),
  publication = nrow(table_Publication)
)

# table_tracker records this information
# ⚠️ table_tracker does not self-deleted, users must manually clear or delete to remove existing data
table_Tracker <- readRDS(paste0(filepath, "table_Tracker.rds")) %>% bind_rows(t)
saveRDS(table_Tracker, paste0(filepath, "table_Tracker.rds"))

# Autobackup ============================
last.date <- readRDS(paste0(filepath, "LastSaveDate.rds"))
today <- today()
# Backs up key files periodically
# Saves all files saved to one file
# To restore, open the backup in RStudio, then save the individual files as needed.
if (today - last.date > 2) {
  save(
    table_SampleTracking,
    table_SampleClassification,
    table_SampleDetail,
    table_SampleProvenance,
    table_SampleStorage,
    table_Extraction,
    table_PCR,
    table_LibraryPreparation,
    table_Sequencing,
    table_Publication,
    table_Tracker,
    file = (paste0("./Autobackups/Autobackup ", today, ".RData"))
  )
  saveRDS(today, file = (paste0(filepath, "LastSaveDate.rds")))
}

# This periodically backs up samples/entries abandoned via the Edit tab
if (today - last.date > 7) {
  file.copy(from = "./RDataFiles/abandoned.csv", to = (paste0("./Autobackups/abandoned ", today, ".csv")))
}

# Backup the aurora_queue.xlsx and taxonomy_queue.xlsx files on launch with daily time stamps
x <- file.copy(from = "./Upload/aurora_queue.xlsx", to = (paste0("./Autobackups/aurora_queue ", today(), ".xlsx")), overwrite = TRUE)
y <- file.copy(from = "./Taxonomy/taxonomy_source.xlsx", to = (paste0("./Autobackups/taxonomy_source ", today(), ".xlsx")), overwrite = TRUE)

# Tidy up memory ============================
# Removing temporary objects and tables from app's memory
# Constants (defined above) used instead of some objects
rm(t)
rm(x)
rm(y)
rm(i)
rm(last.date)
rm(today)
rm(template.cols)
rm(tab.cols)
rm(sp_needs)
# rm(default.cols) # 🚨 If removed, app crashes as loadprimarydata() can't find default.cols. Constants not helping?
# it must be getting called somewhere?
rm(srqpath)
rm(srqsheet)
