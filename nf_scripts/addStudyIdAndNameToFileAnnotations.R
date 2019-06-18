#'author : robert.allaway at sagebionetworks.org
#'
#'addStudyIdAndNameToFileAnnotations takes a portal Study Table - example: syn16787123 -
#'and annotates files with the studyName and studyId for that study.
#'
#'In order to do this the function requires 5 arguments:
#'study_table_id     : Synapse ID of the Study Table
#'study_name_col     : Name of the column in the Study Table that contains the Study Names
#'study_id_col       : Name of the column in the Study Table that contains the Study Synapse IDs
#'study_fileview_col : Name of the column in the Study Table that contains the Fileview IDs for each study
#'which_studies : editing the whole set of studies is prone to errors due to lack of access to subsets of files, etc. 
#'to specify a set of studies instead of the whole gamut, pass in a vector of studyIds here
#'

#'This function tests for the following conditions:
#'Each study must be a single row in the Study table
#'note - The fileviews can be empty if there is no data
#'Each fileview must be associated with only one study 
#'If studyId and studyName are in the fileview schemas - if not, it adds them
#'
#'This function does NOT test for:
#'Overlapping scopes between fileviews. 
#'Access to the data - you must have edit permission to all files within the study fileviews
#'
#'

library(synapser)
library(pbmcapply)
cores <- detectCores()
synLogin()

addStudyIdAndNameToFileAnnotations<-function(study_table_id, study_name_col, study_id_col, study_fileview_col, which_studies = NULL){
  
  if(!is.null(which_studies)){
  query <- paste0('select ', study_name_col,',',study_id_col,',',study_fileview_col,' from ',
                  study_table_id," where projectFileviewId is not null and ",study_id_col," in ('", paste0(which_studies, collapse = "','"),"')")
  }else{
    query <- paste0('select ', study_name_col,',',study_id_col,',',study_fileview_col,' from ',
                    study_table_id," where projectFileviewId is not null")
  }
  foo <- synTableQuery(query)$asDataFrame()
  
  if(nrow(foo) != length(unique(foo$projectFileviewId))){ ##check for a 1:1 mapping between studies and fileviews
    
    print("Need distinct fileview for each study!")
    
  }else if(nrow(foo) != length(unique(foo$id))){ ##check for all distinct study ids
    
    print("Need distinct study ids!")
    
  }else{
    
    lapply(foo$id, function(x){
      print(x)
      fv <- foo$projectFileviewId[foo$id == x]  ##get fileview id for study x
      name <- foo$projectName[foo$id == x]  ##get name for study x
      tryCatch({
      bar <- synTableQuery(paste0('select * from ',fv)) ##get fileview data for study x
      }, error=function(cond){
        print(paste0("check fileview, ",fv," - appears broken"))
      })
      df <- bar$asDataFrame()
      
      if(!c("studyId") %in% colnames(df)){ ##add studyId to fileview schema if not there already
        print("adding studyId to schema")
        schema <- synGet(fv)
        newcol1 <- synStore(Column(name = "studyId", columnType = "ENTITYID"))
        schema$addColumn(newcol1)
        schema <- synStore(schema)
      }
      
      if(!c("studyName") %in% colnames(df)){ ##add studyName to fileview schema if not there already
        print("adding studyName to schema")
        schema <- synGet(fv)
        newcol2 <- synStore(Column(name = "studyName", columnType = "LARGETEXT"))
        schema$addColumn(newcol2)
        schema <- synStore(schema)
      }
             
      if(nrow(df)>0){     ##check for files to annotate
        
      df$studyId <- x #add studyId to file annotations 
      df$studyName <- name ##ad studyName to file annotations
      try(synStore(Table(bar$tableId, df))) ##store new annotations for files for study x,
 
      }else{
        print(paste0("No files associated with project ", x, "."))
      }
    })
  }
}


#example:
addStudyIdAndNameToFileAnnotations(study_table_id = "syn16787123",
                                   study_name_col = "projectName",
                                   study_id_col = "id",
                                   study_fileview_col = "projectFileviewId",
                                   which_studies = c("syn11374337")) 
