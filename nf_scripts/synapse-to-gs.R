library(googlesheets)
library(synapser)
library(dplyr)
##this script assumes you have settled your table's schema already

##authenticate with synapse and google sheets
synLogin()
gs_auth()

synapse_to_gs <- function(tableId){

  ##create query and a title
  query <- sprintf("SELECT * FROM %s", tableId)
  title <- sprintf("annotation_%s", Sys.time())

  ##get view data
  tab <- synTableQuery(query)$asDataFrame() %>% mutate_all(as.character)

  ##create a google sheet with view contents
  sheet <- gs_new(title, input = tab)

  ##open the sheet and edit
  browseURL(sheet$browser_url)
  
  return(list("title"=title, "sheet"=sheet, "tab" = tab, "tableId" = tableId))
}

gs_to_synapse <- function(syn_to_gs){
  
  ##retrieve the updated sheet
  gs <- gs_title(syn_to_gs$title)
  
  tab_new <- gs_read(gs, col_types = readr::cols(.default = "c"))
  ##filter for only changed rows
  tab_diff <- dplyr::setdiff(tab_new, syn_to_gs$tab) 

  ##upload back to view
  table <- Table(syn_to_gs$tableId, tab_diff)
  table <- synStore(table)
}

foo <- synapse_to_gs("<fv_id>")
gs_to_synapse(foo)
