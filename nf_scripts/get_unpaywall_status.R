library(httr)
library(jsonlite)
library(tidyverse)
library(synapser)

##OA API, requires email
your_email <- "robert.allaway@sagebionetworks.org"
doi <- "10.1126/science.aba3758"
  
get_unpaywall_status <- function(your_email, doi){
  
  query_path <- glue::glue("https://api.unpaywall.org/v2/{doi}?")
  
  req <- GET(
    url = query_path,
    query = list(
      email = your_email
      )
  )
  
  response <- content(req, as = "text", encoding = "UTF-8") %>% 
    fromJSON(flatten = TRUE) 
  
  is_oa <- pluck(response, "is_oa")
  oa_status <- pluck(response, "oa_status")
  
  if(is_null(is_oa)){
    is_oa <- NA
  }
  
  if(is_null(oa_status)){
    oa_status <- NA
  }
  
  
 tribble(
    ~doi, ~is_oa, ~oa_status,
    doi, is_oa, oa_status
  )
    
}


dois <- synTableQuery("select doi from syn16857542")$asDataFrame()

dfs <- lapply(dois$doi, function(x) get_unpaywall_status(your_email = your_email, doi = x))

dfs_df <- bind_rows(dfs)
