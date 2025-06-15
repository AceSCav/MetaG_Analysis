import pandas as pd

df = pd.read_csv("asv_to_lifestage.tsv", sep='\t')

df["PrimaryLifeStage"] = df["Life_Stages"].apply(lambda x: x.split(';')[0])

color_map = {
    "Polyp": "#FF69B4",     # Hot Pink
    "Ephyra": "#87CEEB",    # Sky Blue
    "Medusae": "#32CD32"    # Lime Green
}

df["Color"] = df["PrimaryLifeStage"].map(color_map)

df = df.rename(columns={"ASV": "#FeatureID", "PrimaryLifeStage": "LifeStage"})

output_df = df[["#FeatureID", "LifeStage", "Color"]]

output_df.to_csv("asv-stage-colors.tsv", sep='\t', index=False)
