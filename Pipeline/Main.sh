#!/bin/bash
set -e

echo "Welcome to the MetaG_Analysis pipeline!"
echo "With this pipeline, you'll be able to clean, trimm and perform statistical analysis on your 16S sequencing data using QIIME2 and R."
echo "This tool was created for a college project focused on the 16S sequencing, so keep in mind it's tailored for that context."
echo "We highly recommend running this pipeline inside the QIIME2 docker, version 2024.10. With this we assure it will run smoothly"
echo "Once started, the pipeline will guide you through each step, so no need to worry!"
echo "We did our best to make it as user-friendly as possible :)"
echo "If you need additional help, check the README or our repository at:"
echo "👉 https://github.com/AceSCav/MetaG_Analysis"
echo ""
echo "Alright, let's begin your analysis!"

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'

echo -e "\nFirst, we need the path to your main data directory:"

read -rp "Enter your data directory path: " DATADIR

RESULTS_DIR="$(realpath "$DATADIR")/Results"
mkdir -p "$RESULTS_DIR"

echo "Note: A folder named <Results> will be created here with all the files originating from this pipeline"

echo ""
echo "Now that we have our directory, let's start with cleaning and trimming the data."
echo "Currently running CleanTrim.sh..."
./CleanTrim.sh "$DATADIR" "$RESULTS_DIR"

echo ""
echo "Done with that part! Now, what comes next is up to you."
echo "You have two options:"
echo "1. Check for contaminants using control samples (only if you have them)."
echo "2. Skip directly to the statistical analysis."
read -rp "So what option will it be? (1 = run decontam, 2 = skip): " answer

if [[ "$answer" == "1" ]]; then
  echo "We will now check for contaminants."

  #Export QIIME table first
  echo "Exporting QIIME table from QZA..."
  qiime tools export --input-path "$RESULTS_DIR/table.qza" --output-path "$RESULTS_DIR/exported-table"

  echo "Converting .biom to .tsv for decontam..."
  biom convert -i "$RESULTS_DIR/exported-table/feature-table.biom" -o "$RESULTS_DIR/exported-table/feature-table.tsv" --to-tsv

  ASV_TABLE="$RESULTS_DIR/exported-table/feature-table.tsv"
  METADATA_FILE="$DATADIR/metadata.tsv"

  if [ ! -f "$ASV_TABLE" ]; then
    echo "Error: ASV table not found at $ASV_TABLE"
    exit 1
  fi

  if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: metadata file not found at $METADATA_FILE"
    exit 1
  fi

  # Run decontam
  echo "Running decontam.R with ASV and metadata files..."

  Rscript decontam.R "$ASV_TABLE" "$METADATA_FILE" "$RESULTS_DIR"

  table_path="$RESULTS_DIR/decontam-filtered-table.tsv"

  if [ ! -f "$table_path" ]; then
    echo "Error: decontam did not produce cleaned table at $table_path"
    exit 1
  fi

  echo "Decontam finished successfully. Cleaned table is at $table_path"

  # Convert cleaned table back to .biom first
  cleaned_biom="$RESULTS_DIR/decontam-filtered-table.biom"

  biom convert \
    -i "$table_path" \
    -o "$RESULTS_DIR/decontam-filtered-table.biom" \
    --table-type="OTU table" \
    --to-hdf5

  if [ ! -f "$cleaned_biom" ]; then
    echo "Error: Failed to convert cleaned table back to .biom"
    exit 1
  fi

  # Import back into QIIME 2
  cleaned_qza="$RESULTS_DIR/table-cleaned.qza"

  qiime tools import \
    --input-path "$RESULTS_DIR/decontam-filtered-table.biom" \
    --type "FeatureTable[Frequency]" \
    --input-format BIOMV210Format \
    --output-path "$RESULTS_DIR/table-cleaned.qza"

  if [ ! -f "$cleaned_qza" ]; then
    echo "Error: Failed to import cleaned table back into QIIME 2"
    exit 1
  fi

  table_file="$cleaned_qza"

else
  echo "Got it! Skipping decontam."
  table_file="$RESULTS_DIR/table.qza"
fi

echo ""
echo "Good, now we have our data ready for our final step. Yay!"
echo "Lets go for the stats then."
echo "Currently running Stats.sh..."
./Stats.sh "$DATADIR" "$table_path" "$RESULTS_DIR"

echo ""
echo "🎉 All main analysis steps are complete!"
echo "You can now explore your QIIME2 artifacts (.qza and .qzv files) using:"
echo "🔗 https://view.qiime2.org/"
echo ""
echo "Would you like to export any QIIME2 artifact or visualization to regular formats? (y/n)"
read -r export_choice

while [[ "$export_choice" == "y" ]]; do
    echo "Which type of file do you want to export? (qza/qzv)"
    read file_type

    if [[ "$file_type" == "qza" || "$file_type" == "qzv" ]]; then
        echo "Enter the path to your .$file_type file:"
        read -rp file_path

        file_dir=$(dirname "$file_path")
        file_name=$(basename "$file_path")

        export_path="$RESULTS_DIR/exported_${file_name%.*}"
        mkdir -p "$export_path"

        echo "Exporting $file_name to $export_path..."
        qiime tools export \
            --input-path "$file_path" \
            --output-path "$export_path"

        if [[ "$file_type" == "qza" ]]; then
            biom_file=$(find "$export_path" -name "*.biom" | head -n 1)
            if [[ -n "$biom_file" ]]; then
                echo "BIOM file found. Converting to TSV..."
                biom convert \
                    -i "$biom_file" \
                    -o "${biom_file%.biom}.tsv" \
                    --to-tsv
                echo "Conversion complete: ${biom_file%.biom}.tsv"
            fi
        fi
    else
        echo "Oops... invalid file type. Please enter either 'qza' or 'qzv'."
    fi

    echo ""
    read -rp "Do you want to export another file? (y/n): " export_choice
done

echo ""
echo "Exporting complete. 🎊"
echo "Thanks for using the MetaG_Analysis pipeline. See you next time!"
exit 0