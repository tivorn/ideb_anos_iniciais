library(ggplot2)
library(ggridges)
library(brazilmaps)
library(sf)
library(spdep)

# Suaviza os dados 

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

load_data_file <- here::here("R", "load_data.R")

counties_map <- get_brmap("City") 

# Dados geográficos do {SAEB}

ideb_counties_map <- counties_map %>%
  mutate(City = as.character(City)) %>%
  left_join(df_ideb_score,
            by = c("City" = "county_id"))

source(load_data_file)


## Análise exploratória
## Relação da nota do SAEB com a pontuação do IDEB
## --->>>>>

## 1. Distribuição da pontuação no {SAEB - Nota média padronizada}
## Distribuição da pontuação no {SAEB - Matemática e Português}

df_ideb_score %>%
  filter(ideb_score_status == "Observado") %>%
  ggplot(aes(x = ideb_score, 
             y = ideb_publication_year, 
             fill = ideb_publication_year)) +
  geom_density_ridges(stat = "binline", alpha = 0.6) +
  theme_minimal() +
  theme(legend.position = "none")


## 2. Mapa da distribuição da pontuação

ideb_counties_map %>%
  filter(ideb_score_status == "Observado") %>%
  ggplot() +
  geom_sf(aes(fill = ideb_score),
          colour = "transparent", size = 0.1) +
  scale_fill_continuous(type = "viridis") +
  facet_wrap(~ideb_publication_year) +
  theme(panel.grid = element_line(colour = "transparent"),
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())

## 3. Mapa da pontuação suavizada pelos vizinhos

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

## 4. Diagrama de espalhamento de Moran

ideb_counties_map_queen_weights %>%
  ggplot(aes(x = ideb_score, y = ideb_score_lag)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_vline(xintercept = mean(ideb_counties_map_queen_weights$ideb_score, na.rm = TRUE),
             color = "red", linetype = "dashed") +
  geom_hline(yintercept = mean(ideb_counties_map_queen_weights$ideb_score_lag, na.rm = TRUE), color = "red", linetype = "dashed") +
  facet_wrap(~ideb_publication_year) +
  labs(y = "Média do desempenho no IDEB em relação aos vizinhos",
       x = "desempenho no IDEB")

## 5. Mapa de Moran

ideb_counties_map_queen_weights %>%
  group_by(ideb_publication_year) %>%
  drop_na() %>%
  summarise(global_moran_index = cor(ideb_score, ideb_score_lag, method = "pearson")) %>%
  ggplot(aes(x = ideb_publication_year, y = global_moran_index)) +
  geom_point() +
  geom_segment(aes(x = ideb_publication_year,
                   xend = ideb_publication_year,
                   y = .8,
                   yend = global_moran_index))


