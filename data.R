library(osmdata)
library(sf)
library(tmap)
library(tidyverse)
library(googledrive)
library(googlesheets4)

our_streets <- c("Lansdown", "Brickrow", "Church Street", "King Street")
road_types <- c("secondary", "tertiary", "unclassified", "residential")

# local1 <- osmdata::getbb("Lansdown, Stroud", featuretype = "road", format_out = "matrix", limit = 1)

# manual bbox
local_bb <- matrix(c(-2.2184, 51.7453, -2.2090, 51.7490),
                   nrow = 2, ncol = 2,
                   dimnames = list(
                     c("x", "y"),
                     c("min", "max")
                   ))

local_houses <- osmdata::opq(bbox = local_bb) %>% 
  add_osm_feature(key = "building") %>% 
  osmdata_sf() %>% 
  pluck("osm_polygons") %>% 
  filter(addr.street %in% our_streets) %>% 
  filter(!building %in% c("commercial", "retail")) %>% 
  select(1:11)

lh_num <- local_houses %>% filter(!is.na(addr.housenumber))
lh_name <- local_houses %>% filter(is.na(addr.housenumber)) %>% filter(!is.na(addr.housename))

local_roads <- osmdata::opq(bbox = local_bb) %>% 
  add_osm_feature(key = "highway") %>% 
  osmdata_sf() %>% 
  pluck("osm_lines") %>% 
  filter(name %in% our_streets)
  # filter(highway == "tertiary")
  

tmap_mode("view")
tmap_options(
  # basemaps = NULL
  basemaps = "Stamen.TonerBackground"
)

qtm(lh_num, text = "addr.housenumber", text.size = 0.5, fill = "orange") +
  qtm(lh_name, text = "addr.housename", text.size = 0.5, fill = "orange") +
  qtm(local_roads, lines.col = "orange", lines.lwd = 2, text = "name", text.size = 0.7)


local_houses %>%
  sf::st_drop_geometry() %>% 
  readr::write_csv("local_houses.csv")

googledrive::drive_put(media = "local_houses.csv")
