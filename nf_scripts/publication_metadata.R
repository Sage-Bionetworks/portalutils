library(tidyverse)
library(easyPubMed)
##read in publication data
data <- read_csv("example_publications_table.csv") 

##function that uses a doi 
##(other search terms, such as PMID, PMCID, etc will also work as input but will error if retrieve >1 record )
##and gets journal,author, title, year, pmid, and formats for NF Data Portal
##if not using doi, you'll need to rename the output of this function (column DOI) to join your dataset

# doi <- '10.3390/genes11050477'

get_portal_formatted_publication_data <- function(doi){
  print(doi)

  pmids <- get_pubmed_ids(doi) ##query pubmid for doi
  if(pmids$Count == 0){ ##if no records found, return vector of NAs
    print('nothing found for doi')
    return(c("title"=NA, "journal"=NA, "author"=NA, "year"=NA, "pmid" = NA, "doi"=doi))
  }else{ ##otherwise look for all data
  pmids <- fetch_pubmed_data(pmids, format = "xml", retmax = 1) 
  
  pmids_df <- pmids %>% 
    article_to_df
  
  ##extract author, collapse using | for portal data
  author <- pmids_df %>% tidyr::unite(name, firstname, lastname, sep = " ")
  author <- author$name %>% str_c(., collapse = " | ")
  
  author_list <- pmids_df %>% tidyr::unite(name, firstname, lastname, sep = " ") %>% 
    pluck('name') %>% str_c(., collapse = '","')
  author_list <- glue::glue('["{author_list}"]') 
  
  ##extract other metadata
  ##journal names are not stored on pubmed in title case, so let's do that
  journal <- pmids_df$journal %>% unique %>% tools::toTitleCase(.)
  
  ##title case not typically used for scientific publications
  title <- pmids_df$title %>% unique
  
  
  ## default function doesn't get accurate publication date, but rather the listing date. use different function to get publication year:
  year <- custom_grep(pmids, tag = "PubDate")[1] %>% str_extract(., "<Year>\\d+") %>% str_extract('\\d+')
  
  pmid <- pmids_df$pmid %>% unique
  
  if(length(journal)>1 | length(title)>1 | length(year)>1 | length(author)>1 | length(pmid)>1){
    print("one to many mappings detected - manually curate")
  }else{
    #return metadata
    return(c("title"=title, "journal"=journal, "author"=author, "author_list" = author_list, "year"=year, "pmid" = pmid, "doi"=doi))
  }
}
}

##run the function on full list of dois
res <- lapply(data$doi, get_portal_formatted_publication_data) %>% plyr::ldply(.)

##remove old columns from data and join new ones on DOI
data <- data %>% select(-title, -journal, -author, -year, -pmid, -author_list) %>% left_join(res) %>% distinct()

##then, manually curate any remaining data and upload via webui or upload programatically 
##in particular, journal names are typically not cleanly stored on pubmed

write_csv(data, "example_publications_table_output.csv", na = "")


