library(readr)
library(brazilmaps)
library(dplyr)
library(sf)
library(here)
library(ggplot2)

library(spdep)

df_ideb_score <- here("data", "df_ideb_score.csv") %>% read_csv()

counties_map <- get_brmap("City") 

ideb_counties_map <- counties_map %>%
  left_join(df_ideb_score, by = c("City" = "county_id"))

ideb_counties_map_queen_weights <- ideb_counties_map %>%
  filter(ideb_score_status == "Observado") %>%
  group_by(ideb_publication_year) %>%
  group_modify(~get_ideb_spatial_lag(.x)) %>%
  ungroup()

ideb_counties_map_queen_weights %>%
  ggplot() +
  geom_sf(aes(geometry = geometry, fill = ideb_score_lag),
          colour = "transparent", size = 0.1) +
  scale_fill_continuous(type = "viridis") +
  facet_wrap(~ideb_publication_year) +
  theme(panel.grid = element_line(colour = "transparent"),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

