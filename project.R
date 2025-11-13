#Load libraries
library(GO.db)
library(AnnotationDbi)
library(dplyr)
library(stringr)


#fake data

df <- data.frame(
  Gene = c("GeneA", "GeneB"),
  GO_IDs = c("GO:0001234;GO:0005678", "GO:0009012")
)


#Convert to long table
df_long <- df %>%
  separate_rows(GO_IDs, sep = ";")

#Get the terms and the ontology

df_long$TERM <- AnnotationDbi::select(GO.db,
                                      keys = df_long$GO_IDs,
                                      columns = c("TERM"),
                                      keytype = "GOID")$TERM

df_long$ONTOLOGY <- AnnotationDbi::select(GO.db,
                                          keys = df_long$GO_IDs,
                                          columns = c("ONTOLOGY"),
                                          keytype = "GOID")$ONTOLOGY

library(readxl)
eggnog <- read_excel(
  "Lachancea_thermotolerans_Eggnog/out.emapper.annotations.xlsx",
  skip = 2   # skip ONLY the first metadata row
)

library(dplyr)
library(tidyr)

go_df <- eggnog %>%
  select(Gene = query, GO_IDs = GOs) %>%
  filter(!is.na(GO_IDs), GO_IDs != "-")
head(go_df)

go_df$GO_IDs <- gsub(",", ";", go_df$GO_IDs)

go_long <- go_df %>%
  separate_rows(GO_IDs, sep = ";") %>%
  distinct()

library(GO.db)
library(AnnotationDbi)

mapped <- AnnotationDbi::select(
  GO.db,
  keys = go_long$GO_IDs,
  columns = c("TERM", "DEFINITION", "ONTOLOGY"),
  keytype = "GOID"
)

final_go <- go_long %>%
  left_join(mapped, by = c("GO_IDs" = "GOID"))




