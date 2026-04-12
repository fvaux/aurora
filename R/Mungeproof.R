# Mungeproof
# Grant Abernethy
# Date: 2023.01.26

# This is an R script for the Aurora application
# These functions assist with protecting the data in the app from corruption in Excel and text editors

# mungeproof ====
#' mungeProof
  #' paste a "_" in front of every item in a data frame, to stop excel from munging it after export to .csv.
  #' Excel is used as a convenient way to apply bulk data changes outside of R.
  #' (the csv is fine upon creation, but if double clicked on desktop, the .csv will almost always open in excel...)
  #' excel 'munging' includes changing dates from UTI standard format to excel specific (e.g 43356 days);
  #' changing anything that looks like a date to a date, which is done inconsistently;
  #' changing long serial numbers to scientific notation (which risks loss of trace-ability of serial number); 
  #' changing numbers stored as text (intentionally) to numbers

  #' paste a "_" in front of every item forces everything to text as far as excel is concerned.
  #' to reverse anti-munging, use mungeReverse() 

  #' @param inp a tibble or dataframe intended for export to .csv
  #' @return the input tibble or dataframe with every data as text format with/without "_" prefixed.
  #' @examples 
  # mungeproof:  "2004-04-03" or date format 2004-04-03 becomes "_2004-04-03"
 
  mungeProof <- function(inp) {
   inp <- inp %>% 
     mutate(
       across(.fns = as.character),  
       across(.fns = function(x) paste0("_", x))
     )
    return(inp)
  }
  
#' mungeReverse
#' Simple function to to reverse 'anti-munging' by mungeProof(). i.e. remove leading underscores on data
#' also change text "NA" generated in excel to R's NA value, and excel sourced attributes
#' @param inp a tibble or dataframe re imported after export to from .csv
#' @return the input tibble or dataframe with every data as text format without leading "_" and "NA" -> NA
#' @examples "NA" is changed to NA; "_2004-04-03" becomes text format "2004-04-03" 
#' (check: other uses of '_' might also be removed)

  mungeReverse <- function(inp) {
   inp <- inp %>% 
     mutate(
       across(.fns = as.character),
       across(.fns = ~ str_replace(., "^_", "")), #^ ensures that only underscores at the start of entries are removed
       across(.fns = ~ na_if(., "NA")),
       across(.fns = ~ na_if(., ""))
     )
   attr(inp, "spec") <- NULL
  return(inp)
  }
