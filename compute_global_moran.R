ideb_counties_map_queen_weights %>%
  group_by(ideb_publication_year) %>%
  drop_na() %>%
  summarise(global_moran_index = cor(ideb_score, ideb_score_lag, method = "pearson"))

mean_ideb_score <- mean(ideb_counties_map_queen_weights$ideb_score, na.rm = TRUE)

mean_ideb_score_lag <- mean(ideb_counties_map_queen_weights$ideb_score_lag, na.rm = TRUE)

ideb_counties_map_queen_weights %>%
  group_by(ideb_publication_year) %>%
  mutate(moran_status = case_when((ideb_score_lag > mean_ideb_score_lag) & (ideb_score > mean_ideb_score) ~ "AA",
                                  (ideb_score_lag < mean_ideb_score_lag) & (ideb_score < mean_ideb_score) ~ "BB",
                                  (ideb_score_lag > mean_ideb_score_lag) & (ideb_score < mean_ideb_score) ~ "BA",
                                  (ideb_score_lag < mean_ideb_score_lag) & (ideb_score > mean_ideb_score) ~ "AB",
                                  TRUE ~ "NS"))



df_subset <- ideb_counties_map %>%
  filter(ideb_publication_year == 2019,
         ideb_score_status == "Observado") 

weights_vct <- df_subset %>%
  poly2nb() %>%
  nb2listw(zero.policy = TRUE)

lagged_vct <- lag.listw(weights_vct,
                        df_subset$ideb_score, NAOK = TRUE)

moran(x = df_subset$ideb_score, 
      listw = weights_vct,
      n =length(df_subset$ideb_score),
      S0 = Szero(weights_vct),
      NAOK = TRUE, zero.policy = TRUE)
