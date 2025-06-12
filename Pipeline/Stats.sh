#!/bin/bash

DATADIR=$1
TABLE=$2

metadata_file="$DATADIR/metadata.csv"

echo "Importing metadata file..."
echo "Preparing for rarefaction curve..."
echo "What maximum sequencing depth do you want for the rarefaction curve?"
echo "This is often based on the sequencing depth of your samples (e.g. 10000–20000)"
read -r max_depth

qiime diversity alpha-rarefaction \
  --i-table "$DATADIR/table-decontam.qza" \
  --i-phylogeny "$DATADIR/tree.qza" \
  --p-max-depth "$max_depth" \
  --o-visualization "$DATADIR/rarefaction.qzv"

echo""
echo "Now we will start with the taxonomic summary."
echo "First we will do a taxa barplot..."
qiime taxa barplot \
  --i-table "$DATADIR/table-decontam.qza" \
  --i-taxonomy "$DATADIR/taxonomy.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/taxa-barplot.qzv"

echo""
echo "Now for boxplots of diversity metrics."
echo "Let's start with the core metrics we need to do the next stats."
echo "We will now create a new folder named <core-metrics-results>"
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "$DATADIR/tree.qza" \
  --i-table "$DATADIR/table-decontam.qza" \
  --p-sampling-depth "$max_depth" \
  --m-metadata-file "$metadata_file" \
  --output-dir "$DATADIR/core-metrics-results"

echo""
echo "Next we will the Shannon and Simpson alpha diversity"
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$DATADIR/core-metrics-results/shannon_vector.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/shannon-group-significance.qzv"

echo ""
echo "We will now calculate the Simpson diversity values"
qiime diversity alpha \
  --i-table "$DATADIR/table-decontam.qza" \
  --p-metric simpson \
  --o-alpha-diversity "$DATADIR/simpson_vector.qza"

echo ""
echo "And generate the respective diversity boxplot!"
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$DATADIR/simpson_vector.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/simpson_boxplot.qzv"

echo""
echo "We are done with Shannon and Simpson."
echo "Let's go for the PCA and PCoA plots!"

echo ""
echo "Now we will be doing the Unweighted UniFrac PCoA"
qiime emperor plot \
  --i-pcoa "$DATADIR/core-metrics-results/unweighted_unifrac_pcoa_results.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/unweighted-unifrac-emperor.qzv"

echo ""
echo "Calculating the Euclidean distance matriz and PCoA"
qiime diversity beta \
  --i-table "$DATADIR/table-decontam.qza" \
  --p-metric euclidean \
  --o-distance-matrix "$DATADIR/euclidean_distance.qza"

qiime diversity pcoa \
  --i-distance-matrix "$DATADIR/euclidean_distance.qza" \
  --o-pcoa "$DATADIR/euclidean_pcoa.qza"

qiime emperor plot \
  --i-pcoa "$DATADIR/euclidean_pcoa.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/euclidean_emperor.qzv"

echo ""
echo "Lets calculate the Bray-Curtis distance and the PCoA"
qiime diversity beta \
  --i-table "$TABLE" \
  --p-metric braycurtis \
  --o-distance-matrix "$DATADIR/braycurtis_distance.qza"

qiime diversity pcoa \
  --i-distance-matrix "$DATADIR/braycurtis_distance.qza" \
  --o-pcoa "$DATADIR/braycurtis_pcoa.qza"

qiime emperor plot \
  --i-pcoa "$DATADIR/braycurtis_pcoa.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/braycurtis_emperor.qzv"

echo ""
echo "Lets now start calculating the Jaccard distance and the PCoA"
qiime diversity beta \
  --i-table "$DATADIR/table-decontam.qza" \
  --p-metric jaccard \
  --o-distance-matrix "$DATADIR/jaccard_distance.qza"

qiime diversity pcoa \
  --i-distance-matrix "$DATADIR/jaccard_distance.qza" \
  --o-pcoa "$DATADIR/jaccard_pcoa.qza"

qiime emperor plot \
  --i-pcoa "$DATADIR/jaccard_pcoa.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/jaccard_emperor.qzv"

echo ""
echo "Now lets do the weighted UniFrac distance and the PCoA"
qiime diversity beta-phylogenetic \
  --i-table "$DATADIR/table-decontam.qza" \
  --i-phylogeny "$DATADIR/tree.qza" \
  --p-metric weighted_unifrac \
  --o-distance-matrix "$DATADIR/weighted_unifrac_distance.qza"

qiime diversity pcoa \
  --i-distance-matrix "$DATADIR/weighted_unifrac_distance.qza" \
  --o-pcoa "$DATADIR/weighted_unifrac_pcoa.qza"

qiime emperor plot \
  --i-pcoa /data/weighted_unifrac_pcoa.qza \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/weighted_unifrac_emperor.qzv"

echo ""
echo "And ending with the Unweighted UniFrac distance and the PCoA"
qiime diversity beta-phylogenetic \
  --i-table "$DATADIR/table-decontam.qza" \
  --i-phylogeny "$DATADIR/tree.qza" \
  --p-metric unweighted_unifrac \
  --o-distance-matrix "$DATADIR/unweighted_unifrac_distance.qza"

qiime diversity pcoa \
  --i-distance-matrix "$DATADIR/unweighted_unifrac_distance.qza" \
  --o-pcoa "$DATADIR/unweighted_unifrac_pcoa.qza"

qiime emperor plot \
  --i-pcoa "$DATADIR/unweighted_unifrac_pcoa.qza" \
  --m-metadata-file "$metadata_file" \
  --o-visualization "$DATADIR/unweighted_unifrac_emperor.qzv"

echo ""
echo "Time for some stats — PERMANOVA style."
echo "We’ll test if sample groups (based on your metadata columns) are significantly different."

while true; do
  echo ""
  echo "Which metadata column do you want to use for PERMANOVA?"
  echo "(Tip: Check your metadata.csv file for column names like SampleType, etc.)"
  read -r metadata_column

  if grep -q "$metadata_column" "$metadata_file"; then
    echo "Running PERMANOVA for column: $metadata_column"

    output_file="$DATADIR/permanova-${metadata_column}.qzv"

    qiime diversity beta-group-significance \
      --i-distance-matrix "$DATADIR/braycurtis_distance.qza" \
      --m-metadata-file "$metadata_file" \
      --m-metadata-column "$metadata_column" \
      --p-method permanova \
      --o-visualization "$output_file"

    echo "Done! Result saved in $output_file"
  else
    echo "Oops! Column '$metadata_column' not found in metadata.csv. Try again."
    continue
  fi

  echo ""
  read -rp "Do you want to run PERMANOVA with another metadata column? (y/n): " again
  if [[ "$again" != "y" ]]; then
    break
  fi
done
 
echo "PERMANOVA analysis complete!"

