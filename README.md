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
- [About this pipeline](#about-this-pipeline)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [File Organization](#file-organization)

---

## About this pipeline
This pipeline performs a complete 16S rRNA sequencing analysis — from raw FASTQ files all the way to microbial community profiles — using QIIME2 and a suite of powerful statistical tools.  
It’s designed for reproducibility, ease of use, and education, making it perfect for students and researchers who want to learn more about microbial communities.

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
✅ Docker and QIIME2 image (alternatives exist, but we advise QIIME2)  
✅ R with the packages `phyloseq` and `decontam`

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

### File Organization
