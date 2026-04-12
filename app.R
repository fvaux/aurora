# Aurora, version 1 - Hopelessly homeless
# Date: 2025.04.03

# Developers: Grant Abernethy and Felix Zareie-Vaux
# Please cite: PUBLICATION DETAILS AND DOI HERE

# About Aurora ====
# Aurora is a free, open-source laboratory information management system (LIMS)
# This is an R Shiny application, operated using RStudio

# Launch the app in RStudio using 'Run App' button above this pane.
# On launch, the app will appear within an RStudio window or your desktop browser (i.e. 'Run External' under 'Run App')
# You can run the application by clicking within a GUI launched within RStudio or your desktop browser

# Aurora R file structure
# Aurora operates using typical app, global, server and UI R scripts for R Shiny apps
# In addition, many functions are separated in .R files saved in the R folder of the app

# All R scripts are annotated
# roxygen2 type documentation is provided for all functions (except a few simple error messages)
# Annotations marked with ⚠️ indicate a warning or a note regarding user customisation of the app
# Annotations marked with 🚨 indicate a known issue or bug
# Annotations marked with 🌱 indicate sections of code noted for future development

# Run the application ====
shinyApp(ui = ui, server = server) # Run this command to launch the Aurora app


# Development to do list ====

## General tasks ====
# Update/add to Example Data to ensure all columns demonstrated

# Check all library packages are required

# Check backup features (and update folder and file names?)

## Time data ====
# Update formatDataTables.R to process:
# sample_hour (0 to 23, no negative numbers)
# sample_minute (0 - 59, no negative numbers)
# Then make 'provenance_time' column combining sample_hour and sample_minute

## bslib theme ====
# Change to bslib theme <-- PAUSED
# 🚨 Have tried this, but rending of side panel (e.g. filtering options) on Filter tab is failing under bslib
# Don't want to fix with CSS overrides
# ⚠️ When bslib applied, use sidebarLayout to render table parallel with sidebar on Search and Edit tabs (works once implemented)

## Move boxes tab ====
# Replace with 'batch edit' tab

## Geography tab ====
# Move summary table production to geographyfunctions.r?

# Add drop-down menu for changing colours of points on map? (red, orange, yellow, green, cyan, blue, black, white)

## Report tab and reports ====
# Finish Report tab (pivot summary table, general table, map, timeline)

# Search tab function to restrict data in other edits <-- DONE - using Filter Tab
# Report needs to use "report_data" <-- DONE
# Users select samples using filter tab <-- DONE
# "report_table" saves that search to global <-- DONE
# Need separate R files for plotly functions <-- DONE
# UI to select markdown template (has to be a test if plot is null, go and make it) <-- DONE
# Put generated plots in a reactive value called reportItems e.g. reportItems$plot1 <-- DONE
# Then use that reactive value in the reports <-- DONE

#  ⚠️ Need to check order of operations/how report_data formed. 
# e.g. Had to  add date formation into generate_export_data(), instead of relying on launch's own getdate()
# Also, this step means that date columns are in different order to default.cols 

#  🚨 report_data does not have taxonomy information for the Example data
# Maybe an order of operations issue with taxonomy on launch vs report_data?

# Need to move Report functions from server to reportfunctions.r, without breaking anything