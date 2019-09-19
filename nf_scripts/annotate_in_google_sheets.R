library(googlesheets)
library(synapser)
synLogin()
gs_auth()

##this script assumes you have settled your table's schema already

tableId <- '<fileview id>'
query <- sprintf("SELECT * FROM %s", tableId)
title <- sprintf("annotation_%s", Sys.time())

tab <- synTableQuery(query)$asDataFrame()

gs_new(title, input = tab)

## go to google drive, open, make changes

gs <- gs_title(title)
tab_new <- gs_read(gs)

table <- Table(tableId, tab_new)
table <- synStore(table)
