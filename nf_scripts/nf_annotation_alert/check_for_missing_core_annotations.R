library(synapser)
library(rlang)
library(dplyr)
library(mailR)

synLogin()

get_missing <- function(x, df = df){
  length(df[x][is.na(df[x])])
}

annotators <- c("robert.allaway@sagebionetworks.org", "jineta.banerjee@sagebionetworks.org", "sara.gosline@sagebionetworks.org")

check_study_stats <- function(portal_files_table, which_studies = NULL, required_annotations, annotation_filter = NULL){
  
  if(!is.null(which_studies)){
    query <- paste0('select * from ', portal_files_table," where studyId in ('", paste0(which_studies, collapse = "','"),"')")
  }else{
    query <- paste0('select * from ', portal_files_table)
  }
  foo <- synTableQuery(query)$asDataFrame()
  
  if(!is.null(annotation_filter)){
    filt <- rlang::parse_expr(annotation_filter)
    # message("filter statement: `", filt, "`.")
    foo <- foo %>% filter(!!filt)
  }
    
 missing <- lapply(unique(foo$benefactorId), function(x){
    df <- filter(foo, benefactorId == x)
    # print(paste0("study: ", x, " - ", unique(df$studyName)))
    bar <- sapply(required_annotations, get_missing, df=df)
  })
 
 missing <- plyr::ldply(missing) %>% mutate(benefactorId = unique(foo$benefactorId)) 
 missing
}

required_annotations <- c("resourceType","fileFormat", "fundingAgency", "studyName", "studyId", "assay", "dataType")

bar <- check_study_stats(portal_files_table = "syn16858331",
                         required_annotations = required_annotations[1:5])

bar_filt <- check_study_stats(portal_files_table = "syn16858331",
                   required_annotations = required_annotations[6:7],
                  annotation_filter = "resourceType == 'experimentalData'")

tbl<- bar %>%
   full_join(bar_filt) %>% 
  group_by(benefactorId) %>% 
  mutate(total = sum(fileFormat,fundingAgency,assay,dataType,resourceType, na.rm = T)) %>% 
  ungroup() %>% 
  arrange(desc(total)) %>% 
  filter(total>0)

n_studies <- nrow(tbl)

tbl <-  mutate(tbl, assignee=sample(annotators,n_studies, replace = T))

for(i in annotators){
  
  data <- filter(tbl, assignee == i)
  
  data %>% write.csv(. ,file = "table1.csv", row.names = F)
  
  foo <- paste0("('", paste0(data$benefactorId, collapse = "\',\'"), "')")
    
  send.mail(from="nf.osi.workflow@gmail.org",
          to=i,
          subject=paste0("Annotation assignment for ",date(),""),
          body=sprintf('see attached csv for assignments by benefactorId. or, run synapse query to get your annotation fileview: SELECT * FROM syn16858331 where benefactorId in %s', foo),
          attach.files = "table1.csv",
          smtp=list(host.name = "smtp.gmail.com",
                    port = 465,
                    user.name = "nf.osi.workflow@gmail.com",
                    passwd = "XFl48Idf9!EzBBmz",
                    ssl = T),
          authenticate = T,
          send = T,
          html = T)
}
