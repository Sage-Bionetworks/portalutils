#this script largely adapted from textmineR vignette
#https://cran.r-project.org/web/packages/textmineR/vignettes/b_document_clustering.html

library(tidyverse)
library(textmineR)
library(synapser)
synLogin()

##query the study table
studies <- synTableQuery("select * from syn16787123")$filepath %>% 
  readr::read_csv(.) %>% 
  select(-relatedStudies)


##create a document object using the study summaries
dtm <- CreateDtm(doc_vec = studies$summary,
                 doc_names = studies$studyId,
                 ngram_window = c(1,2),
                 stopword_vec = c(stopwords::stopwords("en"),
                                  stopwords::stopwords(source = "smart")),
                 lower = T,
                 remove_punctuation = T,
                 remove_numbers = F,
                 verbose = F,
                 cpus = 4)

tf_mat <- TermDocFreq(dtm)

tfidf <- t(dtm[ , tf_mat$term ]) * tf_mat$idf

tfidf <- t(tfidf)

csim <- tfidf / sqrt(rowSums(tfidf * tfidf))

csim <- csim %*% t(csim)

cdist <- as.dist(1 - csim)

hc <- hclust(cdist, "ward.D")

#break into 20 clusters - this probably should be changed for smaller or larger numbers of studies
#I was targeting ~3-4 related studies per cluster, this seemed to work fairly well 
clustering <- cutree(hc, 20)

plot(hc, main = "Hierarchical clustering of NF Study Summaries",
     ylab = "", xlab = "", yaxt = "n")

rect.hclust(hc, 20, border = "red")


p_words <- colSums(dtm) / sum(dtm)

cluster_words <- lapply(unique(clustering), function(x){
  rows <- dtm[ clustering == x , ]
  
  # for memory's sake, drop all words that don't appear in the cluster
  rows <- rows[ , colSums(rows) > 0 ]
  
  colSums(rows) / sum(rows) - p_words[ colnames(rows) ]
})

cluster_summary <- data.frame(cluster = unique(clustering),
                              size = as.numeric(table(clustering)),
                              top_words = sapply(cluster_words, function(d){
                                paste(
                                  names(d)[ order(d, decreasing = TRUE) ][ 1:5 ], 
                                  collapse = ", ")
                              }),
                              stringsAsFactors = FALSE)

cluster_summary

similar_studies <- clustering %>% 
  as_tibble(rownames = "studyId") %>% 
  group_by(value) %>%
  summarise(relatedStudies = toString(studyId)) %>% ##currently the portals parse a comma-separated list.
  ungroup()

ids <- clustering %>% 
  as_tibble(rownames = "studyId") %>% 
  left_join(similar_studies) %>% 
  select(-value)

studies <- left_join(studies, ids)

##write out and inspect, update studies table interactively
##currently the portals parse a comma-separated list.
##when portals eventually support parsing of stringLists, probably better to use those.
write_csv(studies, "relatedStudies.csv", na = '')
