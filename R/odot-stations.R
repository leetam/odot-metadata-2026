library(dplyr)
library(tidyr)

#### TDInventory - Stations ####
tdi_stations <- readRDS("data/tdi_stations.rds")

# Remove "Construction" highways and bad locations and unneeded attributes
tdi_stations <- tdi_stations |>
  filter(
    `highway-name` != "Construction",
    latitude != -1.0
         ) |>
  select(
    -`roadway-detector-list`,
    - `ramp-list`
  )
# 376 stations in Traffic Detector Inventory


#### PORTAL - Stations ####
raw_portal_stations <- read.csv("data/portal_stations_202605.csv", stringsAsFactors = F)
portal_stations <- raw_portal_stations |>
  filter(
    agency == "ODOT",
    end_date == ""
  ) |>
  select(
    -station_geom,
    -segment_geom
  ) |>
# 407 ODOT stations in PORTAL
  
#### Stations in PORTAL not in TDINVENTORY ####
stations_notintdi <- portal_stations |>
  anti_join(tdi_stations, by = c("locationtext" = "location-name"))
