library(tidyverse)
library(glue)
library(plotly)

ctf_base <- "rgba(126, 232, 250, {a})"
ntap_base <- "rgba(229, 140, 138, {a})"
gff_base <- "rgba(4, 67, 137, {a})"
nfri_base <- "rgba(237, 205, 107, {a})"
nih_base <- "rgba(128, 255, 114, {a})"
nfrp_base <- "rgba(255, 240, 124, {a})"

node_alpha <- 1

nodes <- list(
  "ctf" = list(
    id = 0, label = "CTF", color = glue(ctf_base, a = node_alpha)
  ),
  "ntap" = list(
    id = 1, label = "NTAP", color = glue(ntap_base, a = node_alpha)
  ),
  "gff" = list(
    id = 2, label = "GFF", color = glue(gff_base, a = node_alpha)
  ),
  "nfri" = list(
    id = 3, label = "NFRI", color = glue(nfri_base, a = node_alpha)
  ),
  "nih" = list(
    id = 4, label = "NIH", color = glue(nih_base, a = node_alpha)
  ),
  "nfrp" = list(
    id = 5, label = "NFRP", color = glue(nfrp_base, a = node_alpha)
  ),
  "studies" = list(
    id = 6, label = "Studies", color = "#e84855"
  ),
  "tools" = list(
    id = 7, label = "Tools", color = "#bbbbbc"
  ),
  "datasets" = list(
    id = 8, label = "Datasets", color = "#bbbbbc"
  ),
  "publications" = list(
    id = 9, label = "Publications", color = "#bbbbbc"
  ),
  "files" = list(
    id = 10, label = "Files", color = "#bbbbbc"
  ),
  "consortium_ntap_op" = list(
    id = 11, label = "NTAP Open Proposal", color = "#bbbbbc"
  ),
  "consortium_vri" = list(
    id = 12, label = "Vision Restoration Initiative", color = "#bbbbbc"
  ),
  "consortium_francis" = list(
    id = 13, label = "Francis Collins", color = "#bbbbbc"
  ),
  "consortium_gti" = list(
    id = 14, label = "Gene Therapy Initiative", color = "#bbbbbc"
  ),
  "consortium_cci" = list(
    id = 15, label = "Cell Culture Initiative", color = "#bbbbbc"
  ),
  "consortium_cnf" = list(
    id = 16, label = "cNF Initiative", color = "#bbbbbc"
  ),
  "consortium_synodos" = list(
    id = 17, label = "Synodos", color = "#bbbbbc"
  ),
  "consortium_dhart" = list(
    id = 18, label = "DHART-SPORE", color = "#bbbbbc"
  ),
  "consortium_pro" = list(
    id = 19, label = "Patient Reported Outcomes", color = "#bbbbbc"
  ),
  "consortium_nftc" = list(
    id = 20, label = "Neurofibromatosis Therapeutic Consortium", color = "#bbbbbc"
  )
)


link_alpha <- 0.4

links <- list(
  "ctf_studies" = list(
    src = nodes$ctf$id, tgt = nodes$consortium_synodos$id,
    color = glue(ctf_base, a = link_alpha),
    value = 7,
    label = "7 studies"
  ),
  "ctf_studies_3" = list(
    src = nodes$ctf$id, tgt = nodes$consortium_nftc$id,
    color = glue(ctf_base, a = link_alpha),
    value = 2,
    label = "2 studies"
  ),
  "ntap_studies" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_cnf$id,
    color = glue(ntap_base, a = link_alpha),
    value = 9,
    label = "9 studies"
  ),
  "ntap_studies_2" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_ntap_op$id,
    color = glue(ntap_base, a = link_alpha),
    value = 14,
    label = "14 studies"
  ),
  "ntap_studies_3" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_pro$id,
    color = glue(ntap_base, a = link_alpha),
    value = 4,
    label = "4 studies"
  ),
  "ntap_studies_4" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_cci$id,
    color = glue(ntap_base, a = link_alpha),
    value = 8,
    label = "8 studies"
  ),
  "ntap_studies_6" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_francis$id,
    color = glue(ntap_base, a = link_alpha),
    value = 9,
    label = "9 studies"
  ),
  "ntap_studies_7" = list(
    src = nodes$ntap$id, tgt = nodes$consortium_nftc$id,
    color = glue(ntap_base, a = link_alpha),
    value = 2,
    label = "2 studies"
  ),
  "gff_studies" = list(
    src = nodes$gff$id, tgt = nodes$consortium_vri$id,
    color = glue(gff_base, a = link_alpha),
    value = 11,
    label = "11 studies"
  ),
  "gff_studies_2" = list(
    src = nodes$gff$id, tgt = nodes$consortium_gti$id,
    color = glue(gff_base, a = link_alpha),
    value = 9,
    label = "9 studies"
  ),
  "nfri_studies" = list(
    src = nodes$nfri$id, tgt = nodes$consortium_francis$id,
    color = glue(nfri_base, a = link_alpha),
    value = 1,
    label = "1 studies"
  ),
  "nfrp_studies" = list(
    src = nodes$nfrp$id, tgt = nodes$studies$id,
    color = glue(nfrp_base, a = link_alpha),
    value = 0,
    label = "0 studies"
  ),
  "nih_studies" = list(
    src = nodes$nih$id, tgt = nodes$consortium_dhart$id,
    color = glue(nih_base, a = link_alpha),
    value = 4,
    label = "4 studies"
  ),
  "ctf_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(ctf_base, a = link_alpha),
    value = 7,
    label = "7 tools"
  ),
  "ntap_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(ntap_base, a = link_alpha),
    value = 8,
    label = "8 tools"
  ),
  "nfri_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(nfri_base, a = link_alpha),
    value = 0,
    label = "0 tools"
  ),
  "gff_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(gff_base, a = link_alpha),
    value = 0,
    label = "0 tools"
  ),  
  "nih_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(nih_base, a = link_alpha),
    value = 0,
    label = "0 tools"
  ),
  "nfrp_tools" = list(
    src = nodes$studies$id, tgt = nodes$tools$id,
    color = glue(nfrp_base, a = link_alpha),
    value = 0,
    label = "0 tools"
  ),
  "ctf_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(ctf_base, a = link_alpha),
    value = 5,
    label = "5 datasets"
  ),
  "ntap_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(ntap_base, a = link_alpha),
    value = 6,
    label = "6 datasets"
  ),
  "gff_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(gff_base, a = link_alpha),
    value = 0,
    label = "0 datasets"
  ),
  "nfri_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(nfri_base, a = link_alpha),
    value = 0,
    label = "0 datasets"
  ),
  "nih_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(nih_base, a = link_alpha),
    value = 0,
    label = "0 datasets"
  ),
  "nfrp_datasets" = list(
    src = nodes$studies$id, tgt = nodes$datasets$id,
    color = glue(nfrp_base, a = link_alpha),
    value = 0,
    label = "0 datasets"
  ),
  "ctf_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(ctf_base, a = link_alpha),
    value = 21,
    label = "21 publications"
  ),
  "ntap_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(ntap_base, a = link_alpha),
    value = 23,
    label = "23 publications"
  ),
  "nfri_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(nfri_base, a = link_alpha),
    value = 0,
    label = "0 publications"
  ),
  "gff_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(gff_base, a = link_alpha),
    value = 0,
    label = "0 publications"
  ),
  "nfrp_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(nfrp_base, a = link_alpha),
    value = 0,
    label = "0 publications"
  ),  
  "nih_publications" = list(
    src = nodes$studies$id, tgt = nodes$publications$id,
    color = glue(nih_base, a = link_alpha),
    value = 10,
    label = "10 publications"
  ),
  "ctf_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(ctf_base, a = link_alpha),
    value = 10580/1000,
    label = "10580 files"
  ),
  "ntap_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(ntap_base, a = link_alpha),
    value = 7940/1000,
    label = "7940 files"
  ),
  "nfri_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(nfri_base, a = link_alpha),
    value = 0,
    label = "0 files"
  ),
  "gff_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(gff_base, a = link_alpha),
    value = 0,
    label = "0 files"
  ),
  "nfrp_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(nfrp_base, a = link_alpha),
    value = 0,
    label = "0 files"
  ),  
  "nih_files" = list(
    src = nodes$studies$id, tgt = nodes$files$id,
    color = glue(nih_base, a = link_alpha),
    value = 664/1000,
    label = "664 files"
  ),
  "cci" = list(
    src = nodes$consortium_cci$id, tgt = nodes$studies$id,
    color = glue(ntap_base, a = link_alpha),
    value = 8,
    label = "8"
  ),
  "cnf" = list(
    src = nodes$consortium_cnf$id, tgt = nodes$studies$id,
    color = glue(ntap_base, a = link_alpha),
    value = 9,
    label = "9"
  ),
  "dhart" = list(
    src = nodes$consortium_dhart$id, tgt = nodes$studies$id,
    color = glue(nih_base, a = link_alpha),
    value = 4,
    label = "4"
  ),
  "francis" = list(
    src = nodes$consortium_francis$id, tgt = nodes$studies$id,
    color = glue(ntap_base, a = link_alpha),
    value = 9,
    label = "9"
  ),
  "gti" = list(
    src = nodes$consortium_gti$id, tgt = nodes$studies$id,
    color = glue(gff_base, a = link_alpha),
    value = 9,
    label = "9"
  ),
  "indie_ctf" = list(
    src = nodes$ctf$id, tgt = nodes$studies$id,
    color = glue(ctf_base, a = link_alpha),
    value = 6,
    label = "6"
  ),
  "indie_ntap" = list(
    src = nodes$ntap$id, tgt = nodes$studies$id,
    color = glue(nih_base, a = link_alpha),
    value = 1,
    label = "1"
  ),
  "nftc" = list(
    src = nodes$consortium_nftc$id, tgt = nodes$studies$id,
    color = glue(ctf_base, a = link_alpha),
    value = 2,
    label = "2"
  ),
  "ntap_open" = list(
    src = nodes$consortium_ntap_op$id, tgt = nodes$studies$id,
    color = glue(ntap_base, a = link_alpha),
    value = 14,
    label = "14"
  ),
  "pro" = list(
    src = nodes$consortium_pro$id, tgt = nodes$studies$id,
    color = glue(ntap_base, a = link_alpha),
    value = 4,
    label = "4"
  ),
  "synodos" = list(
    src = nodes$consortium_synodos$id, tgt = nodes$studies$id,
    color = glue(ctf_base, a = link_alpha),
    value = 6,
    label = "6"
  ),
  "vri" = list(
    src = nodes$consortium_vri$id, tgt = nodes$studies$id,
    color = glue(gff_base, a = link_alpha),
    value = 11,
    label = "11"
  )
)

plot_ly(
  type = "sankey",
  orientation = "h",
  
  node = list(
    label = c(
      map(nodes, 'label') %>% unlist
    ),
    color = c(
      map(nodes, 'color') %>% unlist
    ),
    pad = 15,
    thickness = 20,
    line = list(
      color = "black",
      width = 0.5
    )
  ),
  
  link = list(
    color = c(
      map(links, 'color') %>% unlist
    ),
    source = c(
      map(links, 'src') %>% unlist
    ),
    target = c(
      map(links, 'tgt') %>% unlist
    ),
    value =  c(
      map(links, 'value') %>% unlist
    ),
    label = c(
      map(links, 'label') %>% unlist
    )
  )
)

