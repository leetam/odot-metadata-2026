library(keyring)
library(dplyr)
library(tidyr)
library(httr)
library(jsonlite)


kb <- keyring_unlock("work_keys")

locations <- GET("https://api.odot.state.or.us/tripcheck/TrafficDetector/Inventory",
                 add_headers(
                   "Cache-Control" = "no-cache",
                   "Ocp-Apim-Subscription-Key" = kb$get("odot_ttip")
                 )
)

locations_text <- content(locations, as = "text")
locations_df <- fromJSON(locations_text)

tdi_location <- locations_df[['traffic-detector-list']][['location']]
tdi_detector_station <- locations_df[['traffic-detector-list']][['detector-station']]

# TDI - Stations
tdi_stations <- bind_cols(tdi_location, tdi_detector_station)

# TDI - Detectors
tdi_detectors <- unnest(tdi_stations, 'roadway-detector-list', keep_empty = TRUE)

# TDI - Ramps
# rename location-id because can't have two columns with the same name
tdi_stations_r <- rename(tdi_stations, "location_id" = "location-id")
tdi_ramps <- unnest(tdi_stations_r, 'ramp-list')

saveRDS(tdi_stations, "data/tdi_stations.rds")
saveRDS(tdi_detectors, "data/tdi_detectors.rds")
saveRDS(tdi_ramps, "data/tdi_ramps.rds")
