library(tidyverse)
library(here)
library(stringr)

dir_name <- here("raw_data")

file_name <- list.files(dir_name)

file_path <- str_glue("{dir_name}/{file_name}") 

raw_df_ideb <- readxl::read_excel(file_path, sheet = "IDEB P") %>%
  janitor::clean_names()

# County info ------------------------------------------------------------------

df_county_info <- raw_df_ideb %>%
  select(uf, codmun, municipio) %>%
  rename(county_id = codmun, county_name = municipio)

# Pass rate ------------------------------------------------------------

df_pass_rate <- raw_df_ideb %>%
  select(codmun, starts_with("txa")) %>%
  pivot_longer(cols = starts_with("txa"),
               names_to = "temp_var",
               values_to = "pass_rate") %>%
  filter(!str_detect(temp_var, "15")) %>%
  mutate(ideb_publication_year = str_sub(temp_var,
                                         start = 4, end = 7),
         elementary_school_nd_grade = str_sub(temp_var,
                                              start = 9)) %>%
  select(-temp_var) %>%
  rename(county_id = codmun)


# Performance index ------------------------------------------------------

df_performance_index <- raw_df_ideb %>%
  select(codmun, starts_with("ir")) %>%
  pivot_longer(cols = starts_with("ir"),
               names_to = "temp_var",
               values_to = "performance_index") %>%
  mutate(ideb_publication_year = str_sub(temp_var, 5)) %>%
  select(-temp_var) %>%
  rename(county_id = codmun)


# SAEB Score --------------------------------------------------------------------

df_saeb_score <- raw_df_ideb %>%
  select(codmun, starts_with("ns")) %>%
  mutate(across(starts_with("ns"), as.numeric)) %>%
  pivot_longer(cols = starts_with("ns"),
               names_to = "temp_var",
               values_to = "saeb_score") %>%
  mutate(ideb_publication_year = str_sub(temp_var, 3, 6),
         score_class = str_sub(temp_var, 7),
         score_class = case_when(score_class == "m" ~ "Matemática",
                                 score_class == "p" ~ "Português",
                                 score_class == "nmp" ~ "Nota média padronizada")) %>%
  select(-temp_var) %>%
  rename(county_id = codmun)


# IDEB Score --------------------------------------------------------------------

df_ideb_score <- raw_df_ideb %>%
  select(codmun, starts_with(c("proj", "ideb"))) %>%
  pivot_longer(cols = starts_with(c("proj", "ideb")),
               names_to = "temp_var",
               values_to = "ideb_score") %>%
  mutate(ideb_publication_year = str_sub(temp_var, 5),
         ideb_score_status = str_sub(temp_var, 1, 4),
         ideb_score_status = case_when(ideb_score_status == "ideb" ~ "Observado",
                                       ideb_score_status == "proj" ~ "Projetado")) %>%
  select(-temp_var) %>%
  rename(county_id = codmun)


