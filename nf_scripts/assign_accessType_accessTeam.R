library(reticulate)

import('synapseclient')

library(tidyverse)
synLogin()

fileview_id <- "syn16858331"

fv <- synTableQuery(sprintf("SELECT * FROM %s", fileview_id)) ##get fileview with all benefactorIds
tab <-as.data.frame(fv) ##get fileview with all benefactorIds

data_access_teams <- synTableQuery('SELECT * FROM syn20644235')$asDataFrame() %>% 
  filter(team != "273948") ##these are all the "primary" teams in the NF-OSI that grant data access (eg. not including special admin teams)

access_status <- sapply(unique(tab$benefactorId), function(x){
  ls <- synRestGET(paste0("/entity/",x,"/acl"))$resourceAccess %>% 
    data.table::rbindlist(.) ##query each unique benefactorId for list of teams that have access to it
  
  publicaccess <-  dplyr::filter(ls, principalId == 273948 & accessType == "DOWNLOAD") ##check for public access ("all registered users") to bfId
  team_access <-  dplyr::filter(ls, principalId %in% data_access_teams$team & accessType == "DOWNLOAD") ##check for team-based access to bfId

  
  if(nrow(publicaccess)==1){ ##if "all registered users" has download access, mark as OPEN and label "accessTeam" as 273948
    c("PUBLIC", "273948")
  }else if(nrow(team_access)==1){ ##if any of the team-based data access teams have downlad access, mark REQUEST ACCESS and label "accessTeam" as the team with access..
    c("REQUEST ACCESS", team_access$principalId)
  }else{
      c("PRIVATE", "") ##these conditions are filled, must be private 
    }
})

remove_cols <- T

if(all(!c("accessType","accessTeam") %in% colnames(tab))){
  schema <- synGet("syn16858331")
  newColumn <- synStore(Column(name = "accessType", columnType = "STRING", maximumSize = 20))
  newColumn2 <- synStore(Column(name = "accessTeam", columnType = "USERID", maximumSize = 20))
  schema$addColumns(c(newColumn, newColumn2))
  schema <- synStore(schema)
  remove_cols <- F
}

accessdf <- access_status %>%
  t %>% 
  as.data.frame %>% 
  rownames_to_column %>% 
  set_names(c("benefactorId","accessType", "accessTeam"))

if(remove_cols == F){
  tab_access <- tab %>% 
    left_join(accessdf)
}else{
  tab_access <- tab %>% 
    select(-accessType, -accessTeam) %>% 
    left_join(accessdf)
}

synStore(Table(fileview_id, tab_access))

