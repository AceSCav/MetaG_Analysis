<h1 align="center">🔬 MetaG Analysis - 16S Sequencing Pipeline</h1>
<p align="center">
A pipeline for QIIME2 16S rRNA microbial community analysis.
</p>

---

## Authors 
A group of 4 students from ESTBarreiro with their school id number assigned.
- Aleff Cavalcante, 202300054
- Bianca Silva, 202300273
- Filipa Fernandes, 202300218
- Ravi Silva, 202100191

---

## Index
- [About this repository](#about-this-repository)
- [About this pipeline](#about-this-pipeline)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [File Organization](#file-organization)

---

## About this repository
This repository was made to hold the data of a college project on the replication of 16S sequencing. We used the following article "The microbiome of a Pacific moon jellyfish Aurelia coerulea" (it can be found at: https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0298002) to use it as a base for our project.
It has three folders:
-Pipeline (where you find the files to run the QIIME2 and R files)
-Results (where you can find our stats and multiqc report)
-other_scripts&guides (here you can find a guide on how to do your own SILVA classifier; python scripts that might help you adjusting your phylo trees; a little overview on where we went to look for tutorials)

---

## About this pipeline
This pipeline performs a complete 16S rRNA sequencing analysis — from raw FASTQ files all the way to microbial community profiles — using QIIME2 and a suite of powerful statistical tools.  
It’s designed for reproducibility, ease of use, and education, making it perfect for students and researchers who want to learn more about microbial communities.
It's made for easy adaptation to your own use; you can easily find ways to tweak it for your needs.

---

## Features
- QIIME2 pipeline for 16S rRNA sequencing
- Reproducible and flexible workflow
- User-friendly instructions and prompts during execution
- Allows you to skip steps if you wish
- Educational — perfect for students and beginners in microbial ecology

---

## Installation

### Pre Requisites
✅ Docker and QIIME2 image (alternatives exist, but we advise QIIME2) - for this we used Docker v.27.5.1 and QIIME2 CLI version 2024.10.1
✅ R with the packages `phyloseq` and `decontam` (but the decontam.R on the pipeline installs it for you too) 
✅ A manifest.tsv and metadata.tsv files adapted for QIIMME2 (a *.csv can be used too, but then you'd need to change it on the pipeline files)

### Installation Steps

1. Clone the repository:
```shell
git clone https://github.com/AceSCav/MetaG_Analysis.git
cd MetaG_Analysis/Pipeline
```
---

## Usage
### Run the pipeline:
```sh
./Main.sh
```

After running you'll be prompt with the informations of this pipeline along side of how to use it. During the process you'll always be told what to do and explained what is happenning. You'll have the choice to skip some steps too.

---

## File Organization
All the files have self explanatory names, but in the end you should have something like this:
![image](https://github.com/user-attachments/assets/7f0ca69c-a718-4c97-a682-a2ba711c6ae8)
####Expected directory structure after pipeline execution.
