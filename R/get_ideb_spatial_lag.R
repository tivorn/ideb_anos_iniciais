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

get_pass_rate_spatial_lag <- function(df) {
  
  queen_weights <- df %>%
    poly2nb() %>%
    nb2listw(zero.policy = TRUE)
  
  vct_spatial_lag <- list(score_lag = lag.listw(queen_weights,
                                                df$mean_pass_rate, NAOK = TRUE))
  
  mean_mean_pass_rate <- mean(df$mean_pass_rate, na.rm = TRUE)
  
  mean_mean_pass_rate_spatial_lag <- mean(vct_spatial_lag$score_lag, na.rm = TRUE)
  
  
  df_spatial_lag <- bind_cols(df, vct_spatial_lag) %>%
    mutate(moran_status = case_when((score_lag > mean_mean_pass_rate_spatial_lag) & (mean_pass_rate > mean_mean_pass_rate) ~ "AA",
                                    (score_lag < mean_mean_pass_rate_spatial_lag) & (mean_pass_rate < mean_mean_pass_rate) ~ "BB",
                                    (score_lag > mean_mean_pass_rate_spatial_lag) & (mean_pass_rate < mean_mean_pass_rate) ~ "BA",
                                    (score_lag < mean_mean_pass_rate_spatial_lag) & (mean_pass_rate > mean_mean_pass_rate) ~ "AB",
                                    TRUE ~ "NS"))
  
  return(df_spatial_lag)
  
}

get_saeb_spatial_lag <- function(df_saeb) {
  
  saeb_queen_weights <- df_saeb %>%
    poly2nb() %>%
    nb2listw(zero.policy = TRUE)
  
  vct_saeb_spatial_lag <- list(saeb_score_lag = lag.listw(saeb_queen_weights,
                                                          df_saeb$saeb_score, NAOK = TRUE))
  
  mean_saeb_score <- mean(df_saeb$saeb_score, na.rm = TRUE)
  
  mean_saeb_score_lag <- mean(vct_saeb_spatial_lag$saeb_score_lag, na.rm = TRUE)
  
  
  df_saeb_spatial_lag <- bind_cols(df_saeb, vct_saeb_spatial_lag) %>%
    mutate(moran_status = case_when((saeb_score_lag > mean_saeb_score_lag) & (saeb_score > mean_saeb_score) ~ "AA",
                                    (saeb_score_lag < mean_saeb_score_lag) & (saeb_score < mean_saeb_score) ~ "BB",
                                    (saeb_score_lag > mean_saeb_score_lag) & (saeb_score < mean_saeb_score) ~ "BA",
                                    (saeb_score_lag < mean_saeb_score_lag) & (saeb_score > mean_saeb_score) ~ "AB",
                                    TRUE ~ "NS"))
  
  return(df_saeb_spatial_lag)
  
}
