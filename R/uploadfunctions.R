# uploadfunctions.R
# Grant Abernethy and Felix Zareie-Vaux
# Date: 2023.08.06

# This is an R script for the Aurora application

# This function:
# 1. Reads the Excel upload file
# 2. Prepares it (removes extra header rows, adds missing columns, formats types)
# 3. Backs it up
# 4. Updates the relevant tables in memory
# 5. Saves updated tables to disk
# 6. Shows notifications in Shiny
#
# Parameters:
# - constants: list containing srqpath, srqsheet, and template.cols
# - table_mapping: vector of table names (e.g., c("table_SampleTracking", "table_Sequencing", ...))
# - fpath: reactive expression in Shiny that returns a directory path

upload_new_samples <- function(constants, table_mapping, fpath) {
  # Read Excel file ====
  dupload <- read_excel(
    path = constants$srqpath,
    sheet = constants$srqsheet,
    col_types = "text" # Forces R not to assume any columns are logical
  ) %>%
    mutate_all(as.character) %>% # Needed to prevent error combining columns with different formats (e.g. character, numeric, 'double')
    filter(!is.na(sample_accession)) %>% # The first row has example data in it; using "is.na status" to prevent na's being silently dropped
    bind_rows(constants$template.cols) # Adds all the other missing columns, no matter what columns or column order is read in

  # Remove 'grey instruction row' if present ====
  # Remove first non-header row (i.e. grey cells used to indicate spreadsheet usage)
  if (substr(dupload[1, 1], 1, 20) == "universal identifier") { # grey cells identified using text in column A
    dupload <- dupload[-1, ]
  }

  # Backup uploaded rows before munge-proofing ====
  # Backup the uploaded rows before removing anti-munge protection
  write_csv(dupload,
    file = "./Autobackups/Uploaded.csv",
    col_names = TRUE, append = TRUE
  )

  # Reverse munge protection & format ====
  dupload <- dupload %>%
    mungeReverse() %>%
    formatDataTables()

  # Loop through mapped tables and insert/update ====
  for (i in table_mapping) {
    # Remove "duplicate" column if exists
    table_i <- get(i) %>%
      select(-any_of(c("duplicate")))

    # Match dupload columns to existing table columns
    x <- colnames(table_i)
    aa <- dupload %>%
      select(all_of(x)) %>%
      mutate(rowsums = rowSums(!is.na(.))) %>%
      filter(rowsums > 1) %>% # sample_accession will always be there, so rowsums = at least 1.
      select(-"rowsums") %>%
      distinct()

    if (nrow(aa) > 0) {
      if (i == "table_SampleTracking") {
        # Try safe upsert by unique key
        tryIsolates <- try(
          ti <- rows_upsert(table_i, aa, by = "sample_accession")
        )

        if (inherits(tryIsolates, "try-error")) {
          toastr_error("NOT UPLOADED -- Possibly duplicate sample accession",
            position = "bottom-left"
          )
          return()
        } else {
          assign("table_SampleTracking", ti, envir = .GlobalEnv)
          saveRDS(table_SampleTracking, file = paste0(fpath(), "table_SampleTracking.rds"))
        }
      } else {
        # Append and deduplicate for other tables
        # Use bind_rows not rows_upsert because we can have duplicate entries per sample_accession
        ti <- bind_rows(table_i, aa) %>%
          distinct()

        assign(i, ti, envir = .GlobalEnv)
        saveRDS(ti, file = paste0(fpath(), i, ".rds"))
      }
    }
  }

  # Notify user ====
  toastr_success("Records Uploaded", position = "bottom-left")
}


# Action upload ====
actionUpload <- function(dupload) {
  for (i in table_mapping) {
    table_i <- get(i) %>%
      select(-any_of(c("duplicate")))
    x <- colnames(table_i)
    aa <- dupload %>%
      select(all_of(x)) %>%
      mutate(rowsums = rowSums(!is.na(.))) %>%
      filter(rowsums > 1) %>% # sample_accession will always be there, so rowsums = at least 1.
      select(-"rowsums") %>%
      distinct()
    if (nrow(aa) > 0) { # proceed if aa is not empty
      # treat table_SampleTracking differently to the other, because we need to preserve the unique index 'sample_accession' if (i == 1) {
      if (i == "table_SampleTracking") {
        # try() and then discontinue with a message if error, possibly caused by non-unique index
        tryIsolates <- try(
          ti <- rows_upsert(table_i, aa, by = "sample_accession")
        )
        if (class(tryIsolates)[1] == "try-error") {
          toastr_error("NOT UPLOADED -- Possibly duplicate sample accession", position = "bottom-left")
          return()
        } else {
          assign("table_SampleTracking", ti, envir = .GlobalEnv)
          saveRDS(table_SampleTracking, file = paste0(fpath, "table_SampleTracking.rds"))
        }
      } else {
        # for all tables except table_SampleTracking:
        # bind_rows not rows_upsert because we can have duplicate entries per sample_accession
        ti <- bind_rows(table_i, aa) %>%
          distinct()
        assign(i, ti, envir = .GlobalEnv)
        saveRDS(ti, file = paste0(fpath(), i, ".rds"))
      }
    }
  }
}