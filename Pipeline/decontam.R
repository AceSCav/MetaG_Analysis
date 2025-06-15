library(decontam)
library(phyloseq)
#The following code was adapted from:
#https://benjjneb.github.io/decontam/vignettes/decontam_intro.html


##Command line arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 3) {
  stop("Usage: Rscript decontam.R <ASV_TABLE_FILE> <METADATA_FILE> <OUTPUT_DIR>")
}

asv_file <- args[1]
metadata_file <- args[2]
output_dir <- args[3]

if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

#Loading ASVs table
asv_table <- read.table(asv_file, header = TRUE, row.names = 1,
                        check.names = FALSE, skip = 1, sep = "\t")
asv_matrix <- as.matrix(asv_table)

# Loading metadata
metadata <- read.table(metadata_file, header = TRUE, row.names = 1, sep = "\t")

# Matching column names to metadata rownames
colnames(asv_matrix) <- rownames(metadata)

#Creating phyloseq object
OTU <- otu_table(asv_matrix, taxa_are_rows = TRUE)
SAM <- sample_data(metadata)
ps <- phyloseq(OTU, SAM)

#Running decontam (with prevalence-based method)
is.neg <- sample_data(ps)$SampleType %in% c("ASW_Control", "DNA_Control")
contamdf.prev <- isContaminant(ps, method = "prevalence", neg = is.neg)

cat("Not contaminants :", sum(!contamdf.prev$contaminant), "\n")
cat("Contaminants :", sum(contamdf.prev$contaminant), "\n")

#Filtering out contaminants
ps_clean <- prune_taxa(!contamdf.prev$contaminant, ps)

#Saving cleaned table
otu <- as(otu_table(ps_clean), "matrix")

if (!taxa_are_rows(ps_clean)) {
  otu <- t(otu)
}

output_file <- file.path(output_dir, "decontam-filtered-table.tsv")
write.table(otu, file = output_file, sep = "\t",
            quote = FALSE, col.names = NA)

cat("Cleaned ASV table successfully saved to :", output_file, "\n")
