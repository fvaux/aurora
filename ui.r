# This is the user interface code for the Aurora application
# Developers: Grant Abernethy and Felix Zareie-Vaux

ui <- fluidPage(
  useToastr(),

  # Header  ============================
  headerPanel(title = "", windowTitle = "Aurora LIMS"),

  # Banner title
  div(
    class = "navbar navbar-default", # Use navbar styling for a narrow look
    style = "background-color: #003366; color: white; 
                 margin: -20px -15px 10px -15px; 
                 padding: 5px 15px; 
                 text-align: left; 
                 min-height: 20px; 
                 line-height: 20px;",

    # Use an h3 tag, which is a good size for a smaller title
    tags$h3(
      "Aurora – laboratory information management system",
      style = "color: white; 
                     margin-top: 0px; 
                     margin-bottom: 0px; 
                     font-size: 18px; 
                     font-weight: normal; 
                     display: inline-block;"
    )
  ),

  # Main tabsetpanel ============================
  tabsetPanel(
    # Launch ============================
    # This it the launch/splash page tab, when the Aurora app is first opened
    # Launch contains information to explain the app to users
    # The tab also contains a toggle to switch between user data and the example data
    tabPanel(
      "Launch",
      h3("Welcome to Aurora! 🐧"), # Penguin is a reference to SY Aurora (see FAQs)

      # Top Row: Example data toggle & Citation Panel
      fluidRow(
        column(
          6,
          wellPanel(
            style = "background-color: #fffecf",
            h4("Toggle example data"),
            materialSwitch(
              inputId = "include_examples",
              label   = "Switch to example data",
              value   = FALSE,
              status  = "warn"
            ),
            p("If other tabs have been used prior to changing data, refresh them by selecting a button or preparing data"),
            p("Turning this toggle off and on will also refresh data without relaunching the app")
          )
        ),
        column(
          6,
          wellPanel(
            style = "background-color: #d7ecfc",
            h4("Credits"),
            p("Developed by Grant Abernethy and Felix Zareie-Vaux"),
            strong("Please cite this paper for the Aurora app:"),
            br(),
            tags$a(href = "https://www.doi.org/", "Zareie-Vaux F., Abernethy G.A. 2026. Aurora: a versatile, open-source laboratory information management system for biological samples using R Shiny. Journal of Open Source Software, XX, XX-XX. DOI.XXX.XXXX"),
            br(),
            strong("Access Aurora's Zenodo repository here:"),
            br(),
            tags$a(href = "https://www.doi.org/", "https://www.doi.org/")
          )
        )
      ),

      # Bottom Row: About Aurora & FAQs Panels
      fluidRow(
        column(
          6,
          wellPanel(
            style = "background-color: #FFFFFF",
            h4("About Aurora"),
            p("Aurora is a free, open-source laboratory information management system (LIMS), which operates using R, R Shiny and RStudio. The default version of the software is focused on the tracking and management of biological samples used for genetics research, but the app can be modified for any sample-based purpose."),
            strong("How it works ⚙️"),
            p("Aurora operates as a relational database, where all data is linked to a primary key: the sample accession. All entries require a sample accession, and it must be unique. There are dozens of other, optional fields (or columns) to record sample information. Aurora is designed to accommodate a very broad range of sample types. These fields are divided into several data tables (or data frames) that are managed separately. The division of these data tables reflects different aspects of sample information (e.g. classification or provenance) or stages of a laboratory workflow (e.g. sample storage, nucleic acid extraction, or sequencing)."),
            p("Samples are usually imported by uploading rows from a Microsoft Excel file, 'aurora_queue.xlsx', using the matching 'Upload' tabs in that file and the app. Samples can also be manually added using the app’s Edit tab, or by bulk importing data using the Bulk Edit tab (caution advised)."),
            p("When data is uploaded, the app conducts many formatting checks and provides warnings if there are errors (e.g. duplicate rows). The app conducts multiple automatic backups and ‘munge-proofing’ steps. Data is saved locally within the Aurora app’s folder. Permanent RDS files store all data as characters, and when launched, the app loads data into memory and transforms certain columns into appropriate formats (e.g. numeric)."),
            p("To avoid repetition and laborious editing, high-level taxonomic information (e.g. kingdom, phylum) is managed in another Excel file, 'taxonomy_source.xlsx', which acts as a reference table. Users can manually edit that taxonomic information, and we have provided utility R code if users want to retrieve data from GBIF."),
            p("Aurora operates using a small set of R Scripts and it only requires around a dozen commonly used R packages. Within RStudio, Aurora can be run within an R Studio window or run externally within a web browser. R is a powerful programming language for manipulating large data frames, making it highly suitable for a LIMS. The perennial popularity of R means that Aurora is likely to have considerable longevity. While Aurora is a Shiny web application, it is offline and does not attempt to connect with the internet or other databases."),
            strong("Using Aurora 👨🏼‍🔬💻👩🏽‍🔬"),
            p("The same instance of an Aurora app (and its database) can be accessed and edited simultaneously by multiple users. To achieve this, Aurora’s files folder and files must be saved in a shared location and each user must have R, R Shiny and R Studio installed with the required packages. Once set up, users can create desktop short-cuts to launch the app outside of RStudio."),
            p("Users can generally edit at the same time, although edits to the exact same table (or sample), or bulk edits, may cause changes to be overwritten. Users can also edit the aurora_queue.xlsx file simultaneously if permitted under local Excel or One Drive settings, and a laboratory workflow can be separated across Excel tabs to reduce editor conflicts (e.g. sample intake > DNA extraction > sequencing > pre-upload > upload > manual backup)."),
            strong("Customising Aurora ✨"),
            p("Since Aurora is open-source using R and R Shiny, any user competent with R can edit their version of the app freely. Users may want to add or remove columns or data tables, change export formats, produce new tabs or visualisations, or add security features."),
            p("Aurora is shared on GitHub with versions released using Zenodo. All of the R scripts are thoroughly annotated. To aid users, the launch page of Aurora includes answers to a list of frequently asked questions.️️️"),
            br(),
            h4("Data management in Aurora"),
            p("The diagram below shows an entity relationship diagram for Aurora. The different Data Tables are illustrated with colours matching the column header shading in the the aurora_queue.xlsx file. The numbers for Data Tables indicate their order in the Aurora Excel file. The taxonomy source table, managed in the taxonomy_source.xlsx file, is shown with a dashed boarder to indicate its separate, look-up relationship."),
            img(src = "AuroraEntityRelationships.png", style = "max-width: 100%; height: auto; display: block; margin: auto;"),
            br(),
            h4("Data flow and editing in Aurora"),
            p("The illustration below indicates how data flows in and out of Aurora, and how data can be edited."),
            img(src = "AuroraDataFlow.png", style = "max-width: 75%; height: auto; display: block; margin: auto;")
          )
        ),
        column(
          6,
          wellPanel(
            style = "background-color: #FFFFFF",
            h4("FAQs"),
            strong("What do all the columns mean? 📶"),
            p("The aurora_queue.xlsx file contains lots information to explain every column and Data Table. The example data also illustrate various ways the columns can be used for different types of data."),
            strong("How should samples be named? 🪲"),
            p("Every sample needs a unique sample accession."),
            p("A few recommendations:"),
            tags$ul(
              tags$li("Keep names short (<12 characters)"),
              tags$li("Avoid some characters (e.g. # * ,), although Aurora is designed to cope with common separators (e.g. - _ .)"),
              tags$li("Avoid sample accessions with a small number of fixed digits (e.g. 'A01' or 'Plant105') - this messes up sorting if the dataset grows"),
              tags$li("Avoid dates in sample accessions - these can be corrupted by Excel")
            ),
            strong("How does Aurora handle subsamples? 🧫"),
            p("Aurora is fundamentally focused on samples or specimens, which are represented by a unique sample accession. Different tissue clippings, separate microbial isolates, replicate samples, or other subsamples of the same organism or environmental matrix cannot share the exact same sample accession. Those samples can be named in a consistent fashion to indicate subsampling though (e.g. Sample1-1, Sample1-2; or Specimen1, Specimen1.r1, etc.)."),
            p("As a sample progresses along a laboratory workflow, it can be associated with multiple entries for other fields. For example, one sample accession may be associated with several extraction and sequencing accessions. However, it's important to remember these are not subsamples of the original specimen - they are multiple products derived from the same sample."),
            strong("Can Aurora keep track of external accessions? 🏛️"),
            p("Yes, there are several places to record external accessions. The Sample Tracking table has external_accession1 and 2 for any purpose (e.g. museums or reference collections), and the Sequencing table has multiple columns for database accessions. Many other aliases can be linked to sample accessions (e.g. storage labels or extraction accessions)."),
            strong("Can Aurora store nucleic acid sequence data? 🧬"),
            p("Aurora can store the metadata for sequenced samples, but it is intentionally designed not to store genetic sequences or data. Aurora can store multiple external accessions for molecular data stored in existing repositories (e.g. NCBI GenBank)."),
            strong("How is taxonomic information managed? 🌿"),
            p("Aurora is focused on family, genus, species and lower level classifications (e.g. subspecies), which are directly associated with samples (via the Sample Classification table). This information can be entered in the aurora_queue.xlsx when samples are uploaded and edited within the app."),
            p("Genus and species (i.e. the specific epithet) are uploaded separately, and Aurora automatically creates a binomial species column. This approach prevents extra spaces (etc.) in species names. The default version of Aurora does not keep track of taxonomic authorities."),
            p("High level taxonomic information (e.g. kingdom, phylum) is managed in a second Excel file: taxonomy_source.xlsx (located in the Taxonomy folder). This reference table is used to match high level taxonomic information to specimens with species, genus or family information. By using this reference table, Aurora reduces repetitive data entry and reduces opportunity for typos."),
            p("Users should update taxonomy_source.xlsx with new taxa as they are added to the database. Users can also add new columns for additional taxonomic levels as required (e.g. subphylum, infraclass or tribe). Users may want to retrieve taxonomic data from GBIF: we have provided code in the utility.r script to gather such data, and provided a large set of records in the taxonomy_GBIF.xlxs file."),
            p("High level taxonomic data does not appear in the Search and Edit tabs, since it is managed via the reference table. These fields can be exported though."),
            strong("What do the storage columns like 'unit' mean? 📦"),
            p("Aurora provides five hierarchical levels for storing samples and extractions:"),
            tags$ul(
              tags$li("Unit: freezer, fridge or cupboard"),
              tags$li("Shelf: shelf or drawer"),
              tags$li("Rack: rack, tower or crate for holding boxes"),
              tags$li("Slot: position of box, bag, folder or binder within rack"),
              tags$li("Box: box, bag, folder or binder"),
              tags$li("Plate: plate (e.g. tissue or PCR plate) or page within box"),
              tags$li("Well: plate well or position of sample/extraction in box or page")
            ),
            p("Units, shelves, racks, boxes and plates should have unique names to avoid confusion (the Storage tab can help reveal errors). Since shelves are nested within units (e.g. freezer shelves), their names should indicate these relationships."),
            p("The aurora_queue.xlsx file contains further information to explain all storage and extraction columns, and the example data illustrate different use cases."),
            strong("What's the difference between the extraction, PCR, library preparation, and sequencing tables? 🧮"),
            p("These tables follow the standard workflow of a genetics lab. Some columns are similar between the PCR and Library Preparation tables, but it is important to separate them as PCR is often used for screening samples prior to sequencing, and not all PCR testing needs subsequent sequencing."),
            p("For example, a lab might use a qPCR test to check for the presence of a pathogen (no sequencing required) among many samples, but then conduct genomic sequencing on a subset of those DNA extractions. Conversely, many genomics lab might sequence samples without any PCR testing."),
            tags$ul(
              tags$li("Extraction: information for DNA and RNA extractions from samples, and their storage"),
              tags$li("PCR: information on polymerase chain reaction (PCR) amplifications from samples, which may not lead to sequencing"),
              tags$li("Library Preparation: information on how samples were prepared for sequencing"),
              tags$li("Sequencing: information and results for the DNA and RNA sequencing of samples")
            ),
            strong("Does the colour of buttons mean anything? 🌈"),
            tags$ul(
              tags$li(tags$span(style = "color: blue;", "Blue: changes made to the permanent data that will be saved (in the .rds files)")),
              tags$li(tags$span(style = "color: green;", "Green: exporting data or reports")),
              tags$li(tags$span(style = "color: red;", "Red: uploading/importing or deleting data")),
              tags$li(tags$span(style = "color: orange;", "Orange: changes made to the temporary data in the app's memory (e.g. preparing or filtering data)")),
            ),
            strong("Does Aurora automatically backup data? 💾"),
            p("Yes, Aurora keeps multiple automatic backups in the Autobackups folder:"),
            tags$ul(
              tags$li("Aurora keeps track of the most recent save date and automatically backs up all data as a single, date-stamped .rds file if the most recent save is >2 days old"),
              tags$li("After >7 days, all abandoned samples (from the Edit tab) are backed up"),
              tags$li("On launch the app backs up the aurora_queue and taxonomy_source Excel files (one save per day)"),
              tags$li("On every upload from the aurora_queue.xlsx file (via the Upload tab), the app also creates a .csv backup of the uploaded entries"),
            ),
            p("We also recommend users periodically make manual backups of their Aurora app files (particularly if editing code) and use the 'Manual backup' tab in the aurora_queue.xlsx. Users can also export data via the Export or Bulk Edit tabs."),
            strong("How are dates managed? 📅"),
            p("Dates are uploaded in the aurora_queue.xlsx file using separate year, month and day columns. The Aurora app uses these columns to create a new date column with a standardised YYYY-MM-DD format (saved as characters). The separate year, month and day columns are retained but are listed last in each table. If any information is missing, the app fills in the gaps using the current year and 1st January. This approach permits missing data information and avoids date formatting errors (including automated changes in Excel)."),
            p("Dates should be updated using the separate year, month and day columns. Date columns will be automatically updated when the app is launched."),
            strong("Can Aurora store other time information? ⌚💀"),
            p("Aurora can record time in 24-hour hours and minutes for sample collection using sample_hour and sample_minute. On launch, Aurora converts these separate columns into the 24-hour HH:MM format."),
            p("For simplicity's sake, the default version of the app does not record seconds or times for othr columns. It also does not provide columns for things like the age estimates of fossils or radiometric dates."),
            strong("What is munge-proofing? 🧹"),
            p("When data is uploaded, Aurora conducts several 'munge-proofing' or transforming steps to prevent poorly formatted data (e.g. extra spaces or commas, and ways to handle missing data/NAs). When data is saved, it is kept in a 'munge-proof' format that inserts an underscore (_) before characters to prevent formatting errors. All data is saved as characters. When the app is launched, it loads the data into memory and transforms such columns into appropriate formats (e.g. numeric). Edits in memory can be sent back to the permanent files, which includes munge-proofing."),
            strong("What are the example data? 🦠🐟🦒"),
            p("Aurora and the aurora_queue.xlxs file are provided with >500 entries of fictitious example data. The example data indicate how fields, tables and tabs within the app can be used, and it can be useful for testing during app development."),
            p("Users can switch between user data and example data using the toggle on this page. Example data .RDS files are stored in a separate directory."),
            p("A copy of the example data is stored as a tab in the Aurora Excel file. If desired, that example data can be uploaded into Aurora and saved in the normal .RDS file location."),
            strong("How do I report an error with Aurora? 🚨"),
            p("Please raise a new issue in Aurora's GitHub repository (linked the to Zenodo archive)."),
            strong("How can I share my own customised version of Aurora? 🛠️"),
            p("We recommend modifying a forked version Aurora's GitHub repository. Please remember to cite the app and our paper (linked above). We're excited to see what people create!"),
            strong("Why is it called Aurora? ❄️🥶"),
            p("The app is named after SY Aurora, which was involved in multiple Antarctic rescue missions in the Heroic Age of Antarctic Exploration. Like the vessel, this app aims to save scientists and specimens lost in freezers!")
          )
        )
      )
    ),

    # Search ============================
    # Used to search for samples across Data Tables
    tabPanel(
      "Search",
      sidebarPanel(
        fluidRow(
          column(
            6,
            checkboxGroupInput("search_sp_need",
              label = "Preset searches:",
              choices = constants$search_sp_need,
              selected = NULL
            )
          ),
          column(
            6,
            checkboxGroupInput("search_box",
              label = "Select data tables:",
              choices = constants$table_names,
              selected = constants$table_names
            )
          )
        ),
        hr(style = "border-color: #3B71C5"),
        p("🔍 All data tables selected by default, untick to restrict search by table. Preset searches are mutually exclusive, and they may require all tables to be selected."),
        p("Use text box below to hide and reveal columns across tables."),
        selectInput("SelectCol",
          label = "Customise columns:",
          choices = constants$template.colnames,
          selected = template.selected,
          multiple = TRUE
        ),
        width = 2
      ),
      mainPanel(
        br(),
        DTOutput("search_table") # ⚠️ If want smaller text use: div(DTOutput("search_table"), style = list("font-size:85%"))
      )
    ),

    # Edit ============================
    # This tab is used to edit samples across Data Tables
    # Tab can also be used to add or abandon/delete samples
    tabPanel(
      "Edit",
      sidebarPanel(
        radioButtons("checkGroup",
          label = "Select Data Table:",
          choices = constants$table_names,
          selected = "Sample Tracking"
        ),
        hr(style = "border-color: #3B71C5"),
        p("📅 Change dates using year, month and day columns. Dates will automatically update when app is relaunched or data is toggled on the Launch tab."),
        hr(style = "border-color: #3B71C5"),
        actionBttn("addRowEdit",
          label = "Add Row",
          size  = "xs",
          style = "unite",
          color = "primary",
          icon  = icon("pen-square", lib = "font-awesome")
        ),
        sliderInput("dupRowEdit",
          label = NULL, #
          min = 0,
          max = 20,
          step = 1,
          value = 0
        ),
        h6("0: Add blank row(s) or"),
        h6("Duplicate 1 row x times"),
        hr(style = "border-color: #3B71C5"),
        actionBttn("SaveEdit",
          label = "Save Edits",
          size  = "sm",
          style = "unite",
          color = "primary",
          icon  = icon("save", lib = "font-awesome")
        ),
        hr(style = "border-color: #3B71C5"),
        p("Duplicates mode shows duplicate sample accession entries"),
        materialSwitch(
          inputId = "DuplicateMode",
          label   = "Duplicates Mode",
          value   = FALSE,
          status  = "primary"
        ),
        hr(style = "border-color: #3B71C5"),
        materialSwitch(
          inputId = "abandonlive",
          label   = "Enable Abandon",
          value   = FALSE,
          status  = "danger"
        ),
        actionBttn("AbandonEdit",
          label = "Abandon Samples",
          size  = "sm",
          style = "unite",
          color = "danger",
          icon  = icon("trash", lib = "font-awesome")
        ),
        width = 2
      ),
      mainPanel(
        br(),
        DTOutput("tbl") # ⚠️ if want smaller text use: div(DTOutput("tbl"), style = list("font-size:75%"))
      )
    ),


    # Batch Edit ====
    tabPanel(
      "Batch Edit (WIP)",
      
      fluidRow(
        
        column(
          3,
          
          selectInput(
            "batch_table",
            "Table",
            choices = names(table_mapping)
          ),
          
          selectInput(
            "batch_match_col",
            "Match column",
            choices = NULL
          ),
          
          selectInput(
            "batch_match_val",
            "Match value",
            choices = NULL
          ),
          
          selectInput(
            "batch_edit_col",
            "Column to edit",
            choices = NULL
          ),
          
          textInput(
            "batch_new_val",
            "New value"
          ),
          
          br(),
          
          actionButton(
            "batch_preview",
            "Preview changes"
          ),
          
          actionButton(
            "batch_apply",
            "Apply changes"
          ),
          
          br(),
          br(),
          
          textOutput("batch_rows_changed")
          
        ),
        
        column(
          9,
          DT::dataTableOutput("batch_preview_table")
        )
        
      )
    ),
    
    # Move Boxes ============================
    # This tab is for moving or renaming boxes
    tabPanel(
      "Move Boxes (WIP)",
      br(),
      column(
        3,
        wellPanel(
          h4("Move Box to Shelf (e.g. shelf or drawer):"),
          br(),
          selectInput("moveBoxSelect",
            label   = "Select Box",
            choices = values$boxChoices_samples,
          ),
          br(),
          selectizeInput("moveshelfdest",
            label = "Select/Create Shelf (e.g. shelf or drawer)",
            choices = values$shelfChoices_samples,
            options = list(create = TRUE)
          ),
          br(),
          actionBttn("moveBoxtoShelf",
            label = "Move Box",
            size = "sm",
            color = "primary",
            icon = icon("truck-moving", lib = "font-awesome")
          ),
        )
      ),
      column(
        3,
        wellPanel(
          h4("Rename a Box:"),
          br(),
          selectInput("moveBoxSelect2",
            label   = "Select Box",
            choices = values$boxChoices_samples
          ),
          br(),
          textInput("moveBoxRename",
            label = "Rename box:"
          ),
          br(),
          actionBttn("moveRenameBox",
            label = "Rename Box",
            size = "sm",
            style = "unite",
            color = "primary",
            icon = icon("pen-square", lib = "font-awesome")
          ),
        )
      ),
      column(
        3,
        wellPanel(
          h4("Rename a Shelf (e.g. shelf or drawer):"),
          br(),
          selectInput("moveShelfSelect",
            label   = "Select Shelf",
            choices = values$shelfChoices_samples
          ),
          br(),
          textInput("moveshelfRename",
            label = "Rename Shelf:"
          ),
          br(),
          actionBttn("moveRenameUnit",
            label = "Rename Unit",
            size = "sm",
            style = "unite",
            color = "primary",
            icon = icon("pen-square", lib = "font-awesome")
          ),
        )
      )
    ),

    # Bulk Edit ============================
    # Used to export and import each Data Table .rds file for manual bulk editing in Excel or a text editor
    # See Edit tab for editing smaller numbers of samples more safely
    tabPanel(
      "Bulk Edit",
      h3("Bulk edit"),
      fluidRow(
        column(
          6,
          wellPanel(
            p("Use this tab to export (and re-import) selected Data Tables as files for manual bulk editing in Excel or a text editor."),
            p("High level taxonomic information should be edited in the taxonomy_source.xlsx file - there's no need to bulk edit that data."),
            p("⚠️ Note that another user might save changes in Aurora in the meantime, causing edits to be overwritten. Notify other active users before conducting bulk edits."),
            radioButtons("UtilscheckGroup",
                         label = "Select Data Table:",
                         choices = constants$table_names
            ),
            actionBttn("UtilsExport",
                       label = "Export",
                       size = "sm",
                       style = "unite",
                       color = "success",
                       icon = icon("file-export", lib = "font-awesome")
            ),
            hr(style = "border-color: #3B71C5"),
            materialSwitch(
              inputId = "UtilsConfirm",
              label   = "Enable Import",
              value   = FALSE,
              status  = "danger"
            ),
            actionBttn("UtilsImport",
                       label = "Import",
                       size = "sm",
                       style = "unite",
                       color = "danger",
                       icon = icon("file-arrow-up", lib = "font-awesome")
            ),
          )
        )
      )
    ),
    
    # Upload ============================
    # This tab is used to upload/import samples from the 'Upload' tab in the aurora_queue.xlsx file
    tabPanel(
      "Upload",
      h3("Upload data"),
      fluidRow(
        column(
          6,
          wellPanel(
            p("Upload data from the aurora_queue.xlsx file"),
            p("(Samples are taken from the 'Upload' tab in that Excel spreadsheet, found in the Upload folder)"),
            p("Newly uploaded files should appear automatically. You may need to refresh a tab by pressing a button."),
            br(),
            actionBttn("Upload",
              label = "Upload",
              size = "lg",
              style = "unite",
              color = "danger",
              icon = icon("file-arrow-up", lib = "font-awesome")
            ),
            br(),
            br(),
            h4("If Upload fails... ⚠️"),
            tags$ul(
              tags$li("Failure may be due to duplicates in the sample tracking table. To check, use Duplicates Mode on the Edit Table tab in the Aurora app. Then abandon any duplicates, save, and restart Aurora and re-attempt upload."),
              tags$li("If there are no duplicates, check if the Upload tab in the aurora_queue.xlsx file has traces of data below your new samples (e.g. entries in lower rows in Excel - potentially with hidden characters)."),
              tags$li("You can also check the Dashboard tab to investigate if data has been added (or removed).")
            ),
          )
        )
      )
    ),

    # Export ============================
    # Used to export samples (or other data) in various formats
    tabPanel(
      "Export",
      h3("Export data"),
      fluidRow(
        column(
          6,
          wellPanel(
            p("Export data from Aurora in different file formats"),
            p("Prepare data first before selecting file to export."),
            actionBttn("generateData",
              label = "Prepare Data",
              size = "sm",
              style = "unite",
              color = "warn",
              icon = icon("refresh", lib = "font-awesome")
            ),
            hr(style = "border-color: #3B71C5"),
            h4("Export all samples 🪲⬇️"),
            p("Exports all data"),
            actionBttn("exportSamples",
              label = ".csv and .rds formats",
              size = "sm",
              style = "unite",
              color = "success",
              icon = icon("file-export", lib = "font-awesome")
            ),
            br(),
            hr(style = "border-color: #3B71C5"),
            h4("Export all sequenced samples 🧬⬇️"),
            p("Exports all data for sequenced samples"),
            actionBttn("exportSequenced",
              label = ".csv and .rds formats",
              size = "sm",
              style = "unite",
              color = "success",
              icon = icon("file-export", lib = "font-awesome")
            ),
          )
        )
      )
    ),

    # Dashboard ============================
    # Used to evaluate statistics tracking the Aurora database
    # i.e. how many samples (and other data) stored in the Aurora database
    # Can use plots to identify if significant uploads or deletions have occurred
    tabPanel(
      "Dashboard",
      h3("Dashboard"),
      fluidRow(
        column(
          6,
          wellPanel(
            p("Evaluate Aurora database using Dashboard"),
            actionBttn("generate_dashboard",
              label = "Refresh data",
              size = "sm",
              style = "unite",
              color = "warn",
              icon = icon("refresh", lib = "font-awesome")
            )
          )
        )
      ),
      h4("Accumulation of dated data (in memory):"),
      p("Shows the accumulation of dated samples and data (i.e. provenance, storage, extraction, library preparation, sequencing) over time, using each relevant date column"),
      p("Estimated based on data in Aurora app's memory, not Data Table .rds files"),
      plotlyOutput("accumulation_plot"),
      hr(style = "border-color: #3B71C5"),
      h4("Total contents of Data Tables over time (.rds files):"),
      p("Checking change in total number of entries for each data table (.rds file) over time (requires at least two time points)."),
      p("Increase indicates new samples uploaded, decrease increases samples deleted. Plot can be used to identify unintentional user errors (i.e. accidental uploads or deletions)"),
      plotlyOutput("tableTally1"),
      hr(style = "border-color: #3B71C5"),
      h4("Index purity:"),
      p("Checking if number of rows match across Data Tables (.rds files)"),
      p("table_SampleTracking exists to track changes in the Data Tables (it is not a sample Data Table)"),
      tableOutput("uniques.Taxonomy"),
    ),

    # Filter data ============================
    # Used to prepare and filter data (i.e. generates report_data)
    # report_data then used by storage, diversity, geography, timeline and report tabs
    tabPanel(
      "Filter",
      h3("Filter report data"),
      fluidPage(
        fluidRow(
          column(
            3,
            wellPanel(
              p("Filter and select data for Reporting"),
              p("The Filter tab provides data for the Storage, Diversity, Map and Report tabs, which are used to generate reports. None of these tabs edit the actual Aurora database."),
              p("⚠️ Use the Export tab to export full data from Aurora"),
              actionBttn("generateReportData",
                label = "Load data for reporting",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("refresh")
              ),
              hr(style = "border-color: #3B71C5"),
              uiOutput("multi_filter_ui")
            )
          ),
          column(
            9,
            h4("Filtered Data"),
            DTOutput("report_filtered_table")
          )
        )
      )
    ),

    # Storage ==============================
    # Used to visualise and assess the storage of samples and extractions in report_data
    # e.g. where are a project's samples kept, or what is stored in a particular freezer
    tabPanel(
      "Storage",
      h3("Storage overview"),
      fluidPage(
        fluidRow(
          column(
            3,
            wellPanel(
              p("Explore storage of samples and extractions in report data"),
              actionBttn("refresh_storage",
                label = "Refresh report data",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("refresh")
              ),
              br(),
              br(),
              actionBttn("generate_all_figs",
                label = "Generate tables and figures",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("chart-bar")
              )
            )
          ),
          column(
            9,
            tabsetPanel(
              tabPanel(
                "Samples",
                h4("Samples"),
                DTOutput("sample_storage_table"),
                hr(),
                plotlyOutput("sample_hist", height = "350px"),
                plotlyOutput("sample_sankey", height = "450px"),
                tags$hr(),
                h4("Inventory of all samples"),
                DTOutput("sample_inventory")
              ),
              tabPanel(
                "Extractions",
                h4("Extractions"),
                DTOutput("extract_storage_table"),
                hr(),
                plotlyOutput("extract_hist", height = "350px"),
                plotlyOutput("extract_sankey", height = "450px"),
                tags$hr(),
                h4("Inventory of all extractions"),
                DTOutput("extract_inventory")
              )
            )
          )
        )
      )
    ),

    # Diversity =========================================
    # Used to assess the taxonomic diversity of samples in report_data
    tabPanel(
      "Diversity",
      h3("Taxonomic diversity"),
      fluidPage(
        fluidRow(
          column(
            4,
            wellPanel(
              p("Explore the diversity of samples across across taxonomic levels in report data"),
              actionBttn(
                "refresh_diversity",
                label = "Refresh report data",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("refresh")
              ),
              br(),
              br(),
              selectInput(
                "x_tax_level", "Select primary taxonomic level (X axis)",
                choices = c("kingdom", "phylum", "class", "order", "family", "genus", "species_binomial"),
                selected = "phylum"
              ),
              selectInput(
                "color_tax_level", "Select secondary taxonomic level (sample groups/colouring)",
                choices = c("kingdom", "phylum", "class", "order", "family", "genus", "species_binomial"),
                selected = "class"
              ),
              actionBttn(
                "generate_diversity_plot",
                label = "Generate tables and figures",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("chart-bar")
              )
            )
          ),

          # Right Column (Outputs) - Structure is updated
          column(
            8,
            # 1. Plot first
            h4("Diversity Histogram"),
            plotlyOutput("diversity_plot"),
            tags$hr(), # Add a separator for better visual grouping

            # 2. Table second
            h4("Diversity Summary Table"),
            dataTableOutput("diversity_summary_table")
          )
        )
      )
    ),

    # Geography =========================================
    # Used to map and assess the spatial distribution of samples in report_data
    tabPanel(
      "Geography",
      h3("Geography"),
      fluidPage(
        # Controls and info panel
        fluidRow(
          column(
            12,
            wellPanel(
              p("View and summarise the geographic origin of samples in report data, and map samples with include latitude and longitude coordinates."),
              p("In the map, samples with identical coordinates have ~50 m of jitter added to separate points (click on a sample to check true coordinates)."),
              fluidRow(
                column(
                  4,
                  actionBttn(
                    "generate_data",
                    label = "Refresh map data",
                    size = "sm",
                    style = "unite",
                    color = "warning",
                    icon = icon("refresh")
                  ),
                  actionBttn(
                    "generate_map",
                    label = "Generate map and table",
                    size = "sm",
                    style = "unite",
                    color = "warning",
                    icon = icon("map-marked-alt")
                  )
                )
              ),
              fluidRow(
                column(
                  4,
                  br(),
                  selectInput(
                    "basemap_choice",
                    label = "Select basemap layer:",
                    choices = c(
                      "Esri.WorldTopoMap",
                      "Esri.OceanBasemap",
                      "Esri.WorldImagery",
                      "Esri.WorldStreetMap",
                      "OpenStreetMap.Mapnik"
                    ),
                    selected = "Esri.WorldTopoMap",
                    width = "100%"
                  )
                )
              )
            )
          )
        )
      ),

      # Map output
      fluidRow(
        column(
          12,
          h4("Map of Samples"),
          leafletOutput("map_samples", width = "100%", height = "600px")
        )
      ),
      tags$hr(),

      # Geography table
      fluidRow(
        column(
          12,
          h4("Summary of Samples per Sample Point"),
          dataTableOutput("geography_summary_table")
        )
      )
    ),

    # Timeline =========================================
    # Used to assess temporal variation for samples in report_data
    # Accumulation plots show the accumulation of data across the dated data tables over time
    # i.e. how many samples collected, stored, extracted, library prepared, and sequenced
    # Process plots show dated information per sample
    # i.e. shows how long for a sample to be collected, stored, extracted, library prepared, and sequenced
    tabPanel(
      "Timeline",
      h3("Timeline of sample processing"),
      fluidPage(
        fluidRow(
          column(
            2,
            wellPanel(
              p("Visualise time data for samples"),
              actionBttn(
                "refresh_timeline",
                label = "Refresh report data",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("refresh")
              ),
              br(),
              br(),
              actionBttn(
                "generate_timeline",
                label = "Generate figures",
                size = "sm",
                style = "unite",
                color = "warning",
                icon = icon("chart-line")
              )
            )
          ),
          column(
            10,
            h4("Accumulation of dated data"),
            p("Shows the accumulation of dated samples and data (i.e. provenance, storage, extraction, library preparation, sequencing) over time"),
            plotlyOutput("timeline_accumulation_plot", height = "600px"),
            tags$hr(),
            h4("Sample processing through time"),
            p("Each line represents one sample. Points show available dates for provenance, storage, extraction, library preparation, and sequencing"),
            plotlyOutput("timeline_process_plot", height = "600px")
          )
        )
      )
    ),

    # Report ======================================
    # Used to export reports using report_data
    # Reports can be interactive .html reports, Excel files or .html maps files
    # This is for exporting reports, for data export - see Export tab
    tabPanel(
      "Report",
      h3("Produce reports"),
      fluidPage(
        fluidRow(
          column(
            3,
            wellPanel(
              h4("Select content for report"),
              p("Choose tables and figures for exported reports"),
              uiOutput("select_tables_ui"),
              uiOutput("select_plots_ui"),
              hr(),
              hr(style = "border-color: #3B71C5"),
              h4("Export HTML report"),
              p("Export an interactive .html report"),
              textInput("report_title", "Edit report title", "Aurora Report"),
              # textInput("report_author", "Author", "Data Team"), # For adding author box
              actionBttn(
                "generate_report",
                label = "Generate .html report",
                style = "unite",
                color = "success",
                size = "sm",
                icon = icon("file-export")
              ),
              br(),
              hr(style = "border-color: #3B71C5"),
              h4("Export tables to Excel"),
              p("Export tables in an MS Excel file"),
              actionBttn(
                "export_selected_tables",
                label = "Export selected tables to Excel",
                style = "unite",
                color = "success",
                size = "sm",
                icon = icon("file-export"),
              ),
              br(),
              hr(style = "border-color: #3B71C5"),
              h4("Export .html map"),
              p("Export only the sample map within an interactive .html file"),
              actionBttn(
                "export_report_map",
                label = "Export map to .html",
                style = "unite",
                color = "success",
                size = "sm",
                icon = icon("file-export")
              ),
            )
          ),
          column(
            7,
            h4("Preview selected tables and figures"),
            uiOutput("report_preview_ui")
          )
        )
      )
    )
  )
) # end of UI fluidpage
