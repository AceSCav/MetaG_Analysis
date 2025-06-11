library(decontam)
library(phyloseq)
#The following code was adapted from:
#https://benjjneb.github.io/decontam/vignettes/decontam_intro.html

#Loading ASVs table
asv_table <- read.table("feature-table.tsv", header=TRUE, row.names=1, 
                        check.names=FALSE, skip=1, sep="\t")
asv_table <- as.matrix(asv_table)

metadata <- read.table("metadata.tsv", header=TRUE, row.names=1, sep="\t")

#Matching ASVs table columns with Metadata table rows
colnames(asv_table) <- rownames(metadata)

#Creating phyloseq object
OTU <- otu_table(asv_table, taxa_are_rows=TRUE)
SAM <- sample_data(metadata)
ps <- phyloseq(OTU, SAM)

#Running decontam (with prevalence-based method)
is.neg <- sample_data(ps)$SampleType %in% c("ASW_Control", "DNA_Control")
contamdf.prev <- isContaminant(ps, method = "prevalence", neg = is.neg)

#Viewing contaminants
table(contamdf.prev$contaminant)
##How many ASVs are classified as contaminants or not
##Not contaminants: 287
##Contaminants: 126

#Filtering out contaminants
ps_clean <- prune_taxa(!contamdf.prev$contaminant, ps)

#Saving cleaned table
otu <- as(otu_table(ps_clean), "matrix")

if (!taxa_are_rows(ps_clean)) {
  otu <- t(otu)
}

write.table(otu, file = "decontam-filtered-table.tsv", sep = "\t",
            quote = FALSE, col.names = NA)
