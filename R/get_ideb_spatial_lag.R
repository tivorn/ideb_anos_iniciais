library(spdep)

get_ideb_spatial_lag <- function(df_ideb) {
  
  ideb_queen_weights <- df_ideb %>%
    poly2nb() %>%
    nb2listw(zero.policy = TRUE)
  
  vct_ideb_spatial_lag <- list(ideb_score_lag = lag.listw(ideb_queen_weights,
                                                          df_ideb$ideb_score, NAOK = TRUE))
  
  df_ideb_spatial_lag <- bind_cols(df_ideb, vct_ideb_spatial_lag)
  
  return(df_ideb_spatial_lag)
  
}

get_saeb_spatial_lag <- function(df_saeb) {
  
  saebqueen_weights <- df_saeb %>%
    poly2nb() %>%
    nb2listw(zero.policy = TRUE)
  
  vct_saeb_spatial_lag <- list(saeb_score_lag = lag.listw(saeb_queen_weights,
                                                          df_saeb$saeb_score, NAOK = TRUE))
  
  df_saeb_spatial_lag <- bind_cols(df_saeb, vct_saeb_spatial_lag)
  
  return(df_saeb_spatial_lag)
  
}

ideb_counties_map_queen_weights <- ideb_counties_map %>%
  filter(ideb_score_status == "Observado") %>%
  group_by(ideb_publication_year) %>%
  group_modify(~get_ideb_spatial_lag(.x)) %>%
  ungroup()
