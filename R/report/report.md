Análise dos resultados do IDEB da 1° à 5° série da rede pública entre
2005 e 2019
================

### Hipóteses primárias

1.  O desempenho do sistema educacional dos municípios brasileiros
    evoluiram em taxas de variação semelhantes

### Hipóteses secundárias

1.1 O desempenho no Sistema de Avaliação da Educação Básica (Saeb) ddos
municípios brasileiros evoluiram em taxas de variação semelhantes

1.2 O fluxo escolar dos municípios brasileiros evoluiram em taxas de
variação semelhantes

``` r
library(ggplot2)
library(ggridges)
library(brazilmaps)
library(sf)
```

    ## Linking to GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1

``` r
load_data_file <- here::here("R", "load_data.R")

source(load_data_file)
```

    ## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --

    ## v tibble  3.1.2          v dplyr   1.0.7     
    ## v tidyr   1.1.3          v stringr 1.4.0.9000
    ## v readr   1.4.0          v forcats 0.5.1     
    ## v purrr   0.3.4

    ## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

    ## here() starts at C:/Users/victo/Desktop/PROJ/Current/ideb

### Visão geral

``` r
df_ideb_score %>%
  filter(ideb_score_status == "Observado") %>%
  ggplot(aes(x = ideb_score, 
             y = ideb_publication_year, 
             fill = ideb_publication_year)) +
  geom_density_ridges(stat = "binline", alpha = 0.6) +
  theme_minimal() +
  theme(legend.position = "none")
```

    ## `stat_binline()` using `bins = 30`. Pick better value with `binwidth`.

    ## Warning: Removed 1896 rows containing non-finite values (stat_binline).

![](report_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

A partir do histograma acima percebe-ce uma tendência de crescimento do
desempenho escolar no território brasileiro, no entanto esse crescimento
vem acompanhado de maior variação nos dados observados. Outrossim, é
notório a presença de mais de uma moda na distribuição dessa variável
durante todo período de 2005 à 2019, embora neste último ano os valores
tendam para pontuações maiores.

``` r
counties_map <- get_brmap("City") 
```

``` r
ideb_counties_map <- counties_map %>%
  mutate(City = as.character(City)) %>%
  left_join(df_ideb_score,
            by = c("City" = "county_id"))
```

``` r
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
```

![](report_files/figure-gfm/unnamed-chunk-4-1.png)<!-- --> Segmentando
por município e por ano de publicação do IDEB é possível observar a
melhoria do desempenho do sistema educacional nos anos inicias do enisno
fundamental. Em 2005 existia uma predominância nacional da pontuação
entre 2.5 e 5 no IDEB, somente parte dos territórios da região
centro-oeste, sudeste e sul alcançaram indicadores acima de 5. Nos anos
sucessores, ocorre o espalhamento dessa pontuação, embora ainda restrito
às regiões supracitadas.No entanto, em contrapartida aos seus vizinhos,
os municípios Cearences ganham maior representatividade nessa faixa de
desempenho (entre 5 e 7.5), fenômeno este que se acentua a partir do
IDEB de 2011. Para uma visualização melhor dessa suposta discrepância do
desempenho do sistema educacional nos munícipios brasileiros, é
necessário obter uma medida suavizada baseada nos seus vizinhos. A fim
de alcançar esse objetivo utilizou-se a regra de contiguidade da rainha
de primeira ordem.

``` r
get_ideb_spatial_lag_dir <- here::here("R", "get_ideb_spatial_lag.R")

source(get_ideb_spatial_lag_dir)
```

    ## Carregando pacotes exigidos: sp

    ## Carregando pacotes exigidos: spData

    ## To access larger datasets in this package, install the spDataLarge
    ## package with: `install.packages('spDataLarge',
    ## repos='https://nowosad.github.io/drat/', type='source')`

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

    ## Warning in lag.listw(ideb_queen_weights, df_ideb$ideb_score, NAOK = TRUE): NAs
    ## in lagged values

``` r
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
```

![](report_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

### Referências

1.  <https://spatialanalysis.github.io/lab_tutorials/Applications_of_Spatial_Weights.html>

2.  <https://mgimond.github.io/Spatial/spatial-autocorrelation-in-r.html>