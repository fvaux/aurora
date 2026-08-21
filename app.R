# Aurora, version 0.1
# Date: 2026.08.21

# Developers: Grant Abernethy and Felix Zareie-Vaux
# GitHub: https://github.com/fvaux/aurora
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
# roxygen2 style documentation is provided for all functions (except a few simple error messages)
# Annotations marked with ⚠️ indicate a warning or a note regarding user customisation of the app
# Annotations marked with 🚨 indicate a known issue or bug
# Annotations marked with 🌱 indicate sections of code noted for future development

# Run the application ====
shinyApp(ui = ui, server = server) # Run this command to launch the Aurora app


# Development to do list ====
## Minor tasks before manuscript submission ====
# Check that launch page text and readme file for GitHub align with manuscript text
# Record quick youtube tutorial and add thumbnail link to GitHub readme

# Publish Zenodo release version of app (v1.0)
# Update date and version at top of this file to match GitHub

# If accepted: update publication details in this file and UI.

## Example data ====
# Update/add to Example Data to ensure all columns demonstrated (use AI)
# Generate Example data report and Excel file

## Shortcut ====
# Grant to make .bat Windows shortcut file
# Using SY Aurora vessel photo from Wikipedia/Wikicommons?

## Check for possible bugs ====
#  ⚠️ Need to check order of operations/how report_data formed. 
# e.g. Had to  add date formation into generate_export_data(), instead of relying on launch's own getdate()
# Also, this step means that date columns are in different order to default.cols 

#  🚨 report_data does not have taxonomy information for the ***Example data***
# Maybe an order of operations issue with taxonomy on report_data?