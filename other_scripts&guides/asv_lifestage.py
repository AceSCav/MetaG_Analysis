import pandas as pd

metadata = pd.read_csv("metadata.tsv", sep='\t')

metadata = metadata[metadata["SampleType"] != "DNA_Control"]
metadata = metadata.dropna(subset=["LifeStage"])
print(metadata["LifeStage"].value_counts())

sample_to_stage = metadata.set_index("sample-id")["LifeStage"].to_dict()
print("Samples in metadata:", len(sample_to_stage))
asv_table = pd.read_csv("decontam-filtered-table.tsv", sep='\t', index_col=0)
print("Number of ASVs:", len(asv_table))

life_stage_asvs = {}
for sample, stage in sample_to_stage.items():
    if sample in asv_table.columns:
        asvs_present = asv_table[asv_table[sample] > 0].index.tolist()
        for asv in asvs_present:
            life_stage_asvs.setdefault(asv, set()).add(stage)

with open("asv_to_lifestage.tsv", "w") as f:
    f.write("ASV\tLife_Stages\n")
    for asv, stages in life_stage_asvs.items():
        f.write(f"{asv}\t{';'.join(sorted(stages))}\n")