library(synapser)
library(rlang)
library(dplyr)
library(mailR)

synLogin()

get_missing <- function(x, df = df){
  length(df[x][is.na(df[x])])
}

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
    
 missing <- lapply(unique(foo$studyId), function(x){
    df <- filter(foo, studyId == x)
    # print(paste0("study: ", x, " - ", unique(df$studyName)))
    bar <- sapply(required_annotations, get_missing, df=df)
  })
 
 names(missing) <-unique(foo$studyName)
 missing <- plyr::ldply(missing) %>% mutate(studyId = unique(foo$studyId), studyName = .id) %>% select(-.id) 
 missing
}

required_annotations <- c("resourceType","fileFormat", "fundingAgency", "assay", "dataType")

bar <- check_study_stats(portal_files_table = "syn16858331",
                         required_annotations = required_annotations[1]) %>% 
  filter(!is.na(studyName), !is.na(studyId))

bar_filt <- check_study_stats(portal_files_table = "syn16858331",
                  required_annotations = required_annotations,
                  annotation_filter = "resourceType == 'experimentalData'")  %>% select(-resourceType)

tbl<-full_join(bar,bar_filt) %>%
  group_by(studyId) %>% 
  mutate(total = sum(fileFormat,fundingAgency,assay,dataType,resourceType, na.rm = T))

library(mailR)

send.mail(from="nf.osi.workflow@gmail.org",
          to="robert.allaway@sagebionetworks.org",
          subject="Annotation Alert!",
          body="PFA the desired document",
          smtp=list(host.name = "smtp.gmail.com",
                    port = 465,
                    user.name = "nf.osi.workflow@gmail.com",
                    passwd = "XFl48Idf9!EzBBmz",
                    ssl = T),
          authenticate = T,
          send = T)


