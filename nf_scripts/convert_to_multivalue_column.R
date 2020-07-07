library(tidyverse)

vec_to_array <- function(input){
  collapsed_input <- glue::glue_collapse(input, '","') 
  glue::glue('["{collapsed_input}"]')
}

path_to_csv <- "~/Downloads/Job-114069012019390077046156744.csv"
dataframe <- readr::read_csv(path_to_csv)

convert_to_listed_col <- function(dataframe, column_to_convert, new_column, old_sep){
  new_col <- rlang::sym(new_column)
  col_to_conv <- rlang::sym(column_to_convert)
  listed_data <- dataframe %>% 
    mutate(!!new_col := str_split(!!col_to_conv, pattern = old_sep)) %>% 
    mutate(!!new_col := sapply(!!new_col, trimws)) %>% 
    mutate(!!new_col := sapply(!!new_col, vec_to_array)) %>% 
    mutate(!!new_col := case_when(!!new_col == '["NA"]' ~ "",
                                  !!new_col != '["NA"]' ~ !!new_col))
}

res <- convert_to_listed_col(res,
                             column_to_convert = "studyId", 
                             new_column = "studyId_list",
                             old_sep = "\\|")

write_csv(res, "~/Downloads/updated_pub_table.csv", na = "")        

