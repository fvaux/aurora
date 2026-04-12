# storagefunctions.r
# Grant Abernethy and Felix Zareie-Vaux
# Date: 2023.08.06

# This is an R script for the Aurora application

#' Storage helper functions
#'
#' Internal helper functions used by the Storage tab of the Aurora Shiny app.
#'
#' These functions help to track the storage of samples and nucleic acid extractions.
#'
#' @keywords internal
NULL

# Generate storage histogram ====
#' Generate Storage Histogram
#'
#' Creates a stacked histogram showing counts of samples grouped by a
#' specified storage unit and project. The output is an interactive
#' Plotly bar chart.
#'
#' This function is designed for use in the Aurora application to
#' visualise the distribution of samples across different storage
#' units (e.g., freezers, boxes, shelves) and projects.
#'
#' @param data A data frame containing storage metadata.
#' @param unit_col Character string specifying the column name
#' representing the storage unit (x-axis grouping).
#' @param project_col Character string specifying the column name
#' representing project identifiers used for colour grouping.
#' @param title_x Character string used as the x-axis label.
#' @param title_y Character string used as the y-axis label.
#'
#' @return A Plotly stacked bar chart.
#'
#' @details
#' The function counts the number of observations for each combination
#' of storage unit and project before plotting the results.
#'
#' @export
#'
#' @examples
#' make_storage_histogram(
#'   data = storage_data,
#'   unit_col = "storage_unit",
#'   project_col = "project",
#'   title_x = "Storage unit",
#'   title_y = "Number of samples"
#' )
make_storage_histogram <- function(data, unit_col, project_col, title_x, title_y) {
  data %>%
    count(!!sym(unit_col), !!sym(project_col)) %>%
    plot_ly(
      x = ~ get(unit_col),
      y = ~n,
      color = ~ get(project_col),
      type = "bar"
    ) %>%
    layout(
      barmode = "stack",
      xaxis = list(title = title_x),
      yaxis = list(title = title_y)
    )
}

# Generic Plotly Sankey generator for storage hierarchy ====
#' Generate Storage Hierarchy Sankey Diagram
#'
#' Creates an interactive Sankey diagram representing hierarchical
#' relationships between storage levels (e.g., facility → freezer →
#' rack → box). The diagram shows the flow of samples through the
#' hierarchy using aggregated counts.
#'
#' This function is designed for use within the Aurora application to
#' visualise storage organisation and sample distribution across
#' multiple hierarchical levels.
#'
#' @param data A data frame containing storage hierarchy metadata.
#' @param level1 Character string specifying the highest storage level
#' (e.g., facility or building).
#' @param level2 Optional character string specifying the second
#' storage level (e.g., freezer).
#' @param level3 Optional character string specifying the third
#' storage level (e.g., rack or shelf).
#' @param level4 Optional character string specifying the fourth
#' storage level (e.g., box or container).
#'
#' @return A Plotly Sankey diagram visualising hierarchical storage flow.
#'
#' @details
#' The function dynamically constructs node and link structures from the
#' provided columns. Missing values are replaced with `"Unknown"` so that
#' incomplete metadata can still be represented in the diagram.
#'
#' Node indices are converted to zero-based indexing to comply with the
#' Plotly Sankey specification.
#'
#' @export
#'
#' @examples
#' make_storage_sankey(
#'   data = storage_data,
#'   level1 = "facility",
#'   level2 = "freezer",
#'   level3 = "rack",
#'   level4 = "box"
#' )
make_storage_sankey <- function(data, level1, level2 = NULL, level3 = NULL, level4 = NULL) {
  # Filter valid levels
  levels <- c(level1, level2, level3, level4)
  levels <- levels[!is.null(levels)]

  # Subset to relevant columns
  df <- data %>%
    select(all_of(levels)) %>%
    # Use as.factor() for better node handling and replace_na
    mutate(across(everything(), ~ replace_na(as.character(.), "Unknown")))

  # Build a single list of all unique node names
  nodes <- data.frame(name = unique(unlist(df)), stringsAsFactors = FALSE)

  # Helper to create link data between two adjacent levels
  make_links <- function(from_col, to_col) {
    # Group and count to get total flow between nodes
    df %>%
      # Use `count` to get the aggregated flow
      count(!!sym(from_col), !!sym(to_col)) %>%
      # Match the names to the global node index (0-based)
      mutate(
        source = match(!!sym(from_col), nodes$name) - 1,
        target = match(!!sym(to_col), nodes$name) - 1,
        value = n # The count 'n' is the flow value
      ) %>%
      select(source, target, value)
  }

  # Build all link pairs
  links <- list()
  for (i in seq_len(length(levels) - 1)) {
    links[[i]] <- make_links(levels[i], levels[i + 1])
  }

  # Bind all links together and sum duplicate links
  links <- bind_rows(links) %>%
    group_by(source, target) %>%
    summarise(value = sum(value), .groups = "drop")

  # Create Sankey plot
  p <- plot_ly(
    type = "sankey",
    orientation = "h",
    node = list(
      label = nodes$name,
      pad = 15,
      thickness = 20,
      line = list(color = "darkgrey", width = 0.5),
      color = "rgba(0, 123, 255, 0.5)"
    ),
    link = list(
      source = links$source,
      target = links$target,
      value = links$value,
      color = "rgba(160,160,160,0.4)"
    )
  ) %>%
    layout(
      title = "Storage hierarchy Sankey diagram",
      font = list(size = 12)
    )

  return(p)
}