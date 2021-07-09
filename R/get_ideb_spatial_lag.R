library(spdep)

get_ideb_spatial_lag <- function(df_ideb) {
  
  ideb_queen_weights <- df_ideb %>%
    poly2nb() %>%
    nb2listw(zero.policy = TRUE)
  
  vct_ideb_spatial_lag <- list(ideb_score_lag = lag.listw(ideb_queen_weights,
                                                          df_ideb$ideb_score, NAOK = TRUE))
  
  mean_ideb_score <- mean(df_ideb$ideb_score, na.rm = TRUE)
  
  mean_ideb_score_lag <- mean(vct_ideb_spatial_lag$ideb_score_lag, na.rm = TRUE)
  
  
  df_ideb_spatial_lag <- bind_cols(df_ideb, vct_ideb_spatial_lag) %>%
    mutate(moran_status = case_when((ideb_score_lag > mean_ideb_score_lag) & (ideb_score > mean_ideb_score) ~ "AA",
                                    (ideb_score_lag < mean_ideb_score_lag) & (ideb_score < mean_ideb_score) ~ "BB",
                                    (ideb_score_lag > mean_ideb_score_lag) & (ideb_score < mean_ideb_score) ~ "BA",
                                    (ideb_score_lag < mean_ideb_score_lag) & (ideb_score > mean_ideb_score) ~ "AB",
                                    TRUE ~ "NS"))
  
  return(df_ideb_spatial_lag)
  
}

ideb_counties_map_queen_weights <- ideb_counties_map %>%
  filter(ideb_score_status == "Observado") %>%
  group_by(ideb_publication_year) %>%
  group_modify(~get_ideb_spatial_lag(.x)) %>%
  ungroup()
