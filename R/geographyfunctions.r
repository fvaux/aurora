# geographyfunctions.r ====
# Felix Zareie-Vaux
# Date: 2023.08.06

# This is an R script for the Aurora application

#' Geography helper functions
#'
#' Internal helper functions used by the Geography page of the Aurora Shiny app.
#'
#' These functions help plot the spatial distribution of samples on maps.
#'
#' @keywords internal
NULL

# Prepare map data ====
#' Prepare Map Data
#'
#' Prepares sample geographic data for mapping within the Aurora application.
#' The function selects relevant metadata columns, converts coordinate and
#' environmental fields to numeric format, removes records without valid
#' latitude and longitude values, and applies jitter to overlapping
#' coordinates to improve visualisation on interactive maps.
#'
#' When multiple samples share identical coordinates, a small random offset
#' is applied to avoid marker overlap. The jitter magnitude can be adjusted
#' by modifying the internal value used in the function.
#'
#' @param report_data A data frame containing sample metadata including
#' geographic coordinates and associated environmental information.
#'
#' @return A data frame containing cleaned map-ready data with additional
#' columns:
#' \describe{
#'   \item{point_count}{Number of samples sharing identical coordinates}
#'   \item{jitter_lat}{Latitude adjusted with jitter when duplicates occur}
#'   \item{jitter_long}{Longitude adjusted with jitter when duplicates occur}
#' }
#'
#' @details
#' Jitter is applied only when duplicate coordinate pairs are detected.
#' The default jitter magnitude (±0.0005 degrees) corresponds to
#' approximately ±50 metres.
#'
#' @export
#'
#' @examples
#' map_data <- prepare_map_data(report_data)
prepare_map_data <- function(report_data) {
  # Select table and columns
  map_data <- report_data %>%
    select(
      sample_accession, project, species_binomial, provenance_date, political_country, political_state,
      geographic_region, geographic_subregion, sample_location, sample_point, substrate,
      lat1, long1, lat2, long2, depth1, depth2, altitude1, altitude2
    ) %>%
    #
    #     # Assign marker colors
    #     mutate(marker_color = case_when(
    #       is.na(sequencing_status) ~ "blue",
    #       sequencing_status == "Pass" ~ "gold",
    #       sequencing_status == "Fail" ~ "red",
    #       TRUE ~ "grey"
    #     )) %>%

    # Convert coordinates and other numeric columns to numeric
    mutate(across(
      c(lat1, long1, lat2, long2, depth1, depth2, altitude1, altitude2),
      as.numeric
    )) %>%
    # Keep only rows with valid lat/long
    filter(!is.na(lat1) & !is.na(long1))

  # Count duplicates
  coord_counts <- map_data %>%
    count(lat1, long1, name = "point_count")

  # Join back
  map_data <- map_data %>%
    left_join(coord_counts, by = c("lat1", "long1"))

  # Apply jitter to duplicates
  # ⚠️ 0.0005 corresponds to approximately ±50 m; users can change to customise app
  set.seed(42) # reproducibility
  map_data <- map_data %>%
    mutate(
      jitter_lat = ifelse(point_count > 1, lat1 + runif(n(), -0.0005, 0.0005), lat1),
      jitter_long = ifelse(point_count > 1, long1 + runif(n(), -0.0005, 0.0005), long1)
    )

  return(map_data)
}

# Render map ====
#' Render Interactive Map
#'
#' Creates an interactive geographic map using the `leaflet` package.
#' Sample locations are displayed as circle markers with informative
#' pop-up metadata describing each sample.
#'
#' The map automatically centres on the mean latitude and longitude
#' of the provided dataset.
#'
#' @param map_data A data frame produced by \code{prepare_map_data()},
#' containing geographic coordinates and metadata.
#'
#' @param basemap Character string specifying the leaflet tile provider.
#' Defaults to `"Esri.WorldTopoMap"`. Any provider available through
#' \code{leaflet::providers} can be used.
#'
#' @return A \code{leaflet} interactive map widget.
#'
#' @export
#'
#' @examples
#' map_data <- prepare_map_data(report_data)
#' rendermap(map_data)
rendermap <- function(map_data, basemap = "Esri.WorldTopoMap") {
  leaflet(data = map_data) %>%
    addProviderTiles(providers[[basemap]]) %>%
    addCircleMarkers(
      ~jitter_long, ~jitter_lat,
      popup = ~ paste(
        "<strong>Sample:</strong>", sample_accession, "<br>",
        "<strong>Species binomial:</strong>", paste0("<i>", species_binomial, "</i>"), "<br>",
        "<strong>Sample date:</strong>", provenance_date, "<br>",
        "<strong>Politcal location:</strong>", paste0(political_country, ", ", political_state), "<br>",
        "<strong>Geographic region:</strong>", geographic_region, "<br>",
        "<strong>Geographic subregion:</strong>", geographic_subregion, "<br>",
        "<strong>Sample location:</strong>", sample_location, "<br>",
        "<strong>Sample point:</strong>", sample_point, "<br>",
        "<strong>Lat long 1:</strong>", paste0(lat1, ", ", long1), "<br>",
        "<strong>Depth 1:</strong>", depth1, "<br>",
        "<strong>Altitude 1:</strong>", altitude1
      ),
      radius = 5, color = "red", fillOpacity = 0.7
    ) %>%
    setView(
      lng = mean(map_data$long1, na.rm = TRUE),
      lat = mean(map_data$lat1, na.rm = TRUE),
      zoom = 2
    )
}