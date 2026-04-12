# This is some extra R code to help with managing the Aurora app.
# These code snippets are NOT required to run the app
# Authors: Grant Abernethy and Felix Zareie-Vaux

# Load packages ==============================
# Load required R packages into library
library(readr)
library(dplyr)

# Load .csv, export as .rds ============================
# Import .csv
table_SampleTracking <- read_csv("table_SampleTracking.csv")
View(table_SampleTracking)

# Export .rds
saveRDS(table_SampleTracking,"table_SampleTracking.rds")

# Utilise GBIF Backbone Taxonomy ============================
# ⚠️ If users want, they can populate taxonomy_source.xlsx using the GBIF Backbone Taxonomy
# Can be downloaded here: https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c

# Unzip files and import the taxon.tsv file
# Define the path to the unzipped taxon.tsv file
# taxon_file <- "path_to_unzipped_folder/taxon.tsv" 
taxon_file <- "./Utility R scripts/Taxon.tsv"

# Read the taxon.txt file
taxon_data <- read_tsv(taxon_file, quote = "")

# Select and rename relevant columns to match your taxonomy_table structure
taxonomy_table <- taxon_data %>%
  select(
    kingdom = kingdom,
    phylum = phylum,
    class = class,
    order = order,
    family = family,
    genus = genus,
    species = specificEpithet
  ) %>%
  mutate(
    species_binomial = ifelse(!is.na(species) & !is.na(genus), paste(genus, species), NA)
  ) %>%
  select(kingdom, phylum, class, order, family, genus, species_binomial) %>%
  # Filter step 1: Must have at least one of family/genus/species_binomial
  filter(!(is.na(family) & is.na(genus) & is.na(species_binomial))) %>%
  # Filter step 2: If any of those three are present, require phylum/class/order to also be present
  filter(!is.na(phylum) & !is.na(class) & !is.na(order)) %>%
  # Filter step 3: Remove rows where genus contains digits (mainly bacteria)
  filter(!str_detect(genus, "[0-9]")) %>%
  # Keep only unique rows (to reduce size)
  distinct() %>%
  # Keep only one species per genus, preferring rows with species_binomial (to reduce size)
  group_by(genus) %>%
  arrange(is.na(species_binomial)) %>%  # non-NA first
  slice(1) %>%
  ungroup()

# Preview the first few rows
head(taxonomy_table)

# Save the taxonomy_table to a CSV file
write_csv(taxonomy_table, "taxonomy_table.csv")
# ⚠️ File is very large, likely need to trim down by adding additional filtering to code above
# ⚠️ Or users can manually curate Excel file
# ⚠️ Some taxa may contain illegal characters
# ⚠️ Based on code above, we have provided an Excel file called 'taxonomy_GBIF' if users want to copy rows across
