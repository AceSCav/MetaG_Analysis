#!/bin/bash

DATADIR=$1

manifest_file="$DATADIR/manifest.csv"

echo "Importing manifest file..."
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path "$manifest_file" \
  --input-format SingleEndFastqManifestPhred33V2 \
  --output-path "$DATADIR/demux.qza"

echo "Visualizing imported reads for sequencing quality and distribution..."
qiime demux summarize \
  --i-data "$DATADIR/demux.qza" \
  --o-visualization "$DATADIR/demux.qzv"

read -rp "Enter forward trim left (e.g. 5): " trim_left_f
read -rp "Enter reverse trim left (e.g. 10): " trim_left_r
read -rp "Enter forward trunc length (e.g. 177): " trunc_len_f
read -rp "Enter reverse trunc length (e.g. 170): " trunc_len_r

echo "Denoising with DADA2... this might take a bit so be patience."
qiime dada2 denoise-paired \
  --i-demultiplexed-seqs "$DATADIR/demux.qza" \
  --p-trim-left-f "$trim_left_f" \
  --p-trim-left-r "$trim_left_r" \
  --p-trunc-len-f "$trunc_len_f" \
  --p-trunc-len-r "$trunc_len_r" \
  --o-table "$DATADIR/table.qza" \
  --o-representative-sequences "$DATADIR/rep-seqs.qza" \
  --o-denoising-stats "$DATADIR/denoising-stats.qza" 

echo "Reviewing denoising performance..."
qiime metadata tabulate \
  --m-input-file "$DATADIR/denoising-stats.qza" \
  --o-visualization "$DATADIR/denoising-stats.qzv"

echo "Assigning taxonomy..."
read -rp "Enter the path to your classifier file (.qza): " classifier_file
qiime feature-classifier classify-sklearn \
  --i-classifier "$classifier_file" \
  --i-reads "$DATADIR/rep-seqs.qza" \
  --o-classification "$DATADIR/taxonomy.qza"

echo "Visualizing taxonomy table..."
qiime metadata tabulate \
  --m-input-file "$DATADIR/taxonomy.qza" \
  --o-visualization "$DATADIR/taxonomy.qzv"

echo "Filtering samples and features..."
read -rp "Enter minimum frequency to filter samples (e.g., 3500): " min_freq_samples
read -rp "Enter minimum number of samples a feature must appear in (e.g., 2): " min_samples_features
read -rp "Enter minimum frequency for features (e.g., 100): " min_freq_features

# Remove samples with < min_freq_samples reads
qiime feature-table filter-samples \
  --i-table "$DATADIR/table.qza" \
  --p-min-frequency "$min_freq_samples" \
  --o-filtered-table "$DATADIR/table-filtered.qza"

# Remove low-frequency features (singletons, low-abundance noise)
qiime feature-table filter-features \
  --i-table "$DATADIR/table-filtered.qza" \
  --p-min-samples "$min_samples_features" \
  --p-min-frequency "$min_freq_features" \
  --o-filtered-table "$DATADIR/table-filtered-final.qza"

echo "Building a phylogenetic tree for diversity..."
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences "$DATADIR/rep-seqs.qza" \
  --o-alignment "$DATADIR/aligned-rep-seqs.qza" \
  --o-masked-alignment "$DATADIR/masked-aligned-rep-seqs.qza" \
  --o-tree "$DATADIR/unrooted-tree.qza" \
  --o-rooted-tree "$DATADIR/tree.qza"